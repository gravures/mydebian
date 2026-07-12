---
name: testing-property-based
description: >-
  Provides guidance for property-based testing across multiple languages and smart
  contracts. Use when writing tests, reviewing code with serialization/validation/parsing
  patterns, designing features, or when property-based testing would provide stronger
  coverage than example-based tests.
---

# Property-Based Testing Guide

Design and generate property-based tests.

## When to Invoke

**Invoke this skill when you detect:**

- **Pure functions**: (no side effects, deterministic)
- **Validators**: `is_valid`, `validate`, `check_*` (especially with normalizers)
- **Parsers**: URL parsing, config parsing, protocol parsing, string-to-structured-data
- **Serializaters**: `encode`/`decode`, `serialize`/`deserialize`, `toJSON`/`fromJSON`,
  `pack`/`unpack`
- **Normalizers**: `normalize`, `sanitize`, `clean`, `canonicalize`, `format`
- **Data structures**: Custom collections with `add`/`remove`/`get` operations
- **Mathematical/algorithmic**: sorting, ordering, comparators
- **Smart contracts**: Solidity/Vyper contracts, token operations, state invariants,
  access control

## When NOT to Use

Do NOT use this skill for:

- Simple CRUD operations without transformation logic
- One-off scripts or throwaway code
- Code with side effects that cannot be isolated (network calls, database writes)
- Tests where specific example cases are sufficient and edge cases are well-understood
- Integration or end-to-end testing (PBT is best for unit/component testing)
- Prototyping where requirements are fluid
- UI/presentation logic
- User explicitly requests example-based tests only

## Workflow

### Step 1 — Extract Specifications

For each candidate function note:

1. **Inputs** — types, ranges, constraints
2. **Outputs** — types, expected relationships to inputs, exepeced behaviour
3. **Exceptions** — any exceptions the code is expected to raise
   under specific conditions.
4. **State** — mutable state involved, if any
5. **Requirements** — business rules as bullet points
6. **Preconditions** — preconditions or invariants
7. **Existants** — existing example-based tests as hints

### Step 2 — Design Applicable Properties

Design properties in this priority order:

| Property | Formula | When to Use |
|----------|---------|-------------|
| **Invariant** | Output always satisfies a condition | Any transformation |
| **Roundtrip** | `decode(encode(x)) == x` | Parsers, serializers, codecs, conversion pairs |
| **Idempotence** | `f(f(x)) == f(x)` | Normalizers, formatters, sorting |
| **Commutativity** | `f(a, b) == f(b, a)` | Binary/set operations |
| **Associativity** | `f(f(a,b), c) == f(a, f(b,c))` | Combining operations |
| **Identity** | `f(x, identity) == x` | Operations with neutral element |
| **Metamorphism** | Relationship between `f(x)` and `f(transform(x))` | Sort, filter, math operations |
| **Monotonicity** | `x ≤ y → f(x) ≤ f(y)` | Scoring, ranking, pricing |
| **Inverse** | `f(g(x)) == x` | encrypt/decrypt, compress/decompress |
| **Easy to Verify** | `is_sorted(sort(x))` | Complex algorithms |
| **No Exception** | No crash on valid input | Baseline property |
| **Oracle** | `new_impl(x) == reference(x)` | Optimization, refactoring |

Each property MUST include:

- Natural-language description
- Corresponding requirement from Step 1
- One buggy implementation example that this property would catch

### Step 3 — Choose the library

Select the library for current language:

| Language | Library | Import/Setup |
|----------|---------|--------------|
| Python | Hypothesis | `from hypothesis import given, strategies as st` |
| JavaScript/TypeScript | fast-check | `import fc from 'fast-check'` |
| Rust | proptest | `use proptest::prelude::*` |
| Go | rapid | `import "pgregory.net/rapid"` |
| Java | jqwik | `@Property` annotations, `import net.jqwik.api.*` |
| Scala | ScalaCheck | `import org.scalacheck._` |
| C# | FsCheck | `using FsCheck; using FsCheck.Xunit;` |
| Elixir | StreamData | `use ExUnitProperties` |
| Haskell | QuickCheck | `import Test.QuickCheck` |
| Clojure | test.check | `[clojure.test.check :as tc]` |
| Ruby | PropCheck | `require 'prop_check'` |
| Kotlin | Kotest | `io.kotest.property.*` |
| Swift | SwiftCheck | `import SwiftCheck` ⚠️ unmaintained |
| C++ | RapidCheck | `#include <rapidcheck.h>` |

** Smart Contract Testing (EVM/Solidity) **

| Tool | Type | Description |
|------|------|-------------|
| Echidna | Fuzzer | Property-based fuzzer for EVM contracts |
| Medusa | Fuzzer | Next-gen fuzzer with parallel execution |

