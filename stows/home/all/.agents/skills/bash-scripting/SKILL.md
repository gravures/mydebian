---
name: bash-scripting
description: bash scripting code style, linting, formatting, naming conventions. Use when writing new code, reviewing style or establishing project standards.
---

# Bash Scripting Best Practices

This skill provides guidance for writing efficient, robust bash scripts.

## When to Invoke

- Writing or reviewing bash script
- Establishing team coding standards
- Reviewing code for style consistency

## Essential Bash Practices

### 1. Shebang and Executability

- Always use `#!/usr/bin/env bash` for portability
- Ensure scripts have executable permissions (`chmod +x`)

### 2. Variable Handling

- **Scope**: Always use `local` for function variables
- **Naming**: Use lowercase with underscores (`script_dir`, `home`, `delay`)
- **Constants**: Use UPPERCASE for globals (`NAME_MAX_LENGTH`, `SAFE_V_MARGIN`)
- **Validation**: Use parameter expansion for required parameters:

  ```bash
  local name=${1:? missing <name> parameter}
  local default=${2:? missing <name> parameter}
  ```

### Formatting

Let tools handle formatting debates, enforce automatically.

- **Indentation**: Use tabs for shell scripts
- **Quotes**: Always quote variables containing paths or user input
- **Command Substitution**: Use `$(command)` over backticks

## 3. Quoting and Command Substitution

- Always quote variables containing paths or user input
- Use $(command) over backticks for command substitution
- Proper quoting prevents word splitting and glob expansion issues

## 4. String and Integer Comparisons

- Use = for string equality in `[ ]` or `[[ ]]`
- Quote variables in comparisons: `[[ ${show_noteless} = on ]]`
- Use -eq for integer comparisons only

## 5. Lock Files

- Lock Files: Use `mkdir` pattern for atomic lockfiles (portable across systems)

    ```bash
    if ! mkdir /tmp/transient-status.lock 2>/dev/null; then
    exit 0
    fi
  ```

- Always clean up locks: `rmdir /tmp/transient-status.lock`

## 6. Error Handling

- Prefer explicit error checks over set -e for complex logic
- Handle edge cases explicitly with case statements:

   ```bash
   case "$TS_PREFIX" in
   "" | None | none) return 1 ;;
   *) ;;
   esac
   ```

## 7. Processing Space-Separated Lists

Common Pitfall: for key in $VARIABLE; do doesn't handle multiple spaces
or leading/trailing whitespace well.
Better Approach:

## 8. Iterating over Strings

Use native bash behaviors, avoid uncessary call to external process:

```bash
    for word in ${line}`; do
       ...
    done
```

## 9. Test with Assignement

Use compound form when possible, for example with a process returning
a string or an error code, do:

```bash
if my_string=$(process); then
    # do something with my_string
fi
```

## Best Practices Summary

- Keep functions small and focused
- Use built-in bash parameter expansion over external tools (sed, awk) when suitable
- Use early returns for error conditions
- Document complex logic with comments
- Return meaningful exit codes
- Minimize subprocess calls in loops
- Cache expensive operations when possible
- Consider whether tmux operations can be batched
