---
name: python-coding
description: >-
    Python code style, linting, formatting, naming conventions.
    Use when writing or reviewing python code, or establishing project standards.
---

# Python Code Style

Consistent code style make codebases maintainable and collaborative.
This skill covers modern Python tooling, naming conventions.

## When to Invoke

- Writing or reviewing python code
- Establishing team coding standards
- Reviewing code for style consistency

## Core Concepts

- 1. Target correct **Python version** for the project
- 2. Automated Formatting: Let tools handle formatting debates, enforce automatically
- 3. Consistent Naming: Follow PEP 8 naming conventions with meaningful,
     descriptive names
- 4. Type Annotations: strict type hints is a requirement
- 5. **KISS - Keep It Simple**: Before adding complexity, ask: does a simpler
     solution work?

## Naming Conventions

Follow PEP 8 with emphasis on clarity over brevity.

**Files and Modules:**

```python
# Good: Descriptive snake_case
user_repository.py
order_processing.py
http_client.py

# Avoid: Abbreviations
usr_repo.py
ord_proc.py
http_cli.py
```

**Classes and Functions:**

```python
# Classes: PascalCase
class UserRepository:
    pass

class HTTPClientFactory:  # Acronyms stay uppercase
    pass

# Functions and variables: snake_case
def get_user_by_email(email: str) -> User | None:
    retry_count = 3
    max_connections = 100
```

**Constants:**

```python
# Module-level constants: SCREAMING_SNAKE_CASE
MAX_RETRY_ATTEMPTS = 3
DEFAULT_TIMEOUT_SECONDS = 30
API_BASE_URL = "https://api.example.com"
```

### Pattern 4: Import statements

Use absolute imports exclusively:

```python
# Preferred
from myproject.utils import retry_decorator

# Avoid relative imports
from ..utils import retry_decorator
```

In general avoid import inside classes, functions or methods, reserve
this practice for specific use cases (eg: lazy loading, platform specific case).
Imports will be grouped by ruff format command in a consistent order.

## Best Practices Summary

1. **Descriptive names** - Clarity over brevity
2. **Absolute imports** - More maintainable than relative
3. **Error Handling**: Use standard Python error handling.
4. **Formatting**: Let ruff auto format code after writing file.
