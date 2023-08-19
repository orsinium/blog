---
title: "Writing safe to use Go libraries"
date: 2023-06-22
---

The Go standard library is full of bad design choice from the perspective of safety of use. A prime example of that is the blog post [Aiming for correctness with types](https://fasterthanli.me/articles/aiming-for-correctness-with-types#let-s-talk-about-http-headers) by fasterthanlime. It, among other things, compares the Go stdlib [http](https://pkg.go.dev/net/http) package to a third-party Rust [hyper](https://github.com/hyperium/hyper) library. And while some parts that the author covers are due to nature of Go as a language, most of them, I believe, are a bad design of the specific library and can be fixed without rewriting everything to Rust.

I don't think that Go core team isn't smart, quite the opposite. The shortcomings of the stdlib often the result of some features being missed in the language at the time (and because of Go 1 compatibility promise, these workarounds are here to stay forever), some are sacrifices for the sake of simplicity or flexibility.

Today's case study is stdlib [flag](https://pkg.go.dev/flag) and its third-party sibling [pflag](https://github.com/spf13/pflag). I've made quite a few CLI tool using them ([enc](https://github.com/life4/enc) and [sourcemap](https://github.com/orsinium-labs/sourcemap), to name a few), and made quite a few mistakes along the way. And each time I make a mistake, I write a note on it and think how I could prevent it in the future. In this particular case, the outcome of these notes is the [cliff](https://github.com/orsinium-labs/cliff) library and this blog post covering the tricks I used to make this library safe to use.

## Scoping

...

```go
// missed parse call
```

...

```go
// cliff example
```

...

## Custom types

```go
// flag example with switched default and help
```

...

```go
// example of safe SQL exec
```

## Limiting available methods

```go
// potential example of context cancellation from child
```

```go
// context.WithCancel example
```

...

```go
// example of potential context with private type
```

## Error handling

...

```go
// flag parse that exits and so ignores the error
```

...

```go
// same code but now it returns an error but still ignores it
```

## Generics

...

## Generic write target

```go
// json.Unmarshal
```

...

```go
// a safe wrapper for json.Unmarshal
```

## Constraints for generics

...

## Functions over structs

...
