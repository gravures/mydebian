---
name: python-docstring
description: Python documentation standards. Use when writing docstrings, reviewing existing code, reviewing docstrings or establishing project standards.
---

# Python Code Inlined Documentation

This skill covers standards for documentation inlined in python source file.

## When to Invoke

- Creating project documentation
- Writing or reviewing docstrings
- Implementing new code
- Refactoring existing code
- Reviewing code for style consistency
- Establishing team coding standards

## When NOT to Use

Do NOT use this skill for:

- writing private function, method, or class
- writing tests
- prototyping functionnality

## Core Concepts

- Adhere to the **Google Python Style Guide** for docstrings.
- Avoid Google's `double backticks` usage.
- Follow **Sphinx/reStructuredText** (reST) format for documentation.
- Use **cross-references** to relate functions/classes
- Include **examples** when possible.
- **Tone**: the writing should be clear, concise, and technically precise.
- the **Ruff linter** is configured to produce diagnostics about docstrings.

## Workflow

- [ ] step 1: Analyze the Code, identify what you're documenting (function, method,
      class, or module).
- [ ] step 2: Deconstruct the Signature to identify all parameters, including
      their names, type hints, and default values. Identify the return type hint.
- [ ] step 3: Understand the Logic by examining the code's body to determine its
      core purpose, the algorithm it uses, and its behaviors. Specifically,
      look for any `raise` statements and identify all exceptions that can be raised.
- [ ] step 4: Looks if an existing Docstring is already present then use it to extend
      your understanding of the code and continue with the next step.
- [ ] step 5: Check if dunder method (eg, `__init__`, `__iter__`, `__add__`, ...),
      for this special case jump to step 8 otherwise continue with the next step.
- [ ] step 6: Draft the Docstring (Google Style with Sphinx reST)
- [ ] step 7: Assemble and output the complete docstring, enclosed in triple double-quotes
      (`"""..."""`), into the original code directly below the `def` or `class` line.
- [ ] step 8: Only for dunder methods, those methods are often implementation of a protocol,
      behaviour or a syntactic sugar provided by the python language. You should integrate
      your understanding of such logic as a proper section into the class docstring
      (even when reviewing an existing docstring).
      holding this method and left the method itself with no docstring.
- [ ] step 9: Check your writing with the help of Ruff diagnostics related to docstring.


## Docstring Structure Reference

### 1. One-Line Summary

Write a short, imperative summary of the object's purpose, ending with a period.

### 2. Extended Description

Do not abuse **bullets list**, it's not user friendly and not so readable, makes
proper sections or paragraphs with meaningful sentences. If the logic is complex,
add one or more paragraphs providing more detail on the implementation, use cases,
or important considerations.
Do not assume reader knows about specific topics, be pedagogical and explain how
to use code features with examples if necessary.

### 3. Cross-References

Link to relate classes and functions using Sphinx roles:

- `:class:\`~package.module.ClassName\`` - Link to a class
- `:func:\`module.function_name\`` - Link to a function
- `:meth:\`~Example.method_name\`` - Link to a method
- `:attr:\`attribute_name\`` - Reference an attribute
- The `~` prefix shows only the last component (e.g., `Conv2d` instead of `torch.nn.Conv2d`)

### 4. Notes and Warnings

Use admonitions for important information:

```python
.. note::
    This function doesn't work directly with NLLLoss,
    which expects the Log to be computed between the Softmax and itself.
    Use log_softmax instead (it's faster and has better numerical properties).

.. warning::
    :func:`new_tensor` always copies :attr:`data`. If you have a Tensor
    ``data`` and want to avoid a copy, use :func:`torch.Tensor.requires_grad_`
    or :func:`torch.Tensor.detach`.
```

### 5. Examples Section

Include examples when possible:

```python
Examples::

    >>> inputs = torch.randn(33, 16, 30)
    >>> filters = torch.randn(20, 16, 5)
    >>> F.conv1d(inputs, filters)

    >>> # With square kernels and equal stride
    >>> filters = torch.randn(8, 4, 3, 3)
    >>> inputs = torch.randn(1, 4, 5, 5)
    >>> F.conv2d(inputs, filters, padding=1)
```

**Formatting rules:**

- Use `Examples::` with double colon
- Use `>>>` prompt for Python code
- Include comments with `#` when helpful
- Show actual output when it helps understanding (indent without `>>>`)

### 6. Args Section

For Each Parameter, Write a Newline Following This Format:
  `name (type): Description.`

Use Sphinx roles for types, e.g.:

  - `:obj:\`str\``
  - `:obj:\`int\``
  - `:class:\`~MyClass\``
  - `:obj:\`list\` [ :obj:\`str\` ]`

- For optional parameters, include "Default: ``value``" at the end
- Indent continuation lines by 2 spaces

#### 7 Returns Section

Describe the returned value. The line should start with the type of the returned
object (using Sphinx roles), followed by a colon and a description.
For example: `:obj:\`dict\`: A dictionary containing user profile information.`

#### 8. Raises Section

For each exception identified in step 3, write a new line following the format:
    `:exc:\`ExceptionType\`: A description of when this exception is raised.`.

Use the `:exc:` role and a tilde (`~`) for custom exceptions,
(e.g., `:exc:\`~.errors.CustomError\``).


### 9. External References

Link to papers or external documentation:

```python
.. _Link Name:
    https://arxiv.org/abs/1611.00712
```

Reference them in text: ```See `Link Name`_```

## Examples

**Input:**

```python
from .database import User
from .errors import UserNotFoundError

def fetch_user_profile(user_id: int) -> dict | None:
    user = User.get(id=user_id)
    if not user:
        raise UserNotFoundError(f"User with ID {user_id} not found.")

    if not user.is_active:
        return None

    return {"username": user.name, "email": user.email, "is_active": user.is_active}
```

**Output:**

```python
from .database import User
from .errors import UserNotFoundError

def fetch_user_profile(user_id: int) -> dict | None:
    """Fetch a user's profile from the database.

    Retrieves a user's profile information based on their unique user ID.
    If the user is found but is marked as inactive, this function
    will return ``None``.

    Args:
        user_id (:obj:`int`): The unique identifier for the user.

    Returns:
        :obj:`dict` | ``None``: A dictionary containing the user's profile
        data (`username`, `email`, `is_active`), or ``None`` if the
        user is inactive.

    Raises:
        :exc:`~.errors.UserNotFoundError`: If no user with the given
            `user_id` is found in the database.
    """
    user = User.get(id=user_id)
    if not user:
        raise UserNotFoundError(f"User with ID {user_id} not found.")

    if not user.is_active:
        return None

    return {"username": user.name, "email": user.email, "is_active": user.is_active}
```
