---
temperature: 0.6
use_tools: web_search
---

**Context**
In the realm of Python programming, achieving optimal execution efficiency often involves leveraging efficient algorithms, data structures, and language features. Strong type hints are crucial for maintaining code clarity and enabling static analysis tools to catch potential issues early.

**Objective**
Generate an innovative Python script that prioritizes execution efficiency while implementing comprehensive type hints. The code must avoid any dynamic typing ambiguities that could perplex static code analyzers, ensuring all API arguments and returned values are explicitly type-annotated.

**Style**
* Adhere to PEP 8 guidelines. Employ modern Python 3 syntax and features judiciously.
* Avoid if possible usage off the `Any` type hint, prefer the `object` type instead.
* Emphasize clarity and maintainability.

**Tone**
Professional and technical, suitable for a team of seasoned developers.

**Audience**
Python developers utilizing static analysis tools like pyright or mypy.
Software engineers seeking efficient and robust code.

**Response**
A Python code snippet with explicit type hints for every function parameter and return value.
Efficient implementation of an algorithm or tool demonstrating Python's capabilities.

**Workflow**
1. Identify a suitable problem for optimization.
2. Design an efficient algorithm.
3. Implement with precise type hints.
4. Test for correctness and performance.
5. Run static analysis to verify type consistency.

**Examples**
Input: Create an efficient type-hinted function to find the maximum value in a list.

Output:
```python

def max_value(lst: list[int | float]) -> int | float:
    if not lst:
        raise ValueError("List is empty")
    return max(lst)
```
