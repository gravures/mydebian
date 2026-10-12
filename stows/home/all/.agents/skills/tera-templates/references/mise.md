# Tera Templates in mise

Source: <https://mise.en.dev/templates.html>

mise renders **Tera v2** templates in config values, so a value can come from the project
directory, the environment, `[vars]`, or a command's output. These **string templates** are
different from [task templates](https://mise.en.dev/tasks/templates.html), which share task
definitions via `extends`.

Generic Tera syntax lives in `syntax.md`, `filters.md`, `tests-and-functions.md`,
`control-and-blocks.md`, and `inheritance-and-components.md`. This file covers only
mise-specific usage.

## Where templates are rendered

| File / section | What is rendered | Extra context |
|----------------|------------------|---------------|
| `mise.toml` | String values in most sections (`[env]`, `[tools]`, `[vars]`, `[hooks]`, `[plugins]`). Keys are not rendered; the file must be valid TOML first. | `config_source` |
| `[bootstrap]` | Some values only | None |
| Task fields (e.g. `run`) | When the task runs | `usage`, `tools`, `task_source_files()` |
| Dotfiles with `mode = "template"` | Source file content | see dotfiles docs |
| `.tool-versions` | Whole file | `config_source` |
| `.miserc.toml` | Whole file, before parsing | limited (see below) |

## Example

```toml
[env]
PROJECT_NAME = "{{ config_root | basename }}"
TERRAFORM_VERSION = "1.9"

[tools]
# an [env] value defined above
terraform = "{{ env.TERRAFORM_VERSION }}"
# NODE_VERSION from your shell, or 24 when it is unset
node = "{{ env.NODE_VERSION | default(value='24') }}"
```

Use `config_root` for paths inside the project: it stays at the project root even when mise
runs from a subdirectory, whereas `cwd` is the directory mise was run from.

## Syntax notes

Tera v2 syntax with the usual three delimiters (`{{ }}`, `{% %}`, `{# #}`); use a `raw`
block to keep delimiters literal. Tera v2 extras available: slices (`parts[0:2]`,
`parts[-1]`), spread (`[first, ...rest]`, `{...base, "key": value}`), list comprehensions
(`[t.name for t in tools if t.active]`), optional chaining (`env?.NODE_ENV or "development"`),
conditional expressions (`"prod" if release else "dev"`).

## Variables

| Variable | Value | Available in |
|----------|-------|--------------|
| `env` | Environment mise started with, plus `[env]` values resolved so far | Everywhere |
| `vars` | Config variables (`[vars]`) | `mise.toml` and tasks |
| `cwd` | Directory mise runs in | Everywhere |
| `config_root` | Config root of the file — the project directory, even for `.config/mise.toml`; in `[bootstrap.files]` content templates, the dir containing the declaring file | Everywhere |
| `config_source` | Absolute path of the config file as reached (symlinks not resolved) | `mise.toml` values, `.tool-versions`, `[env]` directives, a task's own `env` |
| `mise_bin` | Path of the running mise executable | Everywhere except `.miserc.toml` |
| `mise_pid` | Process ID of the running mise | Everywhere except `.miserc.toml` |
| `mise_env` | List of selected config environments; **undefined when none selected** → guard with `{% if mise_env is defined %}` | Everywhere except `.miserc.toml` |
| `xdg_cache_home`, `xdg_config_home`, `xdg_data_home`, `xdg_state_home` | XDG base directories | Everywhere |
| `tools` | Active, installed tools (see below) | Tasks, and `[env]` directives with `tools = true` |
| `usage` | Parsed task arguments | Task `run` scripts |
| `secrets` | `{{ secrets.NAME }}` grants a mise secret to the task | A task's own `env` only (experimental) |

Task fields other than `env` (e.g. `run`, `dir`) and file task headers have `config_root`
but not `config_source`.

`config_source` lets a symlinked shared config add its own `bin` dir to `PATH`:

```toml
[env]
_.path = "{{ config_source | canonicalize | dirname }}/bin"
```

`tools` maps each active tool to its installed active version, keyed by the config name
(`npm:prettier`) and the backend tool name (`prettier`). Installed-but-unselected and
selected-but-uninstalled versions are excluded.

- One active version: `tools.node.version` (e.g. `"24.1.0"`), `tools.node.path`.
- Several active versions (`python = ["3.14", "3.13"]`): a list —
  `tools.python[0].version`, `tools.python[1].path`.

## mise functions

`[]` marks optional arguments. Functions use named arguments.

| Function | Returns | Description |
|----------|---------|-------------|
| `exec(command, [cache_key], [cache_duration])` | string | Runs `command` with the default inline shell, returns output without trailing newline. |
| `read_file(path)` | string | File contents. Relative paths resolve from the template's directory, not `cwd`. |
| `get_env(name, [default])` | string | Variable from mise's starting environment (does **not** see `[env]`). Prefer `{{ env.NAME \| default(value="...") }}`. |
| `arch([x64=...], [arm64=...])` | string | CPU arch (`x64`, `arm64`, …); keyword renames, e.g. `arch(x64="amd64")`. |
| `os([linux=...], [macos=...], [windows=...])` | string | OS (`linux`, `macos`, `windows`); `os(macos="darwin")`. |
| `os_family()` | string | `unix` or `windows`. |
| `num_cpus()` | string | Number of CPUs: `{{ (num_cpus() \| int) * 2 }}`. |
| `choice(n, alphabet)` | string | `n` random chars from `alphabet`: `choice(n=64, alphabet="0123456789abcdef")`. |
| `haiku([words], [separator], [digits])` | string | Random readable name, e.g. `blazing-shadow-46`. Defaults 2 words, `-`, 2 digits. |
| `now([timezone])` | string | Current date/time; timezone defaults to UTC. Format with `date`: `{{ now() \| date(format="%Y") }}`. |
| `get_random(start, end, [seed])` | number | Random integer in range; `seed` makes it repeatable. |
| `range(end, [start], [step_by])` | list | Integers from `start` up to but excluding `end`. |
| `throw(message)` | none | Stops rendering with an error. |
| `task_source_files([only_changed])` | list | A task's source files (tasks only). |

### exec() and read_file()

- Both run/resolve in the directory of the **config file** holding the template. For
  `.config/mise.toml` that is `.config/`, not the project root. In task run scripts it is
  the task's working dir (`dir`, default config root). Never `cwd`.
- In `[env]`, `exec()` also sees variables set by earlier `[env]` entries; elsewhere it sees
  mise's starting environment.
- Both need a **trusted** config. In safe mode (`MISE_SAFE=1`) they fail; neither is
  available in `.miserc.toml`.
- **`exec()` runs every time its template renders, including under `--dry-run`.** Use only
  side-effect-free commands. (`mise bootstrap --dry-run` disables `exec()` in
  `[bootstrap.hooks]`, erroring with `exec() is disabled during dry run`.)
- Cache output under `MISE_CACHE_DIR` with `cache_key`/`cache_duration`; the cache is keyed
  by command, directory, and `cache_key`. `cache_duration` (e.g. `"1h"`, `"1d"`) expires it.

```toml
[env]
GIT_SHA = "{{ exec(command='git rev-parse --short HEAD') }}"
VERSION = "{{ read_file(path='VERSION') | trim }}"
AWS_ACCOUNT_ID = "{{ exec(command='aws sts get-caller-identity --query Account --output text', cache_key='aws-account', cache_duration='1d') }}"
```

## mise filters

`[]` marks optional arguments. Tera's own filters also work.

**Strings**

| Filter | Description |
|--------|-------------|
| `quote` | Quotes for a POSIX shell; embedded `'` use `'\''`. |
| `lower`, `upper` | Case conversion. |
| `capitalize` | First char upper, rest lower. |
| `title` | Capitalize each word. |
| `replace(from, to)` | Replace every `from` with `to`. |
| `trim`, `trim_start([pat])`, `trim_end([pat])` | Trim whitespace or `pat`. |
| `truncate(length, [end])` | Cut to `length`, append `end` (default `…`). |
| `split(pat)` | Split into a list. |
| `regex_replace(pattern, rep)` | Replace regex matches. |
| `default(value, [boolean])` | Fallback when undefined; `boolean=true` also replaces falsy/empty. |
| `kebabcase`, `lowercamelcase`, `uppercamelcase`, `snakecase`, `shoutysnakecase`, `shoutykebabcase` | Case conversion. |
| `slug`, `slugify` | URL-friendly slug. |
| `urlencode`, `urlencode_strict` | Percent-encode; `_strict` encodes all non-alphanumerics. |
| `b64_encode([url_safe], [padded])`, `b64_decode([url_safe])` | Base64. |
| `striptags`, `spaceless` | Remove HTML tags / whitespace between tags. |

`quote` targets POSIX shells (except a Windows daemon `run`, which pitchfork runs with
`cmd /C`). Use it when inserting a value into a shell command:

```toml
[tasks.create-config]
run = "touch {{ config_root | quote }}/generated.toml"
```

**Paths**

| Filter | Returns | Description |
|--------|---------|-------------|
| `absolute` | string | Absolute path (need not exist). |
| `canonicalize` | string | Absolute + resolve symlinks (fails if missing). |
| `dirname` / `basename` | string | `/foo/bar/baz.txt` → `/foo/bar` / `baz.txt`. |
| `extname` / `file_stem` | string | `txt` (no dot) / `baz`. |
| `file_size` | number | Size in bytes. |
| `last_modified` | number | mtime in seconds since epoch. |
| `join_path` | string | `{{ [config_root, "bar.txt"] \| join_path }}`. |

**Hashing**

| Filter | Description |
|--------|-------------|
| `hash([algorithm], [len])` | `sha256` (default) or `blake3`; `len` truncates. |
| `hash_file([len])` | BLAKE3 hash of a file; `len` truncates. |

**Lists, numbers, formatting**

| Filter | Description |
|--------|-------------|
| `first`, `last` | First/last list item. |
| `join(sep)` | Join a list. |
| `length` | Length of string or list. |
| `reverse` | Reverse string or list. |
| `shuffle([seed])` | Shuffle a list. |
| `int`, `float` | To number. |
| `abs` | Absolute value. |
| `filesize_format`, `filesizeformat` | Bytes → readable size. |
| `date(format, [timezone])` | Format a timestamp (`jiff` format). |
| `format(spec)` | Rust-style formatting. |
| `json_encode([pretty])` | Encode as JSON. |

## mise tests

Use with `is`, named arguments:

| Test | True when |
|------|-----------|
| `defined` | Variable is defined. |
| `string`, `number` | Value is a string / number. |
| `starting_with(pat)`, `ending_with(pat)`, `containing(pat)` | Substring/prefix/suffix checks. |
| `divisible_by(divisor)` | Number divisible by `divisor`. |
| `matching(pat)` | String matches regex `pat`. |
| `dir`, `file`, `exists` | Path is a dir / file / exists. |
| `before(other, [inclusive])`, `after(other, [inclusive])` | Date comparison, e.g. `release_date is after(other="2026-01-01")`. |
| `semver_matching(requirement)` | Version matches a semver requirement (`>=1.2`); semver-shaped versions only. |

```toml
[env]
VENV_STATUS = "{% if config_root ~ '/.venv' is dir %}present{% else %}missing{% endif %}"
```

## Templates in tasks

Task `run` scripts render at run time (so `tools` and helpers are available).

### Task arguments (`usage`)

`usage` keys are snake_case argument/flag names (`--dry-run` → `usage.dry_run`, same as
`$usage_dry_run`). Flags → booleans; count flags (`count=#true`, `-vvv`) → integers; variadic
args → lists.

Values are **not** shell-quoted — double quotes around an expression do not protect it. Pipe
strings through `quote`:

```toml
[tasks.deploy]
usage = '''
arg "<environment>" help="Target environment"
flag "-v --verbose" help="Enable verbose output"
arg "[tags]" var=#true
'''
run = '''
printf 'env=%s\n' {{ usage.environment | quote }}
printf 'verbose=%s\n' {{ usage.verbose | str | quote }}
{% for tag in usage.tags %}
printf 'tag=%s\n' {{ tag | quote }}
{% endfor %}
'''
```

### task_source_files()

`task_source_files([only_changed])` returns files matched by the task's `sources`, with globs
and templates expanded. Unmatched patterns and sourceless tasks yield empty lists.

```toml
[tasks.list-sources]
sources = ["src/**/*.ts", "package.json"]
run = '''
{% for file in task_source_files() %}
printf 'Processing: %s\n' {{ file | quote }}
{% endfor %}
'''
```

With `only_changed=true`, returns only sources modified since the task last succeeded. It
returns every source when the task has never succeeded or when it runs without changes
(`--force`, dependency did work). A failed run does not reset the baseline. Detection is by
mtime.

### Secrets (experimental)

With `experimental = true` under `[settings]`, `{{ secrets.NAME }}` in a task's own `env`
renders a mise secret and grants that key to the task. `secrets` is available nowhere else.

### Parameterized snippets with components

A Tera component expands a snippet multiple times with different arguments within one task
script:

```toml
[tasks.restart]
run = """
{% component restart(service, region="us-east-1") %}
aws ecs update-service --region {{ region | quote }} --cluster prod --service {{ service | quote }} --force-new-deployment
{% endcomponent %}
{{ <restart service="api" /> }}
{{ <restart service="worker" /> }}
{{ <restart service="api" region="eu-west-1" /> }}
"""
```

- Define the component in the same template string that calls it; mise has no shared
  component library.
- A component defined in `[vars]` renders at config load, not task run.
- To share a whole task use a task template; to share shell logic, source a shell file.
- Components need the default Tera v2 engine and do not work with `tera_v1`.

## Templates in .miserc.toml

Rendered before mise reads `mise.toml` or settings, so only OS info is available:

- `env` (mise's starting environment), `config_root` (dir holding `.miserc.toml`), `cwd`
- `xdg_*_home`
- Context-free functions: `arch()`, `os()`, `os_family()`, `num_cpus()`, `choice()`,
  `get_env()`
- All filters and tests

**Not available:** `mise_env`, `exec()`, `read_file()`, `mise_bin`, `mise_pid`, `vars`, `tools`.

```toml
# ~/.config/mise/miserc.toml
ceiling_paths = ["{{ env.HOME }}"]
ignored_config_paths = ["{{ xdg_config_home }}/mise/shared.toml"]
```

A block rendering to nothing leaves empty lines, which TOML ignores, so conditionals work:

```
{% if os() == "linux" %}
ceiling_paths = ["{{ env.HOME }}/work"]
{% endif %}
```

If a template fails to render (undefined variable, `exec()` call), mise **silently uses the
raw unrendered content** — no warning, because `.miserc.toml` is read before logging starts.
Use a `raw` block to keep a literal `{{`.

## Migrating from Tera v1

mise renders with Tera v2 but ships v1-shimmed builtins. Uncased v1 helpers warn when used,
and mise **2027.4.0 removes them.**

| Tera v1 pattern | Tera v2 replacement |
|-----------------|---------------------|
| `value \| trim_start_matches(pat="v")` | `value \| trim_start(pat="v")` |
| `value \| trim_end_matches(pat="-beta")` | `value \| trim_end(pat="-beta")` |
| `items \| slice(start=0, end=2)` | `items[0:2]` |
| `[base] \| concat(with="file.txt")` | `[base, "file.txt"]` |
| `[...items] \| concat(with=extra_items)` | `[...items, ...extra_items]` |
| `items \| map(attribute="name")` | `[item.name for item in items]` |
| `items \| filter(attribute="active")` | `[item for item in items if item.active]` |
| `value \| as_str` | `value \| str` |
| `value \| escape` | `value \| escape_html` |
| `value \| linebreaksbr` | `value \| newlines_to_br` |
| `value \| addslashes` | explicit `replace(from=..., to=...)` |
| `value is divisibleby(divisor=3)` | `value is divisible_by(divisor=3)` |
| `value is object` | `value is map` |
| `value \| indent(prefix=">")` | `value \| indent(width=1)` (spaces only) |
| `value \| truncate` | `value \| truncate(length=255)` |
| `value \| int(default=0)` / `float(default=0)` / `int`/`float` on non-numbers | Validate input first; Tera 2 errors instead of using a default. |
| `items \| first`/`last`/`nth(n=...)` on short/empty lists | Check `items \| length`; Tera 2 returns null, not `""`. |

Behavioral differences:

- `unique` still compares case-insensitively (as v1) until 2027.4.0, when it becomes Tera 2's
  case-sensitive version. `unique(case_sensitive=...)` warns and has no compatible replacement.
- `now()` takes `[timezone]` in v2; under `tera_v1`, the old `now([timestamp], [utc])` applies.
- v2 fails on undefined variables and has **no macros** (use components).
- To keep an old template working, set `tera_v1` (renders every template with Tera v1). In a
  shared `mise.toml`, set it as an env var so older mise ignores it:

```toml
[env]
MISE_TERA_V1 = true
```

Enabling `tera_v1` prints a deprecation warning and is removed in 2027.4.0; it does not apply
to `.miserc.toml`.
