---
name: bash-docs
description: |-
  Bash script documentation. Use when writing function comments,
  reviewing existing documentation, or establishing project documentation standards.
  Use proactively when creating or reviewing bash functions, documenting scripts,
  or establishing coding conventions.

  Examples:
  - user: "Document this bash function" → generate shdoc-formatted comment block
  - user: "Review the documentation in this script" → check shdoc compliance and completeness
  - user: "Add documentation to my bash library" → document functions with proper tags
  - user: "What format should I use for bash comments?" → explain shdoc structure and tags
---

# Bash Code Documentation (shdoc)

Standards for documenting bash scripts and functions using the [shdoc](https://github.com/reconquest/shdoc) comment format.

## When to Invoke

- Creating or updating bash function documentation
- Reviewing scripts for documentation completeness
- Establishing documentation standards for bash projects
- Refactoring functions with existing comments

## When NOT to Use

Do NOT use this skill for:

- Private helper functions (use `@internal` tag instead)
- Test scripts
- Prototyping or throwaway code

## Core Concepts

- Use **shdoc format** for documentation comments
- Place documentation **before** the function definition
- Use `#` for all documentation lines
- All tags start with `@` on their own line
- Include **examples** when possible.
- **Tone**: Clear, concise, technically precise

## Workflow

- [ ] Step 1: Analyze the function — identify purpose, arguments, and exit codes
- [ ] Step 2: Check for existing documentation and merge/extend as needed
- [ ] Step 3: Write `@description` with one-line summary (imperative mood)
- [ ] Step 4: Add extended description if complex behavior exists
- [ ] Step 5: Document each argument with `@arg` tag
- [ ] Step 6: Document options with `@option` tag (if any)
- [ ] Step 7: Document exit codes with `@exitcode` tag
- [ ] Step 8: Document stdout/stderr output with `@stdout`/`@stderr` tags
- [ ] Step 9: Add usage examples with `@example` tag
- [ ] Step 10: Verify all arguments and edge cases are covered

## File-Level Tags

Place these at the top of the file, before any function definitions:

```bash
#!/usr/bin/env bash
# @name MyLibrary
# @brief A library to solve a few problems.
# @description
#     The project solves lots of problems:
#      * a
#      * b
#      * c
#      * etc
```

| Tag | Purpose |
|-----|---------|
| `@name` or `@file` | Project name (used as doc title) |
| `@brief` | One-line project summary |
| `@description` | Multiline project description |

## Function-Level Tags

### @description

Multiline description of the function. Use imperative mood for the first sentence.

```bash
# @description Calculate discounted price with optional minimum floor.
# Computes the final price after applying a percentage discount.
# If the discounted price falls below the minimum, the floor is returned.
```

### @arg

Document positional parameters. Use `$1`, `$2`, etc.

```
# @arg $1 string A person's name.
# @arg $2 string Message priority.
```

Format: `@arg $N type Description.`

### @option

Document command-line options. Use `<value>` for arguments.

```
# @option -h Display help.
# @option --value=<value> Set a value.
# @option -v<value> | --value <value> Long option with short alternative.
```

### @noargs

Mark that the function accepts no arguments:

```
# @noargs
```

### @exitcode

Document exit codes. Can be specified multiple times:

```
# @exitcode 0 If successful.
# @exitcode 1 If an empty string passed.
# @exitcode 2 If file not found.
```

### @stdout

Document expected stdout output:

```
# @stdout The calculated discounted price.
```

### @stderr

Document expected stderr output (errors):

```
# @stderr Error message when percentage is out of range.
```

### @stdin

Document expected stdin input:

```
# @stdin The user's name from the terminal/command line.
```

### @set

Document global variables set by the function:

```
# @set REPLY string Greeting message.
```

### @example

Show concrete usage examples. Indent with 3 spaces:

```
# @example
#    echo "test: $(say-hello World)"
#
#    say-hello --formal "Bob"
#    # Output: Good morning, Bob.
```

### @see

Reference related functions or external docs:

```
# @see validate()
# @see [shdoc](https://github.com/reconquest/shdoc).
```

### @deprecated

Mark function as deprecated:

```
# @deprecated Use new_function() instead.
```

### @section

Group functions into logical sections:

```
# @section My utilities
# @description The following functions solve common problems.
```

### @internal

Skip documentation generation for internal functions:

```
# @internal
```

## Complete Example

**Input (undocumented):**

```bash
#!/usr/bin/env bash

calculate_discount() {
  local price="$1"
  local percentage="$2"
  local min_price="${3:-0}"

  if [[ "$percentage" -lt 0 || "$percentage" -gt 100 ]]; then
    echo "Error: percentage must be 0-100" >&2
    return 1
  fi

  local discounted
  discounted=$(( price * (100 - percentage) / 100 ))

  if [[ "$discounted" -lt "$min_price" ]]; then
    echo "$min_price"
  else
    echo "$discounted"
  fi
}
```

**Output (documented):**

```bash
#!/usr/bin/env bash

# @description Calculate discounted price with optional minimum floor.
# Computes the final price after applying a percentage discount.
# If the discounted price falls below the minimum floor, the
# floor price is returned instead.
#
# @arg $1 integer The original price (positive integer).
# @arg $2 integer The discount percentage (0-100).
# @arg $3 integer Optional minimum price floor. Default: 0.
#
# @exitcode 0 If successful.
# @exitcode 1 If the percentage is outside the valid range.
#
# @stdout The final discounted price.
#
# @example
#    calculate_discount 100 20
#    # Output: 80
#
#    calculate_discount 100 50 60
#    # Output: 60
#
#    calculate_discount 100 150
#    # Error: percentage must be 0-100
calculate_discount() {
  local price="$1"
  local percentage="$2"
  local min_price="${3:-0}"

  if [[ "$percentage" -lt 0 || "$percentage" -gt 100 ]]; then
    echo "Error: percentage must be 0-100" >&2
    return 1
  fi

  local discounted
  discounted=$(( price * (100 - percentage) / 100 ))

  if [[ "$discounted" -lt "$min_price" ]]; then
    echo "$min_price"
  else
    echo "$discounted"
  fi
}
```

## Multi-Function Script Example

```bash
#!/usr/bin/env bash
# @name config_utils
# @brief Configuration management utilities.
# @description
#     This module provides functions for reading and writing
#     key-value configuration files.

# @description Read a value from a configuration file.
# Parses a simple key=value config file and prints the
# value for the given key.
#
# @arg $1 string Path to the configuration file.
# @arg $2 string The key to look up.
#
# @exitcode 0 If successful.
# @exitcode 1 If key is not found.
#
# @stdout The value associated with the key.
#
# @example
#    read_config "/etc/app.conf" "database_host"
#    # Output: localhost
read_config() {
  local file="$1"
  local key="$2"

  if [[ ! -f "$file" ]]; then
    echo "Error: file not found: $file" >&2
    return 1
  fi

  grep -E "^${key}=" "$file" | cut -d'=' -f2- || {
    echo "Error: key not found: $key" >&2
    return 1
  }
}

# @description Write or update a value in a configuration file.
# If the key exists, updates it. If not, appends it.
#
# @arg $1 string Path to the configuration file.
# @arg $2 string The key to set.
# @arg $3 string The value to assign.
#
# @exitcode 0 If successful.
#
# @example
#    write_config "/etc/app.conf" "database_host" "db.example.com"
write_config() {
  local file="$1"
  local key="$2"
  local value="$3"

  if [[ -f "$file" ]] && grep -qE "^${key}=" "$file"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$file"
  else
    echo "${key}=${value}" >> "$file"
  fi
}
```
