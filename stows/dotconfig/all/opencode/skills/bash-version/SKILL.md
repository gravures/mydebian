---
name: bash-version
description: |-
  Determine the minimum required bash version for a script or project by analyzing syntax and feature usage.
  Use for checking bash compatibility, portability audits, or when migrating scripts to newer/older bash versions.

  Examples:
  - user: "What bash version does this script need?" → scan file for features, return minimum version
  - user: "Check bash compatibility for this project" → scan all .sh files, report per-file and overall minimum
  - user: "Can this script run on bash 4.4?" → check features against target version
  - user: "Audit this project for bash version requirements" → full scan with summary table
---

# Bash Version Detector

Analyze bash scripts to determine the minimum required bash version.

## Workflow

1. **Identify scope** — single file, list of files, or entire project
2. **Scan** — extract bash features used in each file (see Detection Rules below)
3. **Match** — compare features against `references/features-by-versions.md` to find minimum version per file
4. **Report** — present results as a table (file → min version → features found)
5. **Conclude** — state the overall minimum version required across all scanned files
6. **Offer next steps** — ask user what to do next (see Post-Analysis Options below)

## Detection Rules

Scan for these patterns and map to versions using `references/features-by-versions.md`:

- **Parameter expansions**: `${var@Q}`, `${var@U}`, `${var@k}`, `${var,,}`, `${var^^}`, `${var/pat/&}`, `${CMDS;}`, `${|CMDS;}`
- **Arrays**: `declare -A` (associative, 4.0+), `assoc=(key val)` syntax (5.1+), `array[-idx]` (4.3+)
- **Conditionals**: `[[ =~ ]]` (3.0+), `;&` / `;;&` case fall-through (4.0+)
- **Loops**: `for ((;;))` (2.04+)
- **Here-strings**: `<<<` (2.05b+)
- **Builtins**: `mapfile`/`readarray` (4.0+), `readarray -d` (4.4+), `printf -v` (3.1+), `coproc` (4.0+), `compopt` (4.0+), `declare -n` (4.3+), `declare -g` (4.2+), `test -v` (4.2+), `test -R` (4.3+)
- **Options**: `pipefail` (3.0+), `lastpipe` (4.2+), `extglob` (2.02+), `globstar` (4.0+), `nocasematch` (3.1+)
- **Shopt options**: `failglob` (3.0+), `patsub_replacement` (5.2+), `globskipdots` (5.2+), `array_expand_once` (5.3+), `localvar_inherit` (5.0+)
- **Variables**: `BASH_REMATCH` (3.0+, no longer readonly in 5.1+), `SRANDOM` (5.1+), `EPOCHSECONDS`/`EPOCHREALTIME` (5.0+), `BASH_ARGV0` (5.0+), `PS0` (4.4+), `READLINE_ARGUMENT` (5.2+), `GLOBSORT` (5.3+), `BASH_REMATCH` as local (5.3+)
- **Read flags**: `read -t 0.5` (4.0+), `read -i` (4.0+), `read -N` (4.1+), `read -d` (2.04+), `read -E` (5.3+)
- **Arithmetic**: `i++` (2.04+), `**` exponentiation (2.02+)
- **Quoting**: `$'...'` (2.0+), `\xXX` (2.02+), `\uXXXX` (4.2+), `printf %#Q` (5.3+), `printf %Q` (5.2+)
- **Brace expansion**: `{x..y..incr}` (4.0+), leading zeros `{009..012}` (4.0+), `{x..y}` (3.0+)
- **Process substitution**: `$!` with wait for procsubs (4.4+)
- **FD variable assignment**: `{var}>` / `{var}<` (4.1+)
- **Misc**: `mapfile -d` (4.4+), `wait -n` (4.3+), `wait -p` (5.1+), `wait -f` (5.0+), `declare -I` (5.1+), `compgen -V` (5.3+), `printf %l.*s` (5.3+)

For each file, track which features are found and their introducing version. The file's minimum version is the highest version among all detected features.

## Post-Analysis Options

After presenting results, ask the user:

> What would you like to do next?

| # | Option | Description |
|---|--------|-------------|
| 1 | Add heading comment to each file | Insert a comment block at the top of each `.sh` file listing its detected features and minimum version as a table |
| 2 | Add README table | Create/update a `README.md` in the project root with an overall summary table of all files, versions, and features |
| 3 | Nothing | End here |
| 4 | Custom request | Let the user type a specific follow-up request |

### Heading comment format (option 1)

```bash
# ┌──────────────────────────────┬─────────┐
# │ Feature                      │ Version │
# ├──────────────────────────────┼─────────┤
# │ associative arrays (declare -A) │ 4.0     │
# │ pipefail                     │ 3.0     │
# └──────────────────────────────┴─────────┘
# Minimum bash version: 4.0
```

### README table format (option 2)

```markdown
# Bash Version Requirements

| File | Min Version | Features |
|------|-------------|----------|
| scripts/deploy.sh | 4.2 | declare -A, pipefail, lastpipe |
| lib/utils.sh | 5.1 | SRANDOM, assoc+=() |
| **Overall** | **5.1** | |
```

## Script scanning tips

- Use `grep -rn` or regex to find feature patterns in `.sh` files
- Ignore comments and quoted strings when scanning
- For projects, scan all `*.sh` files plus files with bash shebangs
- Consider `.bashrc`, `.bash_profile`, `.profile` if present
