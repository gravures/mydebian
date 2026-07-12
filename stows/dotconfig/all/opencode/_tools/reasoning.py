#!/usr/bin/env python3
# ruff: noqa: D100, D101, D102, D103

from __future__ import annotations

import json
import re
import sys
import tempfile
from datetime import datetime
from pathlib import Path
from typing import Literal, NotRequired, Protocol, TypedDict


DEFAULT_MAX_LINES = 2000
DEFAULT_MAX_BYTES = 50 * 1024  # 50KB
MAX_THOUGHTS = 20
MAX_THOUGHT_LENGTH = 20000


class ThoughtData(TypedDict):
    thought: str
    thought_number: int
    total_thoughts: int
    next_thought_needed: bool
    is_revision: NotRequired[bool]
    revises_thought: NotRequired[int]
    branch_from_thought: NotRequired[int]
    branch_id: NotRequired[str]
    needs_more_thoughts: NotRequired[bool]


class ValidatedThoughtData(TypedDict):
    thought: str
    thought_number: int
    total_thoughts: int
    next_thought_needed: bool
    is_revision: bool
    revises_thought: NotRequired[int]
    branch_from_thought: int | None
    branch_id: str | None
    needs_more_thoughts: bool


##
# Validation
#
class ValidationError(TypedDict):
    field: str
    message: str


def validate_thought_data(data: ThoughtData) -> list[ValidationError]:
    errors: list[ValidationError] = []

    # thought: nonempty string with max length
    if not data["thought"].strip():
        errors.append({"field": "thought", "message": "Thought cannot be empty."})
    elif len(data["thought"]) > MAX_THOUGHT_LENGTH:
        errors.append({
            "field": "thought",
            "message": f"Thought exceeds {MAX_THOUGHT_LENGTH} characters.",
        })

    # thought_number: positive integer
    if not isinstance(data["thought_number"], int) or data["thought_number"] < 1:
        errors.append({
            "field": "thought_number",
            "message": "thought_number must be a positive integer.",
        })

    # total_thoughts: positive integer
    if not isinstance(data["total_thoughts"], int) or data["total_thoughts"] < 1:
        errors.append({
            "field": "total_thoughts",
            "message": "total_thoughts must be a positive integer.",
        })

    # next_thought_needed: boolean
    if not isinstance(data["next_thought_needed"], bool):
        errors.append({
            "field": "next_thought_needed",
            "message": "next_thought_needed must be a boolean.",
        })

    # is_revision: boolean (optional)
    if (rev := data.get("is_revision")) is not None and not isinstance(rev, bool):
        errors.append(
            {"field": "is_revision", "message": "is_revision must be a boolean."},
        )

    # revises_thought: positive integer (optional)
    if (rev := data.get("revises_thought")) is not None and (not isinstance(rev, int) or rev < 1):
        errors.append({
            "field": "revises_thought",
            "message": "revises_thought must be a positive integer.",
        })

    # branch_from_thought: positive integer (optional)
    if (brc := data.get("branch_from_thought")) is not None and (
        not isinstance(brc, int) or brc < 1
    ):
        errors.append({
            "field": "branch_from_thought",
            "message": "branch_from_thought must be a positive integer.",
        })

    # branch_id: non-empty string (optional)
    if (brc := data.get("branch_id")) is not None and (
        not isinstance(brc, str) or not brc.strip()
    ):
        errors.append({"field": "branch_id", "message": "branch_id must be a non-empty string."})

    return errors


def is_valid_thought_data(data: ThoughtData) -> bool:
    return not bool(validate_thought_data(data))


##
# Cross-field Validation
class CrossFieldValidationError(TypedDict):
    message: str


def enforce_cross_field_rules(data: ThoughtData) -> list[CrossFieldValidationError]:
    errors: list[CrossFieldValidationError] = []

    if data.get("is_revision", False):
        if (
            not isinstance(data.get("revises_thought"), int)
            or data.get("branch_id")
            or data.get("branch_from_thought")
        ):
            errors.append(
                CrossFieldValidationError(
                    message=(
                        "If is_revision=true, provide revises_thought and omit branch_* fields."
                    )
                )
            )
        elif data.get("revises_thought") is not None:
            errors.append(
                CrossFieldValidationError(
                    message="revises_thought only allowed when is_revision=true.",
                )
            )

    has_branch_fields = (
        data.get("branch_id") is not None or data.get("branch_from_thought") is not None
    )
    if has_branch_fields and (
        data.get("branch_id") is None
        or data.get("branch_from_thought") is None
        or data.get("is_revision", False)
    ):
        errors.append(
            CrossFieldValidationError(
                message=(
                    "branch_id and branch_from_thought required together and not with revision."
                )
            )
        )

    return errors


def is_valid_cross_field(data: ThoughtData) -> bool:
    return not bool(enforce_cross_field_rules(data))


class ThoughtTracker(Protocol):
    def add(self, thought: ValidatedThoughtData) -> None: ...
    def reset(self) -> None: ...
    def ensure_branch_is_valid(self, branch_from_thought: int | None = None) -> None: ...
    def ensure_revision_is_valid(self, revises_thought: int | None = None) -> None: ...
    def branches(self) -> list[str]: ...
    def __len__(self) -> int: ...


class CodeReasoningConfig(TypedDict):
    maxBytes: NotRequired[int]
    maxLines: NotRequired[int]


class TruncationResult(TypedDict):
    content: str
    truncated: bool
    truncatedBy: Literal["lines", "bytes"] | None
    totalLines: int
    totalBytes: int
    outputLines: int
    outputBytes: int
    lastLinePartial: bool
    firstLineExceedsLimit: bool


