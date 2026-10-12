# Tera Control Structures and Blocks

Source: <https://keats.github.io/tera/#control-structures>

## If

Python-like. Undefined variables are falsy, so `{% if my_var %}` tests presence.

```
{% if price < 10 or always_show %}
   Price is {{ price }}.
{% elif price > 1000 and not rich %}
   That's expensive!
{% else %}
    N/A
{% endif %}
```

Every `if` ends with `{% endif %}`.

## For

```
{% for product in products %}
  {{loop.index}}. {{product.name}}
{% endfor %}
```

Iterate string characters:

```
{% for letter in name %}
  {% if loop.index % 2 == 0 %}<span style="color:red">{{ letter }}</span>
  {% else %}<span style="color:blue">{{ letter }}</span>{% endif %}
{% endfor %}
```

Loop variables:

- `loop.index` — 1-indexed iteration
- `loop.index0` — 0-indexed
- `loop.first` — first iteration
- `loop.last` — last iteration
- `loop.length` — total items

Every `for` ends with `{% endfor %}`.

Maps/structs (key/value names are arbitrary, separated by a comma):

```
{% for key, value in products %}
  {{key}}. {{value.name}}
{% endfor %}
```

Apply filters to the container:

```
{% for product in products | reverse %}
  {{loop.index}}. {{product.name}}
{% endfor %}
```

Array literals:

```
{% for a in [1,2,3,] %}{{a}}{% endfor %}
```

Empty fallback with `else`:

```
{% for product in products %}
  {{loop.index}}. {{product.name}}
{% else %}
  No products.
{% endfor %}
```

`break` / `continue`:

```
{% for product in products %}
  {% if product.id == target_id %}{% break %}{% endif %}
  {{loop.index}}. {{product.name}}
{% endfor %}

{% for product in products %}
  {% if loop.index is even %}{% continue %}{% endif %}
  {{loop.index}}. {{product.name}}
{% endfor %}
```

## Assignments

```
{% set my_var = "hello" %}
{% set my_var = 1 + 4 %}
{% set my_var = some_var %}
{% set my_var = <my.component /> %}
{% set my_var = global_fn() %}
{% set my_var = [1, true, some_var | round] %}
```

Scoping: assignments in for loops/components are scoped to their context. Assignments
outside those go to the global context. A for-loop assignment is valid only until the end
of the current iteration.

Use `set_global` to write to the global context from a loop (identical to `set` outside a
loop):

```
{% set_global my_var = "hello" %}
```

`set` with a body and filters:

```
{% set hero | upper | trans(lang="fr") %}
Hello {{ world }}
{% endset %}
```

## Include

```
{% include "included.html" %}
```

- Path must be a static string. `{% include "partials/" ~ name ~ ".html" %}` is invalid.
- No custom context can be passed. Use components instead.
- Values `set` inside the included template do not leak to the caller.
- Escaping is determined by the **include site's** filename: including `partial.txt` from a
  `.html` (autoescaped) template escapes the content of `partial.txt`.

## Comments

```
{# A comment #}
```

Anything between `{# #}` is not rendered.

## Raw

Text inside `raw` is emitted literally, without rendering delimiters:

```
{% raw %}
  Hello {{ name }}
{% endraw %}
```

renders `Hello {{ name }}`.

## Whitespace control

Add a dash to strip all adjacent whitespace:

- statements: `{%-` (before) and `-%}` (after)
- expressions: `{{-` and `-}}`
- comments: `{#-` and `-#}`

```
{% set my_var = 2 -%}
{{ my_var }}
```
