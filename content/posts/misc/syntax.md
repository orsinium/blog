---
title: "Ever-growing syntax"
date: 2023-09-29
tags:
  - languages
  - misc
---

Case and point: the syntax of module-level definitions (types, function, and module itself) grows out of control. The blog post describes the components that major programming languages allow you to specify for modules and symbols defined in them.

The goal is to have a convenient cheat sheet for people starting their own programming language. Look at the list, mark what components you want to see in your programming language, and make decision how you're going to fit it all.

## Module

1. **Module name**. In Python, the module name is defined by the file name. In Go, module name is specified explicitly in each file and there should be only one module in one directory (which complicates scripting). In Elixir, module is a language construct similar to how you define a class in OOP languages. Rust uses a mixed approach: the module name is the file name and you can explicilty define nested modules inside of it.
1. **Visibility**. In theory, it's enough to only be able to mark specific symbols as public or private. On practice, it's very convenient being able to do so for the whole module at once. Rust treats modules as language constructs and allows you to set the same powerful visibility rules as for any type or function. Go doesn't have visibility rules for packages but if you name a module "internal", everything inside it (including nested modules) will be visible only from the same project.
1. **Imports**
    1. **Import path**. The import path usually contains both the library name and the path to a specific module in that library. Go also includes the major version number for the library for version numbers from v2 and higher.
    1. **Imported symbols**. Most of languages allow to import only specific unqualified names. Go doesn't have it and people don't complain, so maybe it's not necessary.
    1. **"import all" flag**. I personally don't use "import all" that often (it's very convenient for unit tests in Rust, though) but maybe it's only fair to let users to write their own "prelude" packages and not keep the privilege only for the stdlib.
    1. **Alias**. Name conflicts are common (both with other packages and with local names), so it should be possible to rename imported modules and symbols.