class Truncation(TypedDict):
    truncatedBy: Literal["lines", "bytes"] | None
    totalLines: int
    totalBytes: int
    outputLines: int
    outputBytes: int
    maxLines: int
    maxBytes: int


class McpToolDetails(TypedDict):
    tool: str
    truncated: bool
    truncation: NotRequired[Truncation]
    temp_file: NotRequired[str]


def truncate_head(content: str, max_lines: int, max_bytes: int) -> TruncationResult:
    """Truncate content from the head (keep first N lines/bytes).

    Suitable for file reads where you want to see the beginning.

    Returns:
        Never returns partial lines. If first line exceeds byte limit,
        returns empty content with firstLineExceedsLimit=true.
    """
    max_lines = max_lines or DEFAULT_MAX_LINES
    max_bytes = max_bytes or DEFAULT_MAX_BYTES
    total_bytes = byte_length(content)
    lines = content.split("\n")
    total_lines = len(lines)

    # Check if no truncation needed
    if total_lines <= max_lines and total_bytes <= max_bytes:
        return TruncationResult(
            content=content,
            truncated=False,
            truncatedBy=None,
            totalLines=total_lines,
            totalBytes=total_bytes,
            outputLines=total_lines,
            outputBytes=total_bytes,
            lastLinePartial=False,
            firstLineExceedsLimit=False,
        )

    # Check if first line alone exceeds byte limit
    if byte_length(lines[0]) > max_bytes:
        return TruncationResult(
            content="",
            truncated=True,
            truncatedBy="bytes",
            totalLines=total_lines,
            totalBytes=total_bytes,
            outputLines=0,
            outputBytes=0,
            lastLinePartial=False,
            firstLineExceedsLimit=True,
        )

    # Collect complete lines that fit
    output_lines: list[str] = []
    output_bytes_count = 0
    truncated_by = "lines"

    while (i := 0) < len(lines) and i < max_lines:
        i += 1
        line = lines[i]
        line_bytes = byte_length(line) + (1 if i > 0 else 0)  # +1 for newline

        if (output_bytes_count + line_bytes) > max_bytes:
            truncated_by = "bytes"
            break

        output_lines.append(line)
        output_bytes_count += line_bytes

    # If we exited due to line limit
    if len(output_lines) >= max_lines and output_bytes_count <= max_bytes:
        truncated_by = "lines"

    output_content = "\n".join(output_lines)
    final_output_bytes = byte_length(output_content)

    return TruncationResult(
        content=output_content,
        truncated=True,
        truncatedBy=truncated_by,
        totalLines=total_lines,
        totalBytes=total_bytes,
        outputLines=len(output_lines),
        outputBytes=final_output_bytes,
        lastLinePartial=False,
        firstLineExceedsLimit=False,
    )


SIZE_OF_STR = sys.getsizeof("")


def byte_length(string: str) -> int:
    return sys.getsizeof(string) - SIZE_OF_STR


def to_json_string(value: object) -> str:
    if isinstance(value, str):
        return value
    try:
        _ = json.dumps(value, indent=2)
    except TypeError:
        return str(value)
    else:
        return _


def format_size(bytes_: int) -> str:
    if bytes_ < 1024:
        return f"{bytes_}B"
    if bytes_ < (1024 * 1024):
        return f"{(bytes_ // 1024)}KB"
    return f"{(bytes_ // (1024 * 1024))}MB"


def normalize_number(value: object) -> int | None:
    if isinstance(value, int):
        return value

    if isinstance(value, str):
        try:
            parsed = int(value)
        except TypeError:
            return None
        else:
            return parsed
    return None


def write_temp_file(tool: str, content: str) -> str:
    safe = re.sub(r"[^a-zA-Z0-9_-]", "_", tool)
    file_name = f"code-reasoning-{safe}-{datetime.now().timestamp()}.txt"  # noqa: DTZ005
    file_path = Path(tempfile.gettempdir(), file_name)
    file_path.write_text(content, encoding="utf-8")
    return str(file_path)


def format_tool_output(
    tool_name: str, result: object, limits: CodeReasoningConfig
) -> dict[str, McpToolDetails]:
    raw_text = to_json_string(result)
    truncation = truncate_head(
        raw_text,
        limits.get("maxLines", DEFAULT_MAX_LINES),
        limits.get("maxBytes", DEFAULT_MAX_BYTES),
    )

    text = truncation["content"]
    temp_file: str | None = None

    if truncation["truncated"]:
        temp_file = write_temp_file(tool_name, raw_text)
        text += (
            f"\n\n[Output truncated: {truncation['outputLines']} of "
            f"{truncation['totalLines']} lines "
            f"({format_size(truncation['outputBytes'])} of "
            f"{format_size(truncation['totalBytes'])}). "
            f"Full output saved to: {temp_file}]"
        )

    if truncation["firstLineExceedsLimit"] and len(raw_text) > 0:
        text = (
            f"[First line exceeded {format_size(limits.get('maxBytes', DEFAULT_MAX_BYTES))} "
            f"limit. Full output saved to: {temp_file or 'N/A'}]\n"
            f"{text}"
        )

    return {
        "text": text,  # pyright: ignore[reportReturnType]
        "details": McpToolDetails(
            tool=tool_name,
            truncated=truncation["truncated"],
            truncation=Truncation(
                truncatedBy=truncation["truncatedBy"],
                totalLines=truncation["totalLines"],
                totalBytes=truncation["totalBytes"],
                outputLines=truncation["outputLines"],
                outputBytes=truncation["outputBytes"],
                maxLines=limits.get("maxLines", DEFAULT_MAX_LINES),
                maxBytes=limits.get("maxBytes", DEFAULT_MAX_BYTES),
            ),
            temp_file=temp_file or "",
        ),
    }
