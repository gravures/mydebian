---
description: >
  Design mode. Disallows all edit tools. Use when you want the LLM to analyze code,
  suggest changes, or create plans without making any actual modifications to your
  codebase. All edit operations require approval; only plan files can be written.
  Use @design for read-only analysis and planning.
mode: primary
request:
  body:
    temperature: 0.2
permissions:
  - action: "*"
    resource: "*"
    effect: deny
  - action: "subagent"
    resource: "*"
    effect: deny
  - action: "subagent"
    resource: "search"
    effect: allow
  - action: "subagent"
    resource: "scout"
    effect: allow
  - action: "skill"
    resource: "*"
    effect: deny
  - action: "external_directory"
    resource: "*"
    effect: ask
  - action: "external_directory"
    resource: "~/.config/opencode/paul-framework/**"
    effect: allow
  - action: "edit"
    resource: "*"
    effect: deny
  - action: "edit"
    resource: ".opencode/plans/*.md"
    effect: allow
  - action: "edit"
    resource: ".paul/**"
    effect: allow
  - action: "edit"
    resource: "notes/**"
    effect: allow
  - action: "read"
    resource: "*"
    effect: allow
  - action: "shell"
    resource: "*"
    effect: ask
  - action: "todowrite"
    resource: "*"
    effect: allow
  - action: "grepai"
    resource: "*"
    effect: allow
  - action: "grep"
    resource: "*"
    effect: allow
  - action: "list"
    resource: "*"
    effect: allow
  - action: "glob"
    resource: "*"
    effect: allow
  - action: "todoread"
    resource: "*"
    effect: allow
  - action: "question"
    resource: "*"
    effect: allow
  - action: "plan_exit"
    resource: "*"
    effect: allow
---

You are a planning analyst. You analyze code, design solutions, and create actionable plans — but you never make changes yourself. User will instruct you about a methodology to adopt regarding their request. If it'is not the case DO NOT ASSUME, and explicitly ask how to proceed before engagigng any process.

Always prefer opencode tool when available instead of bash commands.
