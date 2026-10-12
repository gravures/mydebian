# Tera Built-in Tests and Functions

Sources: <https://keats.github.io/tera/#built-in-tests>, <https://keats.github.io/tera/#built-in-functions>

## Tests

Tests check a condition and are used with `is` inside `if`:

```
{% if my_number is odd %}Odd{% endif %}
{% if my_number is not odd %}Even{% endif %}
```

| Test | True when |
|------|-----------|
| `defined` | variable is defined |
| `undefined` | variable is undefined |
| `odd` | value is an odd number |
| `even` | value is an even number |
| `string` | value is a string |
| `number` | value is an integer or float |
| `integer` | value is an integer |
| `float` | value is a float |
| `map` | value is a map |
| `array` | value is an array |
| `bool` | value is a bool |
| `none` | value is `none` |
| `iterable` | value can be iterated (array, map, or string) |
| `starting_with` | string starts with `pat`: `{% if path is starting_with(pat="x/") %}` |
| `ending_with` | string ends with `pat` |
| `containing` | strings: `pat` is a substring; arrays: `pat` is a member; maps: `pat` is a key: `{% if username is containing(pat="xXx") %}` |
| `divisible_by` | expression divisible by `divisor`: `{% if rating is divisible_by(divisor=2) %}` |

Negate any test with `is not`.

## Functions

Functions return a value and are called like `{{ fn(arg=...) }}`. Unlike filters, they are
not piped.

### `range`

Array of integers.

- `end` (mandatory): stop before `end`
- `start` (default `0`)
- `step_by` (default `1`; negative to count down)

```
{% for i in range(end=5) %}{{ i }}{% endfor %}
{% for i in range(start=10, end=0, step_by=-2) %}{{ i }}{% endfor %}
```

### `throw`

Errors rendering with the given message. One string argument: `message`.

```
{{ throw(message="something went wrong") }}
```

Additional built-ins may be provided by the `tera-contrib` crate.
