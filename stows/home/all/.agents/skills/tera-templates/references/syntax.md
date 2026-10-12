# Tera Syntax Reference

Source: <https://keats.github.io/tera/#template>

## Delimiters

Three kinds, changeable via `Tera::set_delimiters`:

- `{{` and `}}` — expressions
- `{%` and `%}` — statements
- `{#` and `#}` — comments

## Literals

- booleans: `true`/`True`, `false`/`False`
- integers
- floats
- strings: delimited by `""`, `''`, or `` `` ``
- arrays: comma-separated list surrounded by `[ ]` (trailing comma allowed)
- maps: key/value literal inside `{ }` like `{"a": 1, "b": 2}` (trailing comma allowed)
- `none` / `None` (and `null` as a reserved name)

`none` is different from undefined: the value exists and is `none`. Undefined means it
does not exist.

## Variables

Context-provided values render with `{{ name }}`. Rendering an undefined variable errors.

- `__tera_context` — magical variable that prints the current context.
- Assign your own with `{% set %}` (see control-and-blocks.md).

### Valid names

`[a-zA-Z_][a-zA-Z0-9_]*` — start with ASCII letter or `_`, then letters/digits/`_`.
Same restrictions apply to block/component names.

Reserved names (cannot be variables): `true`, `True`, `false`, `False`, `loop`, `self`,
`and`, `or`, `not`, `is`, `in`, `continue`, `break`, `none`, `None`, `null`.

If a key is not a valid identifier, use square brackets: `{{ product["some-key"] }}`.

### Dot notation

`{{ product.name }}`. Array/tuple members via zero-based `.i`: `{{ tuple.0 }}`.
A variable cannot follow a dot.

### Square bracket notation

`{{ product['name'] }}` or `{{ product["name"] }}`. Unquoted values are treated as
variables: given `my_field = "name"`, `{{ product[my_field] }}` resolves to `{{ product.name }}`.
Only strings or integer indices are allowed as index; anything else errors.

### Optional chaining

One level of undefined-ness, short-circuiting on null/undefined:

```
{{ a?.b?.c or "should print" }}
```

Optional array access uses `?[` (different from JS `?.[`):

```
{{ a?['b']?.c or "should print" }}
```

## Expressions

Expressions are allowed everywhere.

### Math

Only on numbers; other types error. Operators: `+`, `-`, `/`, `*`, `%`.
(`//` integer division and `**` power appear in the precedence table.)

### Comparisons

`==`, `!=`, `>=`, `<=`, `>`, `<`

### Logic

`and`, `or`, `not`

### String concatenation

`~` joins strings/numbers/idents; output is always a string.

```
{{ "hello " ~ 'world' ~ `!` }}
{{ an_ident ~ " and a string" ~ another_ident }}
{{ an_ident ~ another_ident }}
```

### `in` checking

```
{{ some_var in [1, 2, 3] }}
{{ 'index' in page.path }}
{{ an_ident not in an_obj }}
```

Right side must evaluate to an array, string, or map. Left side must evaluate to an
integer, string, or boolean.

### Spread

```
{% set m = {...base, "d": 4} %}
{{ [0, ...numbers, 99] }}
```

### Slicing (Python-style `[start:stop:step]`)

```
{{ numbers[0] }}
{{ numbers[-1] }}
{{ numbers[:-1] }}
{{ numbers[:2] }}
{{ numbers[1:2] }}
{{ numbers[0:2:2] }}
{{ numbers[::-1] }}
{{ product.name[-1] }}
{{ product.name[::-1] }}
{{ product.name[1:] }}
{{ product.name[:-1] }}
```

`-1` means the last item.

### Ternary

Both `if` and `else` are required:

```
{{ "majeur" if age >= 18 else "mineur" }}
```

### List comprehension

```
{{ [a for a in numbers if a is odd] }}
{{ [x if x > 1 else 0 for x in numbers] }}
{{ [a | str | safe for a in numbers] | safe }}
{{ [(a * 2) + 1 for a in numbers] }}
{{ [v for k, v in data] | safe }}
{{ [x for x in numbers if x > 100] }}
```

Syntactic sugar for a `for` loop; `loop.*` variables are NOT available inside.

### Operator precedence

Lowest to highest binding power; same row = same precedence:

| Operators |
| --- |
| `or` |
| `and` |
| `not` |
| `in`, `not in`, `is`, `is not` |
| `==`, `!=`, `<`, `<=`, `>`, `>=` |
| `+`, `-` |
| `*`, `/`, `//`, `%`, `~` |
| `**` |
| `\|` (filter) |
| `-` (unary) |
| `.`, `[]`, `()` |