1. **Types**
1. **Constants**
1. **Global variables**
1. **Documentation**
1. **License notice**. The [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) license [suggests](https://www.apache.org/licenses/LICENSE-2.0#apply) (or even requires?) to add a license notice in every text file in the project. It's not a documentation and it's not a particularly useful comment. For all languages I know, it gets put into comments. Maybe, it's time to give it its own section? The section might also be used to specify code owners for the file which might be useful for multi-team projects.
1. **Compilation flags**
1. **Metadata**

## Type

1. **Name**
1. **Visibility**
1. **Documentation**
1. **Invariants**
1. **Fields**
    1. **Name**.
    1. **Type**.
    1. **Default value**.
    1. **Documentation**.
    1. **Descriptors**. You might want to allow specifying custom logic or values for accessing type (not instance) fields. That's especially usefult for ORMs. For example, descriptors let you make a DSL to construct SQL queries like in [LINQ](https://en.wikipedia.org/wiki/Language_Integrated_Query): `name = select(User.name).from(User).exec()`. Python has descriptors, and almost all ORMs and validation libraries use them for specifying fields.
    1. **Metadata**. Even if you don't add descriptors, it should be possible to specify arbitrary metadata. For example, Go [json](https://pkg.go.dev/encoding/json) library uses it to know how to map JSON field names to the struct fields. Or Rust [clap](https://docs.rs/clap/latest/clap/) library uses field metadata a lot to know how CLI flags are supported, how they are mapped to struct fields, to provide help text for flags, and everything else you'd need to make powerful CLI.

## Function

1. **Name**
1. **Visibility**
1. **Documentation**
1. **Examples**. Most languages (like Python, Elixir, Rust) tell you to put code examples right into the function docs following a special syntax (usually, mimicing REPL output) and then provide tools to parse, run, and check such examples. The problem, however, is that almost always such examples don't get the same IDE assistance as regular code: no autocomplete, no syntax highlighting, no code formatting, no linting. Go does it a bit better and allows you to define "testable examples" which are almost like regular tests but included in the documentation. However, you won't see them in your IDE tooltips or when you "go to definition". I think we need to give a special treatment to examples and take the best of two worlds: get them out of docstrings like in Go but keep them next to the code like in Rust.
1. **Tests**. If a function is pure, it's easy to write unit tests for it. And I believe that such tests should live next to the function. That's why it's a common practice in Rust to place tests right into the module where the tested code is defined.
1. **Metadata**
1. **Decorators**
1. **Method receiver**
1. **Exceptions**. Do you know what errors your function may raise (or return, if your language is functional)? Rust allows you to specify specific types of errors, but on practice people don't want to bother and take [anyhow](https://docs.rs/anyhow/latest/anyhow/) which makes all errors to be of the same type. Still, I believe that the language should allow users to specify what errors a function can raise and then a special type checker should check that the erros are handled correctly. This specification mught be optional for people who just want to "ship it" but that might be very helpful for library designers, both for API safety and documentation purposes. There is nothing like this in Python (except third-party solutions like [deal](https://deal.readthedocs.io/basic/exceptions.html)) and that often leads to unexpected exceptions occuring in unexpected places. Even "no exception" languages like Go or Rust might panic unexpectedly.
1. **Markers**. If we track exceptions and how they are propagated, why don't let users specify their own markers? For example, we can say that a function uses IO and then recursively mark all function calling that one as using IO as well. Similar to the IO monad in Haskell, except not that tedious and without any effect on the runtime.
1. **Type variables**
    1. Name
    1. Constraint
1. **Function variants**. Some languages, like Erlang, Elixir, and Julia, allow function-overload (multiple dispatch), either based on argument type or on arbitrary argument conditions. In such languages, a function with one name might have multiple bodies and even signatures.
    1. Arguments
        1. Name or pattern
        1. Type
        1. Documentation
        1. Metadata
    1. Guards
    1. Post-conditions.
    1. Body
    1. Documentation

## Better syntax

Perhaps, we should stop trying to invent it's own place and syntax for each of these components. Maybe, we should learn from LISP and treat it all the same. Make a hierarchical structure and let everything to be defined in it. For example, here is YAML-based module definition:

```yaml
name: main
funcs:
  add:
    doc: Add together two positive integers.
    examples:
      - add(3, 4) == 7
    args:
      left:  {type: int}
      right: {type: int}
    returns: {type: int}
    guards:
      - left > 0
      - right > 0
    decorators:
      - lru_cache
    body: |
      return left + right
```

To compare, the same in Python:

```python
@lru_cache
def add(left: int, right: int) -> int:
    """Add together two positive integers.

    Example:

      >>> add(3, 4)
      7
    """
    assert left > 0
    assert right > 0
    return left + right
```

The YAML syntax has several benefits:

1. It's more flexible. You can easily support simple oneline examples as more complex multiline ones with setup, teardown, title, and maybe description.
1. It's extendable. Adding new features to the language is easy and it won't affect in any way the existing code. Simply add new fields to the structure.
1. It's easier for newcomers to answer questions like "what is the return type of this function?"
1. Since everything has a word, newcomers can search answers online much better. It's easier to find answers for "what is decorator in LANGUAGE_NAME" rather than "What is @ in Python".

However, that syntax is much more verbose and without a good IDE assistance is harder to read when you're looking for something specific. But how a "good IDE assistance" might look like?

Some people say that the future belongs to visual programming languages, like [Enso](https://enso.org/) or [Node-RED](https://nodered.org/). Some say to [always bet on text](https://graydon2.dreamwidth.org/193447.html). I say we need to find the balance. And the balance as I see it is to let function bodies stay text but let modules and definitions in them to get a better representation. Let's use tables, graphs, and icons, and then a structured YAML-like representation will be a perfect fit for it, and the readability will get even better than in any other text-only language. Plus, readability is subjecttive, and we should let people to configure the best code representation (tables, lists, graphs, text, or mixed) on the IDE side.
