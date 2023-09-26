---
title: "Ever-growing syntax"
date: 2023-09-26
tags:
  - misc
---

## Module

1. **Module name**. In Python, the module name is defined by the file name. In Go, module name is specified explicitly in each file and there should be only one module in one directory (which complicates scripting). In Elixir, module is a language construct similar to how you define a class in OOP languages. Rust uses a mixed approach: the module name is the file name and you can explicilty define nested modules inside of it.
1. **Visibility**.
1. **Imports**
    1. **Import path**. The import path usually contains both the library name and the path to a specific module in that library. Go also includes the major version number for the library for version numbers from v2 and higher.
    1. **Alias** or "import all" ("unqualified import").
1. **Types**
1. **Constants**
1. **Global variables**
1. **Documentation**
1. **License notice**. The Apache 2.0 license suggests (or even requires?) to add a license notice in every text file in the project. It's not a documentation and it's not a particularly useful comment. For all languages I know, it gets put into comments. Maybe, it's time to give it its own section? The section might also be used to specify code owners for the file which might be useful for multi-team projects.
1. **Compilation flags**
1. **Metadata**

## Type

1. **Name**
1. **Visibility**
1. **Documentation**
1. **Invariants**
1. **Fields**
    1. Name
    1. Type
    1. Documentation
    1. Descriptors
    1. Metadata

## Function

1. **Name**
1. **Visibility**
1. **Documentation**
1. **Examples**
1. **Tests**
1. **Metadata**
1. **Decorators**
1. **Method receiver**
1. **Markers**
1. **Exceptions**
1. **Type variables**
    1. Name
    1. Constraint
1. **Function variants**
    1. Arguments
        1. Name or pattern
        1. Type
        1. Documentation
        1. Metadata
    1. Guards
    1. Post-conditions.
    1. Body
    1. Documentation
