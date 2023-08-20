---
title: "Writing safe to use Go libraries"
date: 2023-06-22
---

The Go standard library is full of bad design choice from the perspective of safety of use. A prime example of that is the blog post [Aiming for correctness with types](https://fasterthanli.me/articles/aiming-for-correctness-with-types#let-s-talk-about-http-headers) by fasterthanlime. It, among other things, compares the Go stdlib [http](https://pkg.go.dev/net/http) package to a third-party Rust [hyper](https://github.com/hyperium/hyper) library. And while some parts that the author covers are due to nature of Go as a language, most of them, I believe, are a bad design of the specific library and can be fixed without rewriting everything to Rust.

I don't think that Go core team isn't smart, quite the opposite. The shortcomings of the stdlib often the result of some features being missed in the language at the time (and because of Go 1 compatibility promise, these workarounds are here to stay forever), some are sacrifices for the sake of simplicity or flexibility.

Today's case study is stdlib [flag](https://pkg.go.dev/flag) and its third-party sibling [pflag](https://github.com/spf13/pflag). I've made quite a few CLI tool using them ([enc](https://github.com/life4/enc) and [sourcemap](https://github.com/orsinium-labs/sourcemap), to name a few), and made quite a few mistakes along the way. And each time I make a mistake, I write a note on it and think how I could prevent it in the future. In this particular case, the outcome of these notes is the [cliff](https://github.com/orsinium-labs/cliff) library and this blog post covering the tricks I used to make this library safe to use.

## Scoping

Here is the first code snippet using flag. Can you spot a bug?

```go
f := flag.NewFlagSet("", flag.ExitOnError)
var addr string
f.StringVar(&addr, "addr", "127.0.0.1:8080", "address to listen on")
http.ListenAndServe(addr, handler)
```

We define flags but we never parse them because `f.Parse` call is missed. And everything compiles just fine and doesn't even crash in runtime because all variables we need are already defined and we can use them. Except that if we try actually passing CLI flags into our tool, it won't have any effect.

The solution is scoping. We need to make sure that flags cannot be defined without parsing them:

```go
err := Parse(func(f *flag.FlagSet) {
    f.StringVar(&addr, "addr", "127.0.0.1:8080", "address to listen on")
})
```

We still can use addr before the flags are even defined, though. And I've seen this happening in some production services defining too many flags in a too complex manner. So, an even better solution is to make sure that none of the variables are available in the scope before flags are parsed:

```go
type Config struct {
    addr  string
}
config, _ := Parse(func(c *Config) flag.Flag {
    f := flag.NewFlagSet("", flag.ExitOnError)
    f.StringVar(&c.addr, "addr", "127.0.0.1:8080", "address to listen on")
    return *f
})
```

Now we know for sure that `config` is always initialized with the correct values. We'll dive in a later section into generics and how to properly implement this.

## Error handling

In the examples above, we've seen code like this:

```go
f := flag.NewFlagSet("", flag.ExitOnError)
// ...
_ = f.Parse()
```

We can ignore the returned error because `flag.ExitOnError` says that `Parse` will never return an error. It either succeeds or exits the whole app.

The problem here is that we have an argument passed in one function that defines how another function works. And these function can be called many lines apart or even in different files. So, when someone changes it in one place, the compiler and [errcheck](https://github.com/kisielk/errcheck) won't tell you anything:

```go
f := flag.NewFlagSet("", flag.ContinueOnError)
// ...
_ = f.Parse()  // may return an error but we ignore it
```

We need to define the behavior in the same place where the behavior occurs. A quick solution is to move the flag:

```go
f := flag.NewFlagSet("")
// ...
err := f.Parse(flag.ContinueOnError)
```

A better solution is to provide two separate methods. One always may return an error, and the other explicitly doesn't return anything:

```go
f := flag.NewFlagSet("")
// ...
// if we want to exit on error:
f.MustParse()
// if we want to handle the error on our side:
err := f.Parse()
```

Now, if we change the behavior, the method signature also changes.

It's a common practice to provide a `Must` method for functions that are used at the entry level or init time of the app. For example, [regexp.Compile](https://pkg.go.dev/regexp#Compile) is complemented by [regexp.MustCompile](https://pkg.go.dev/regexp#MustCompile). However, it may be tedious to maintain, especially if you have lots of such functions. So, generics to the rescue:

```go
func Must[T any](val T, err error) T {
    if err != nil {
        panic(err)
    }
    return val
}
```

And now we can use it like this:

```go
var validID = Must(regexp.Compile(`^[a-z]+\[[0-9]+\]$`))
```

It works because Go has a special hack for unpacking multiple return values into a function that accepts the same number of arguments.

If you don't feel like copy-pasting this helper function into every project, you can use the one defined in [genesis](https://github.com/life4/genesis): [lambdas.Must](https://pkg.go.dev/github.com/life4/genesis/lambdas#Must).

## Maps

Here is another code snippet with a bug:

```go
f.StringVar(&c.host, "host", "127.0.0.1", "")
f.IntVar(&c.port, "host", 8080, "")
```

Do you see it? Both flags are defined as "host". It will fail in runtime, yes, but can we check it at compile-time? We can if we design the API so that the flags are defined as a map where keys are flag values. Then the compiler will know that each flag name must be unique:

```go
f := cliff.Flags{
    "host": cliff.StringVar(&c.host, "127.0.0.1", ""),
    "host": cliff.IntVar(&c.port, 8080, ""), // compile error
}
```

A nice bonus is that all map values will be vertically aligned by the `go fmt`, so it's also easier to read.

One thing to keep in mind here is that now the order of flags is non-deterministic and may change between runs. In case of CLI flags, it may matter when showing a help message. Easy solution is to sort the flags by the name internally. But if you want to preserve the order in which they are defined, you can do the trick that Django ORM used in the times of Python 2: have a global counter and increment it and store its current value on each call to the flag constructor. "host" flag will have counter value 1, "port" will have 2 and so on, in the order as they are defined in the code. And then use this counter to sort the flags.

## Custom types

Can you sport a bug here?

```go
addr := os.Getenv("ADDR")
f.StringVar(&addr, "addr", "address to listen on", addr)
```

We switched the order of arguments. The function expects "target, name, default, usage" but we pass "target, name, usage, default". And since all of them are just strings (except the target which is a pointer), the compiler won't tell us a thing.

The solution is to define custom types:

```go
type Name string
type Usage string

func StringVar(tar *string, name Name, def string, usage Usage)
```

With this signature, the example above will produce a type error because we try to pass a `string` variable where type `Usage` is expected. And since constants and literals in Go are untyped, the correct order will work without any type casting:

```go
f.StringVar(&addr, "addr", addr, "address to listen on")
```

And in rare situations when you do need to pass a dynamic value as a usage string, you can explicitly cast types but then you'd probably see that something is fishy:

```go
// User or reviewer, hopefully, will see that addr is passed as Usage.
f.StringVar(&addr, "addr", "address to listen on", Usage(addr))
```

If you want to be 100% sure users can't mess it up, you can always make these types private. Then it will still work just fine with constants and literals.

An interesting application for this technique is a wrapper for [sql.DB.Exec](https://pkg.go.dev/database/sql#DB.Exec) that makes sure users don't pass untrusted input as an SQL query (unless explicitly marked as Safe):

```go
type safe string
func (*DB) Exec(query Safe, args ...any) (Result, error)
```

## No global state

Here is an interesting bug:

```go
f := flag.NewFlagSet("", flag.ExitOnError)
var addr string
f.StringVar(&addr, "addr", "127.0.0.1:8080", "address to listen on")
_ = flag.Parse()
```

What happens is we called `flag.Parse` instead of `f.Parse`. And that's easy to miss because the names are almost the same. This compiles because the flag package maintains a global FlagSet instance and provides wrapper functions for each of its methods. And that's the API that the documentation suggests using. Why? I don't know! Maybe because `f := flag.NewFlagSet("", flag.ExitOnError)` is too hard to type. What I do know is that it leads to unexpected bugs and makes it very hard to test. Because [global state is evil](https://softwareengineering.stackexchange.com/questions/148108/why-is-global-state-so-evil). The solution is simple: don't use a global state.

```go
f := flag.NewFlagSet("", flag.ExitOnError)
_ = flag.Parse()  // compile error if flag.Parse is simply not defined
```

## Explicit side effects

[SetOutput](https://pkg.go.dev/flag#FlagSet.SetOutput)

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

## Opaque types

...

## Getters

...

## Putting most of it together

I've started this blog post by saying that most of the techniques described here are used in [cliff](https://github.com/orsinium-labs/cliff) to make a safe to use wrapper around flag nad pflag. So, if you are curious, here is how it all plays together:

```go
type Config struct {
  host  string
  port  int
  debug bool
}

// flag initialization is scoped
flags := func(c *Config) cliff.Flags {
  // flags is a map to avoid duplicate names
  return cliff.Flags{
    // Custom types ensure the correct order of arguments.
    // Using functions over maps to ensure all required arguments are passed.
    "host":  cliff.F(&c.host, 0, "127.0.0.1", "host to serve on"),
    "port":  cliff.F(&c.port, 'p', 8080, "port to listen to"),
    "debug": cliff.F(&c.debug, 'd', false, "run in debug mode"),
  }
}

// MustParse is like Parse but handles errors.
// Side-effects are explicit.
config := cliff.MustParse(os.Stderr, os.Exit, os.Args, flags)
fmt.Printf("%#v\n", config)
```
