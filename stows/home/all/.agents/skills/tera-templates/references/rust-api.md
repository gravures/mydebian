# Tera Rust API

Source: <https://keats.github.io/tera/#api>

## Cargo setup

```toml
tera = "2"
```

By default only pulls `serde`. Optional features:

- `fast` — speed up rendering (can select individual sub-features)
- `glob_fs` — load templates from the filesystem using a glob
- `unicode` — operate on grapheme clusters rather than UTF-8 chars when iterating strings
- `preserve_order` — keep order of insertion for values

The `tera-contrib` crate adds filters/functions/tests that need third-party dependencies.

## Adding templates

Given:

```
templates/
  hello.html
  index.html
  products/
    product.html
    price.html
```

```rust
use tera::Tera;

let mut tera = Tera::default();

// with the `glob_fs` feature enabled
tera.load_from_glob("templates/**/*.html")?;

// or by hand
tera.add_raw_templates(vec![
    ("hello.html", include_str!("templates/hello.html")),
    ("index.html", include_str!("templates/index.html")),
    ("products/product.html", include_str!("templates/products/product.html")),
    ("products/price.html", include_str!("templates/products/price.html")),
])?;
```

With globs, the glob prefix is stripped from template names: `templates/hello.html` →
`hello.html`.

Register custom functions/filters/tests **before** adding templates, otherwise they can't be
resolved during parsing.

## Rendering

Needs a template name and a `tera::Context`.

```rust
use tera::Context;

let mut context = Context::new();
context.insert("age", &24);
context.insert("product", &product);
// if you already have a Value, avoid serialization:
context.insert_value("product2", product_value);

// `context!` macro always serializes
let context = context! {
    age => &24,
    product => &product,
};

tera.render("hello.html", &context)?;
```

Global context, added to every render:

```rust
tera.global_context().insert("name", "John Doe");
```

## Auto-escaping

By default Tera auto-escapes content in files ending with `.html`, `.htm`, and `.xml`,
following OWASP XSS recommendations.

```rust
// escape only files ending with `.php.html`
tera.autoescape_on(vec![".php.html"]);
// disable autoescaping completely
tera.autoescape_on(vec![]);
```

Tera does **not** do contextual auto-escaping (no JS/CSS/HTML-aware escaping).

## Custom filters, tests, and functions

Filters/tests/functions share a signature and take at least:

- `Kwargs` — extract keyword arguments with automatic type handling/errors
- `State` — access the current context

Filters and tests additionally take the value they run on (a `Value` or any convertible
type) as the first parameter.

Simplest filter:

```rust
pub fn upper(val: &str, _: Kwargs, _: &State) -> String {
    val.to_uppercase()
}
```

Wrong types error automatically; return values are converted automatically.

They can be plain functions or implement their trait. `tera-contrib` example:

```rust
#[derive(Debug, Default)]
pub struct Matching {
  cache: RwLock<HashMap<String, Regex>>,
}

impl Test<&str, TeraResult<bool>> for Matching {
  fn call(&self, val: &str, kwargs: Kwargs, _: &State) -> TeraResult<bool> {
    let pat = kwargs.must_get::<&str>("pat")?;
    let regex = get_or_create_regex(&self.cache, pat)?;
    Ok(regex.is_match(val))
  }
}
```

`Kwargs` reports missing arguments and type mismatches for you.
