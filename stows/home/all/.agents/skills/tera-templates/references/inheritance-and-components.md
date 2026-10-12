# Tera Inheritance and Components

Sources: <https://keats.github.io/tera/#inheritance>, <https://keats.github.io/tera/#components>

## Inheritance

Child templates start with `{% extends "base.html" %}` as the first thing in the file.
The parent defines `{% block name %}…{% endblock name %}` slots; children override them.
Multiple levels are supported (A extends B extends C).

Base template (`base.html`):

```
<!DOCTYPE html>
<html lang="en">
<head>
    {% block head %}
    <link rel="stylesheet" href="style.css" />
    <title>{% block title %}{% endblock title %} - My Webpage</title>
    {% endblock head %}
</head>
<body>
    <div id="content">{% block content %}{% endblock content %}</div>
    <div id="footer">
        {% block footer %}
        &copy; Copyright 2008 by <a href="http://domain.invalid/">you</a>.
        {% endblock footer %}
    </div>
</body>
</html>
```

Child template:

```
{% extends "base.html" %}
{% block title %}Index{% endblock title %}
{% block head %}
    {{ super() }}
    <style type="text/css">
        .important { color: #336699; }
    </style>
{% endblock head %}
{% block content %}
    <h1>Index</h1>
    <p class="important">Welcome to my awesome homepage.</p>
{% endblock content %}
```

- `{{ super() }}` renders the parent block's content at that position.
- Naming the block in `{% endblock name %}` is optional but clarifies.
- Nested blocks are supported and `super()` chains through levels.

## Components

First-class, macro-like reusable markup with a JSX twist. Registered globally — no import.

### Defining

```
{% component button(label, variant = "primary") %}
<button class="btn btn-{{variant}}">{{label}}</button>
{% endcomponent button %}
```

Parameters may have default values (literals only, no expressions) and an optional type
(inferable from a default). Types: `string`, `bool`, `integer`, `float`, `number`
(integer or float), `array`, `map`.

A component is **closed**: passing an undeclared argument errors. Make it open with a
spread operator that collects extra args into a map:

```
{% component button(label: string, variant = "primary", ...rest) %}
<button class="btn btn-{{variant}}">{{label}}</button>
{% endcomponent button %}
```

Components are **hermetic**: they only see declared arguments. Implicit parameters (prefixed
with `@`) reach into the caller context:

```
{% component render_hero(@page) %}
{{page.hero}}
{% endcomponent %}
```

Implicit params may have types and defaults. Resolution order:

1. argument passed directly
2. caller context (and parent callers): loop vars, local assignments, parent component params
3. template render context
4. global context
5. default value

If nothing is found, it errors. Implicit lookup crosses component boundaries.

```
{% component greeting(@lang: string = "en") %}
  {% if lang == "fr" %}Bonjour{% else %}Hello{% endif %}
{% endcomponent greeting %}

{{ <greeting /> }}              {# Hello if lang undefined #}
{% set lang = "fr" %}
{{ <greeting /> }}              {# Bonjour #}
{{ <greeting lang="en" /> }}     {# Hello #}
```

An inner component parameter shadows the outer context:

```
{% component english_greeting(lang = "en") %}
  {{ <greeting /> }}
{% endcomponent english_greeting %}

{% set lang = "fr" %}
{{ <english_greeting /> }}          {# Hello (local lang wins) #}
{{ <english_greeting lang="fr" /> }} {# Bonjour #}
```

Attach metadata (available via Rust API only, not templates):

```
{% component array(greeting: string) {"css": "./array.css"} %}
Hello
{% endcomponent %}
```

### Using

```
{% component ui.button(label: string, variant: string = "primary", ...attrs) %}
    <button class="btn btn-{{variant}}">
      {{label}}{% if attrs.important %}!!{% endif %}
    </button>
{% endcomponent ui.button %}

{% component forms.input(name: string, label: string, required: bool = false) %}
    <label for="{{name}}">{{label}}{% if required %}*{% endif %}</label>
    <input type="text" name="{{name}}" {% if required %}required{% endif %}>
{% endcomponent forms.input %}

{% component ui.forms.widget(title: string) %}
    <div class="widget">
      <h3>{{title}}</h3>
      {{body}}
    </div>
{% endcomponent ui.forms.widget %}
```

```
<div class="page">
  {{<ui.button label="Click me" variant="secondary" {...obj} />}}

  {{<forms.input name="email" label="Email Address" required={true} />}}

  {% <ui.forms.widget title> %}
    <p>This is a widget!</p>
    {{<ui.button label="Sign up" variant="primary"/>}}
  {% </ui.forms.widget> %}
</div>
```

- Self-closing call with kwargs: `{{<forms.input name="email" ... />}}`.
- Non-string values use the `{..}` syntax, like JSX: `required={true}`.
- Spread an object into kwargs: `{...obj}`.
- A variable matching an argument name can be passed by shorthand (`title`).
- Body/slot content is passed automatically as the `body` variable (nestable).
- Namespacing with `.` avoids conflicts (e.g. `ui.button`, `zola.button`).
- Single components can be re-rendered from the `Tera` instance (useful with HTMX).
