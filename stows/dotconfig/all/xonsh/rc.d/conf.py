# ruff: noqa: INP001, CPY001, D100
from __future__ import annotations

import os
from pathlib import Path

from xonsh.built_ins import XSH


env: dict[str, str] = XSH.env
env |= os.environ
env["SHELL"] = "xonsh"

aliases: dict[str, str | list[str]] = XSH.aliases
with (Path.home() / ".config" / "shells" / "alias").open("r") as file:
    for line in file:
        if line.startswith("#"):
            continue
        line_ = line.rstrip("\n")
        line_ = line_.rstrip()
        _, _, alias = line_.partition(" ")
        name, _, what = alias.rpartition("=")
        what = what.replace('"', "")
        what = what.split(" ")
        aliases[name] = what