### Step 4 — Build Generators

Create appropriate generator strategies for each input parameter.

**Principles**:

- Create distinct strategies for different classes of data.
  For example, create one strategy for valid inputs that should succeed
  and another for invalid inputs that should cause specific errors.
- Build constraints INTO the strategy, not via `assume()`
- Use realistic size limits to prevent slow tests
- Match real-world constraints

### Step 5 — Implement Tests

Write test files following project conventions. Each test must include:

1. Descriptive property name
2. Generator definition
3. Test body (arrange/act/assert)
4. Seed output on failure
5. Reproduction instructions (as comment)

**Include Edge Cases** — Always add explicit examples:

```python
@example([])           # Empty
@example([1])          # Single element
@example([1, 1, 1])    # Duplicates
@example("")           # Empty string
@example(0)            # Zero
@example(-1)           # Negative
```

## Step 6 — Report

Output in this order:

1. **Requirements summary** — extracted specifications
2. **Property list** — natural language + requirement mapping + buggy impl example
3. **Generator strategies** — with edge case rationale
4. **Test implementation** — actual test code (not pseudocode)

## Input Strategy Reference

### Python/Hypothesis

| Type | Strategy |
|------|----------|
| `int` | `st.integers()` |
| `float` | `st.floats(allow_nan=False)` |
| `str` | `st.text()` |
| `bytes` | `st.binary()` |
| `bool` | `st.booleans()` |
| `list[T]` | `st.lists(strategy_for_T)` |
| `dict[K, V]` | `st.dictionaries(key_strategy, value_strategy)` |
| `set[T]` | `st.frozensets(strategy_for_T)` |
| `tuple[T, ...]` | `st.tuples(strategy_for_T, ...)` |
| `Optional[T]` | `st.none() \| strategy_for_T` |
| `Union[A, B]` | `st.one_of(strategy_a, strategy_b)` |
| Custom class | `st.builds(ClassName, field1=..., field2=...)` |
| Enum | `st.sampled_from(EnumClass)` |
| Constrained int | `st.integers(min_value=0, max_value=100)` |
| Email | `st.emails()` |
| UUID | `st.uuids()` |
| DateTime | `st.datetimes()` |
| Regex match | `st.from_regex(r"pattern")` |

#### Composite Strategies

Use `st.composite()` for complex types, `st.one_of()` for alternatives,
and `.map()` or `.filter()` to refine strategies.

```python
@st.composite
def valid_users(draw):
    name = draw(st.text(min_size=1, max_size=50))
    age = draw(st.integers(min_value=0, max_value=150))
    email = draw(st.emails())
    return User(name=name, age=age, email=email)
```

### JavaScript/fast-check

| Type | Strategy |
|------|----------|
| number | `fc.integer()` or `fc.float()` |
| string | `fc.string()` |
| boolean | `fc.boolean()` |
| array | `fc.array(itemArb)` |
| object | `fc.record({...})` |
| optional | `fc.option(arb)` |

```typescript
const userArb = fc.record({
  name: fc.string({ minLength: 1, maxLength: 50 }),
  age: fc.integer({ min: 0, max: 150 }),
  email: fc.emailAddress(),
});
```

### Rust/proptest

| Type | Strategy |
|------|----------|
| i32, u64, etc | `any::<i32>()` |
| String | `any::<String>()` or `"[a-z]+"` (regex) |
| Vec<T> | `prop::collection::vec(strategy, size)` |
| Option<T> | `prop::option::of(strategy)` |

```rust
proptest! {
    #[test]
    fn test_roundtrip(s in "[a-z]{1,20}") {
        let encoded = encode(&s);
        let decoded = decode(&encoded)?;
        prop_assert_eq!(s, decoded);
    }
}
```

### Go/rapid

```go
rapid.Check(t, func(t *rapid.T) {
    s := rapid.String().Draw(t, "s")
    n := rapid.IntRange(0, 100).Draw(t, "n")
    // test with s and n
})
```

### Best Practices

1. **Constrain early**: Build constraints into strategy, not `assume()`:

   ```python
   # GOOD
   st.integers(min_value=1, max_value=100)

   # BAD
   st.integers().filter(lambda x: 1 <= x <= 100)
   ```

2. **Size limits**: Use `max_size` to prevent slow tests:

   ```python
   st.lists(st.integers(), max_size=100)
   st.text(max_size=1000)
   ```

3. **Realistic data**: Make strategies match real-world constraints:

   ```python
   # Real user ages, not arbitrary integers
   st.integers(min_value=0, max_value=150)
   ```

4. **Reuse strategies**: Define once, use across tests:

   ```python
   valid_users = st.builds(User, ...)

   @given(valid_users)
   def test_one(user): ...

   @given(valid_users)
   def test_two(user): ...
   ```
