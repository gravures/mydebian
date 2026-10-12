# Tera Built-in Filters

Source: <https://keats.github.io/tera/#built-in-filters>

Filters transform a value: `{{ value | filter(arg=...) }}`. They chain left-to-right:
`{{ name | lower | replace(from="doctor", to="Dr.") }}` is `replace(lower(name), ...)`.

Filter sections apply to a body:

```
{% filter my_filter(param="value") %}
some content {{ var }}
{% endfilter %}
```

## Strings

| Filter | Description / example |
|--------|----------------------|
| `lower` | Lowercase. `{{ name \| lower }}` |
| `upper` | Uppercase. |
| `wordcount` | Number of words in a string. |
| `capitalize` | Lowercase all but first char uppercased. |
| `title` | Capitalize each word: `"foo bar"` → `"Foo Bar"`. |
| `replace` | Required `from`/`to`: `{{ name \| replace(from="Robert", to="Bob") }}` |
| `trim` | Trim whitespace; optional `pat`: `{{ value \| trim(pat="\|") }}` |
| `trim_start` | Trim leading whitespace; optional `pat`. |
| `trim_end` | Trim trailing whitespace; optional `pat`. |
| `truncate` | `length`; optional `end` (default ellipsis). Output is never safe. `{{ value \| truncate(length=10) }}`, `truncate(length=10, end="")`. With `unicode` feature, truncates by graphemes. |
| `newlines_to_br` | Replace `\n`/`\r\n` with `<br>`. In autoescaped templates call `safe` after. |
| `indent` | `width` (default 4), `indentation` (default `" "`), `first` (default false), `blank` (default false). |
| `split` | `pat`: `{{ path \| split(pat="/") }}` → array of strings. |
| `str` | String representation of a value. |

## Escaping / safety

| Filter | Description |
|--------|-------------|
| `safe` | Mark content as safe (not escaped). Safety is preserved through safety-aware filters (`replace`, `trim`, `upper`, ...) but dropped by the rest (e.g. `truncate`). |
| `escape` | Escape using current escape function; already-safe input is not re-escaped. |
| `escape_html` | `&`→`&amp;`, `<`→`&lt;`, `>`→`&gt;`, `"`→`&quot;`, `'`→`&#x27;`. |
| `escape_xml` | `&`→`&amp;`, `<`→`&lt;`, `>`→`&gt;`, `"`→`&quot;`, `'`→`&apos;`. |

## Arrays

| Filter | Description / example |
|--------|----------------------|
| `first` | First element; `None` if empty. |
| `last` | Last element; `None` if empty. |
| `nth` | `n` (0-based): `{{ value \| nth(n=2) }}` |
| `join` | `sep`: `{{ value \| join(sep=" // ") }}` |
| `length` | Length of array, object, or string. |
| `reverse` | Reversed string or array. |
| `sort` | Ascending. Numbers by value, strings alphabetical, arrays by length, bools as 0/1. For structs/tuples use `attribute`: `sort(attribute="name.1")`, `sort(attribute="age")`. |
| `unique` | Remove duplicates. |
| `group_by` | Required `attribute`. Returns map of stringified key → list of items. Missing/null attributes discarded. `posts \| group_by(attribute="year")`, `group_by(attribute="author.name")`. |

## Numbers

| Filter | Description |
|--------|-------------|
| `abs` | Absolute value. |
| `round` | `method` (`ceil`/`floor`, default nearest), `precision` (default 0). `{{ num \| round(method="ceil", precision=2) }}` |
| `int` | To integer; optional `base` (2/8/16 understand `0b`/`0o`/`0x` prefixes). |
| `float` | To float. |
| `pluralize` | Plural suffix if value ≠ 1. `singular`/`plural` args. `message{{ n \| pluralize }}`, `categor{{ n \| pluralize(singular="y", plural="ies") }}` |

## Maps / objects

| Filter | Description |
|--------|-------------|
| `keys` | Array of keys. |
| `values` | Array of values. |
| `pairs` | Array of `[key, value]` pairs. Sort afterwards with `sort`. |
| `get` | Access a non-identifier key: `{{ sections \| get(key="posts/content") }}`. Optional `default`: `get(key="posts/content", default="default")`. |

## Defaults

`default` returns the fallback only when the variable is **not present** in the context
(not when it is falsy). Put it at the start of a chain.

```
{{ value | default(value=1) }}
{{ "" | default(value="Louise Michel") }}              {# → "" #}
{{ "" | default(value="Louise Michel", boolean=true) }} {# → "Louise Michel" #}
```

## Notes

- Missing arguments and type mismatches in filters error automatically.
- Filter parameters can be positional or named; named (`from=`, `length=`, `sep=`) is the
  common style in the docs.
