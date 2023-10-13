---
title: "Math behind types"
date: 2023-09-29
tags:
  - languages
  - misc
---

This blog post is a verey abridged version of how type theory relates to other mathematical models and what basic ideas it draws from them. I'm not a mathematician, so some things can be not precise enough or even outright wrong. So, take it with a grain of salt. However, considering how most of other tutorials on the subject are very complicated for the sake of correctness, I find it important to write down this oversimplified post for dummies.

## Related models

There are a few important math theorems that connect different mathematical models together:

1. [Curry-Howard correspondance](https://en.wikipedia.org/wiki/Curry%E2%80%93Howard_correspondence), according to Wikipedia, is "the direct relationship between computer programs and mathematical proofs". Or, inforamlly, it's a proof that **boolean logic** and **type theory** follow the same rules and so behavior described in one can be described in other.
1. [Curry-Howard-Lambek correspondance](https://wiki.haskell.org/Curry-Howard-Lambek_correspondence) is an extension of Curry-Howard correspondance that says that **type theory** (and so boolean logic as well) can be described using **category theory**. There are not the same, category theory is more flexible can describe much more than just types, but it fully describes type theory. Don't worry if you know nothing about category theory, this blog post will cover it in detail.
1. I know that there is also correspondence between **type theory** and **set theory**. I can't find a good reference to support my claim, so maybe there are not 100% equivalent. [Homotopy type theory](https://en.wikipedia.org/wiki/Homotopy_type_theory) links together category theory and set theory through [univalence axiom](https://en.wikipedia.org/wiki/Univalence_axiom) but that also permits homotopy type theory to be used for, well, anything in math, so that's cheating. I also know that [Elixir will soon have set-theoretic types](https://elixir-lang.org/blog/2022/10/05/my-future-with-elixir-set-theoretic-types/), and that means the Elixir type checker will work with types exactly like with sets. So, there is for sure some strong relation.
1. Boolean logic can be described as "a form of arithmetic that deals solely in ones and zeroes" ([source](https://en.wikibooks.org/wiki/Practical_Electronics/Logic/Boolean_Arithmetic)). That means, there is a strong relation between **boolean logic** and basic **arithmetic**. I can't prove you it's possible to describe the whole arithmetic with category theory but I'm sure there is, again, a strong relation.

To set smart words aside, we know that these mathematical models are strongly related:

* [boolean logic](https://en.wikipedia.org/wiki/Boolean_algebra)
* [arithmetic](https://en.wikipedia.org/wiki/Arithmetic)
* [set theory](https://en.wikipedia.org/wiki/Set_theory)
* [category theory](https://wiki.haskell.org/Category_theory)
* [type theory](https://en.wikipedia.org/wiki/Type_theory)

And if you know how exactly there are related, you can use theorems and relations from any of these to describe and solve type theory problems.

This blog post will focus on basics of category theory and show how each concept is related to the other 4 models.

## Category theory basics

A category is formed by two sorts of things: **objects** and **morphisms** (also called "arrows"). When you visualize a category, objects represented as dots and morphisms are represented as arrows between them. We already can establish some relations to other models and that should help us to form intuition about categories:

* category theory: objects and morphisms
* type theory: types and functions
* boolean logic: ...
* arithmetic: ...
* set theory: sets and set functions

...

## Cheat sheet

A category consists of:

* objects
* morphisms (arrows)
* composition of morphisms: if `g: A -> B` & `f: B -> C` then `f . g: A -> C`

Category laws:

* Associativity: `f . (g . h) = (f . g) . h`
* Every object has identity morphism: `g . id = id . g = g`

Not all arrows are the same:

* Monomorphism: no two elements of A are mapped to the same element in B (injective).
* Epimorphism: for every element in B, there is at least element in A mapped to it (surjective).
* Isomorphism: `g . f = id` & `f . g = id`

There are some special objects:

* Initial object: has exactly one morphism to every object. Void.
* Terminal object: has exactly one morphism from every object. Unit.

More interesting patterns:

* Product (tuple): `p . m = p'` & `q . m = q'`
* Sum (union)

Functor: mapping of all elements from category to another category that preserves the structure: maps all objects and morphisms and has the same composition (`F(g . f) = Fg . Ff`).

## Summary

Here is a summarized mapping between the models:

| cat           | type      | bool  | set             | arith |
| ------------- | --------- | ----- | --------------- | ----- |
| object        | type      |       | set             |   |
| morphism      | function  |       | set function    |   |
| unit type     | null      | true  | one-element set | 1 |
| empty type    | void      | false | empty set       | 0 |
| product type  | tuple     | and   | intersection    | * |
| sum type      | union     | or    | union           | + |
