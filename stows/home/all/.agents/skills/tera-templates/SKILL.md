---
name: tera-templates
description: |-
  Write and debug Tera templates (Jinja2-like Rust template engine), including templates used
  inside mise (mise.toml, tasks, .miserc.toml). Covers syntax, expressions, filters, tests,
  functions, control structures, inheritance, components, auto-escaping, custom
  filters/tests/functions, and mise-specific variables (`config_root`, `env`, `tools`) and
  helpers (`exec()`, `read_file()`). Use proactively when authoring or fixing Tera templates,
  building reusable components, writing mise config/task templates, or integrating Tera into a
  Rust app.

  Examples:
  - user: "Write a Tera template that lists products" → produce a for-loop + filter template
  - user: "How do I make a reusable Tera component?" → define a component with args, defaults, and a body slot
  - user: "Tera filter to group posts by year?" → use group_by(attribute="year") and iterate
  - user: "Debug this Tera template error" → check undefined variables, delimiters, tests vs filters
  - user: "Extend a base layout in Tera" → extends + blocks + super()
  - user: "Use a Tera template in mise.toml" → config_root/env/tools variables, exec(), quote filter
  - user: "Register a custom Tera filter in Rust" → implement Filter trait and register before loading templates
---

# Tera Templates

Tera is a Jinja2/Django-inspired template engine for Rust. Templates are text files where
`{{ ... }}` expressions are replaced (rendered) with context values.

## Delimiters

| Syntax | Purpose |
|--------|---------|
| `{{ ... }}` | Expressions (output) |
| `{% ... %}` | Statements (control flow, blocks) |
| `{# ... #}` | Comments (not rendered) |

Whitespace control: add a dash to strip adjacent whitespace — `{%-`, `-%}`, `{{-`, `-}}`, `{#-`, `-#}`.

## Minimal template workflow

1. **Know the context.** Variables only exist if inserted by Rust (or set with `{% set %}`).
   Rendering an undefined variable is an error — guard with `{% if var %}` or `| default(value=...)`.
2. **Choose the construct:**
   - Output value → `{{ name }}`, access with `obj.field` / `obj["some-key"]`
   - Transform value → **filter**: `{{ name | lower | replace(from="a", to="b") }}`
   - Check condition → **test** with `is`: `{% if n is odd %}`
   - Repeated block → `{% for x in items %} … {% endfor %}`
   - Reuse layout → `{% extends %}` + `{% block %}`
   - Reuse parameterized markup → `{% component %}` + `{{ <my.component ... /> }}`
3. **Escape correctly.** `.html`, `.htm`, `.xml` files are auto-escaped. Apply `| safe` only
   to content you trust, and remember some filters drop safety.

## Quick reference

**Output & access:** `{{ user.name }}`, `{{ a?.b?.c or "fallback" }}` (optional chaining),
`{{ product["some-key"] }}`, `{{ nums[0] }}`, `{{ nums[::-1] }}` (Python-style slicing).

**Expressions:** math `+ - * / % ** //`, comparisons `== != < <= > >=`,
logic `and or not`, concat `~`, membership `in` / `not in`, ternary
`{{ "yes" if flag else "no" }}`, spread `{...base, "d": 4}` and `[0, ...rest, 9]`.

**Control:** `{% if %}/{% elif %}/{% else %}/{% endif %}`, `{% for %}/{% else %}/{% endfor %}`
with `loop.index`, `loop.index0`, `loop.first`, `loop.last`, `loop.length`, plus `break`/`continue`.

**Assign:** `{% set x = 1 + 2 %}` (scoped), `{% set_global x = ... %}` (leaks out of loops).

**Reuse:** `{% include "partial.html" %}` (current context, static path), `{% raw %}…{% endraw %}`.

## Reference index

Load these on demand for full detail:

| Reference | Contents |
|-----------|----------|
| `references/syntax.md` | Literals, variables, names, dot/bracket access, optional chaining, all expressions, operator precedence |
| `references/filters.md` | Every built-in filter with signatures and examples |
| `references/tests-and-functions.md` | Built-in tests (`is odd`, `is defined`, …) and functions (`range`, `throw`) |
| `references/control-and-blocks.md` | if/for/assignments/include, loop variables, whitespace, comments, raw |
| `references/inheritance-and-components.md` | extends/blocks/super, full component system (args, types, spread, implicit params, slots) |
| `references/rust-api.md` | Cargo setup, loading templates, rendering, auto-escaping, custom filters/tests/functions |
| `references/mise.md` | Tera inside mise: where templates render, `config_root`/`env`/`tools`/`usage` variables, `exec()`/`read_file()`, mise filters & tests, task templates, `.miserc.toml`, Tera v1→v2 migration |

## Gotchas (frequent mistakes)

- **Tests ≠ filters.** Conditionals use `is` (`{% if x is odd %}`), transformations use `|`
  (`{{ x | length }}`). `is not` negates a test; `not in` negates membership.
- **Undefined ≠ none.** `none` exists and is falsy; an undefined variable errors when rendered.
- **`include` paths must be static strings.** `{% include "partials/" ~ name %}` is invalid —
  use a component to pass a custom context.
- **`include` has no custom context.** Values `set` inside an included template do not leak out.
  For a scoped context use components. To leak a value in a loop use `set_global`.
- **Components are hermetic.** They only see declared args plus `@`-implicit params, not all
  caller variables.
- **Auto-escaping is by output filename, not include site.** Including `partial.txt` from an
  `.html` file still escapes `partial.txt` content.
- **`sort`/`group_by` on structs needs `attribute=`.** e.g. `sort(attribute="author.name")`.
- **The default filter checks existence, not truthiness.** `"" | default(value="x")` stays `""`;
  add `boolean=true` to fall back on falsy values.
- **Register custom filters/tests/functions before loading templates**, or Tera errors because
  they can't be resolved during parsing.
- **`{{ super() }}` calls the parent block**, enabling multi-level inheritance.

## mise-specific gotchas

- **`exec()` runs on every render, including `--dry-run`,** and `read_file()`/`exec()` need a
  trusted config (they fail in `MISE_SAFE=1`). Only use side-effect-free commands.
- **`exec()`/`read_file()` resolve relative to the config file's directory**, not `cwd`.
- **Task `usage` values are not shell-quoted** — pipe through `| quote` before inserting into
  a command.
- **`config_root` stays at the project root** even when running mise from a subdirectory;
  `cwd` is where mise was invoked.
- **A `.miserc.toml` template that fails to render silently falls back to raw content**, and
  `vars`, `tools`, `exec()`, and `read_file()` are unavailable there.
- **Mise uses Tera v2**; v1 helpers still warn and are removed in 2027.4.0 (see `references/mise.md`).
