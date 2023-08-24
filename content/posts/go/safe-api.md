---
title: "Writing safe to use Go libraries"
date: 2023-06-22
---

The Go standard library is full of bad design choices from the perspective of safety of use. A prime example of that is the blog post [Aiming for correctness with types](https://fasterthanli.me/articles/aiming-for-correctness-with-types#let-s-talk-about-http-headers) by fasterthanlime. It, among other things, compares the Go stdlib [http](https://pkg.go.dev/net/http) package to a third-party Rust [hyper](https://github.com/hyperium/hyper) library. And while some parts that the author covers are due to the nature of Go as a language, most of them, I believe, are a bad design of the specific library and can be fixed without rewriting everything to Rust.

I don't think that the Go core team isn't smart, quite the opposite. The shortcomings of the stdlib are often the result of some features being missing in the language at the time (and because of the Go 1 compatibility promise, these workarounds are here to stay forever), and some are sacrifices for the sake of simplicity or flexibility.

Today's case study is stdlib [flag](https://pkg.go.dev/flag) and its third-party sibling [pflag](https://github.com/spf13/pflag). I've made quite a few CLI tools using them ([enc](https://github.com/life4/enc) and [sourcemap](https://github.com/orsinium-labs/sourcemap), to name a few), and made quite a few mistakes along the way. And each time I make a mistake, I write a note on it and think how I could prevent it in the future. In this particular case, the outcome of these notes is the [cliff](https://github.com/orsinium-labs/cliff) library and this blog post covering the tricks I used to make this library safe to use.

## Scoping

Here is the first code snippet using flag. Can you spot a bug?

```go
f := flag.NewFlagSet("", flag.ExitOnError)
var addr string
f.StringVar(&addr, "addr", "127.0.0.1:8080", "address to listen on")
http.ListenAndServe(addr, handler)
```

We define flags but we never parse them because `f.Parse` call is missed. Everything compiles just fine and doesn't even crash in runtime because all variables we need are already defined and we can use them. Except, if we try actually passing CLI flags into our tool, it won't have any effect.

The solution is scoping. We need to make sure that flags cannot be defined without parsing them:

```go
err := Parse(func(f *flag.FlagSet) {
    f.StringVar(&addr, "addr", "127.0.0.1:8080", "address to listen on")
})
```

We still can use addr before the flags are even defined, though. I've seen this happening in some production services defining too many flags in a too complex manner. So, an even better solution is to make sure that none of the variables are available in the scope before flags are parsed:

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
_ = f.Parse(os.Args[1:])
```

We can ignore the returned error because `flag.ExitOnError` says that `Parse` will never return an error. It either succeeds or exits the whole app.

The problem here is that we have an argument passed in one function that defines how another function works. These functions can be called many lines apart or even in different files. So, when someone changes it in one place, the compiler and [errcheck](https://github.com/kisielk/errcheck) won't tell you anything:

```go
f := flag.NewFlagSet("", flag.ContinueOnError)
// ...
_ = f.Parse(os.Args[1:])  // may return an error but we ignore it
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
err := f.Parse(os.Args[1:])
```

Now, if we change the behavior, the method signature also changes.

It's a common practice to provide a `Must` method for functions that are used at the entry-level or init time of the app. For example, [regexp.Compile](https://pkg.go.dev/regexp#Compile) is complemented by [regexp.MustCompile](https://pkg.go.dev/regexp#MustCompile). However, it may be tedious to maintain, especially if you have lots of such functions. So, generics to the rescue:

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

As a side note, `ContinueOnError` is a bad name. If you look at the source code of `Parse`, it parses flags one by one and it returns an error (or panics, or exits, depending on how you configure it) as soon as it encounters an error with a flag. So, it's not "continue on error" but rather "return on error".

There is a lot more to say about safe error handling. If you want to dive deeper into the topic, take a look at my blog post fully dedicated to the topic: [In search of better error handling for Go](https://blog.orsinium.dev/posts/go/monads/).

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

One thing to keep in mind here is that now the order of flags is non-deterministic and may change between runs. In the case of CLI flags, it may matter when showing a help message. The easy solution is to sort the flags by the name internally. But if you want to preserve the order in which they are defined, you can do the trick that Django ORM used in the times of Python 2: have a global counter, increment it, and store its current value on each call to the flag constructor. "host" flag will have counter value 1, "port" will have 2 and so on, in the order as they are defined in the code. Then use this counter to sort the flags.

## Custom types

Can you spot a bug here?

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

Now that we avoid using global variables from flag, can we test it? Well, not yet. By default, the `Parse` method will write warnings, errors, and usage into `sys.Stderr`. And if you use `ExitOnError`, it will also call `os.Exit`. There is no monkey-patching in Go, so you have to make your entry point accept all targets for side effects explicitly.

First, let's deal with `os.Exit`. We can say to flag (by setting `ContinueOnError`) to return the error instead of exiting if something goes wrong or help is requested by the user. However, then we need to convert the error into an exit code ourselves:

```go
if err == ErrHelp {
  return 0, err
}
return 2, err
```

Fact: if an error occurs, flag will print the into the specified output regardless of what behavior on error you specified. But pflag will print the error only if `ExitOnError` is specified. So, despite pflag being a "drop-in replacement for flag", you'll need to add `fmt.Fprintln` or similar in the snippet above before the last return when using pflag.

Perhaps, that's a lot to ask from the user. Any line of code you ask them to write themselves means more room for potential errors. The solution is to make a function that can handle errors, and make it possible to override the `os.Exit` callback for that function:

```go
err := flag.Parse(os.Args[1:])
flag.HandleError(err, os.Exit)
// (or a different callback in tests)
```

Another question is how to redefine `os.Stderr`. The FLagSet provide a [SetOutput](https://pkg.go.dev/flag#FlagSet.SetOutput) method for that. Bonus fact: pflag ignores the output you set here if you specify `ExitOnError` and always writes the error into `os.Stdout`.

I think the problem with `SetOutput` is that it's hiddent somewhere deep in the docs. It's not mantioned in the package documentation and it's not apparent from the package APi that it's here. Plus, you can't expect your users to read the documentation beyond the first code example. And lastly, if you read code that doesn't use it, it's not obvious for you, as a code reviewer, that there is a side-effect.

The solution is to make all side effects explicit. It's a bit more code but everyone knows that side-effects are there and how to redefine them in tests:

```go
cliff.MustParse(os.Stderr, os.Exit, os.Args, flags)
```

## Value vs pointer receivers

It is a valuable information for the caller code if the called method or function can have side-effects and not only return a result but also modify some values. However, there is no notion if mutability in Go, only pointers and values. If it's a pointer it can be modified, if it's a value, it can't. Because of that, I prefer to define methods on value receivers rather than pointer receivers:

```go
// Not good. We don't know if calling the method will modify the Flag or not.
func (f *Flag) Validate() error

// Better. We can be sure that the Flag is the same before and after calling Validate.
func (f Flag) Validate() error
```

And more importantly, constructor methods should be explicit that they don't modify the original value:

```go
// Bad. Modifies the Flag in place, cannot be chained with other methods
// and may cause nasty bugs for the users.
func (f *Flag) WithName(name string)

// Bad. May modify the flag in place or may not, we can't be sure.
func (f *Flag) WithName(name string) *Flag

// Better. We know for sure the original Flag is untouched.
func (f Flag) WithName(name string) Flag
```

However, using value receivers may negatively affect performance (which you shouldn't optimize before you prove it's actually a bottleneck) and even cause bugs (which you should worry about). So, be careful with that. See the blog post [Should methods be declared on `T` or `*T`](https://dave.cheney.net/2016/03/19/should-methods-be-declared-on-t-or-t) by Dave Cheney.

## Limiting available methods

And now something completely different. Let's take the following code that has a bug in how it uses [context](https://pkg.go.dev/context) for cancelation:

```go
func supervisor() {
  ctx := context.Background()
  for i := 0; i < 10; i++ {
    actor(ctx, i)
  }
  // wait for some event to occur
  ctx.Cancel()
}

func actor(ctx context.Context, i int) {
  subtask(ctx, i)
  // wait for some event to occur
  // ...
  ctx.Cancel()
}

func subtask(ctx context.Context, i int)
```

What happens is the supervisor starts multiple actors with the same context so that it can cancel it when it needs to. The problem is that each actor also starts a subtask and uses the same context for it. That means, when any of the actors cancels its subtask, it also implicitly cancels all other actors because they all share the same context.

To prevent the issue, the [Context](https://pkg.go.dev/context#Context) interface doesn't have a `Cancel` method. Instead, you can create a new context using [WithCancel](https://pkg.go.dev/context#WithCancel), and it will return you a callback for cancelation. It allows you to make sure that the context can be canceled only from the same scope where it is created:

```go
subctx, cancel := context.WithCancel(ctx)
for i := 0; i < 10; i++ {
  go f2(subctx, i)
}
// when you want to cancel subctx, just call cancel
cancel()
```

Another possible solution would be to make `WithContext` return a private type that has the `Cancel` method but don't include this method into the `Context` interface so that it cannot be canceled from child functions:

```go
// WithCancel now returns a private type context
func WithCancel(c Context) context

// context is a private type that satisfies the public Context interface
var _ Context = context{}

// context can be canceled but not Context
func (c *context) Cancel()
```

And that's how you can use it:

```go
subctx := context.WithCancel(ctx)
for i := 0; i < 10; i++ {
  go f2(subctx, i)
}
subctx.Cancel()
```

I'd prefer this solution because modifying an object through its method seems more intuitive to me than codifying it through a separate callback returned by its constructor. However, using this API would be more difficult in certain scenarios becuase the context package also has a few other constructors (or better say, wrappers): [WithDeadline](https://pkg.go.dev/context#WithDeadline) and [WithTimeout](https://pkg.go.dev/context#WithTimeout). So, in the following code you loose access to the `Cancel` method:

```go
ctx = context.WithCancel(ctx)
ctx = context.WithDeadline(ctx)

// Type error because whatever WithDeadline returns
// doesn't have Cancel method:
ctx.Cancel()
```

## Generics

Generics are great for writing clean and safe packages. The main application for it is to establish relation between variables used by different methods or parameters of the same function. For example, here is a type safe version of [sync.Pool](https://pkg.go.dev/sync#Pool):

```go
type Pool[T any] struct {
  New func() *T
}
func (p *Pool[T]) Get() *T
func (p *Pool[T]) Put(x *T)
```

Or we can simplify our package API. So, instead of a bunch of methods doing the same thing but for different types like [StringToIntVarP](https://pkg.go.dev/github.com/spf13/pflag#StringToIntVarP) we can simply provide a single generic function:

```go
// before, only for one type
func StringToIntVarP(p *map[string]int, name, shorthand string, value map[string]int, usage string)

// after, for all types
func VarP[T any](p *T, name, shorthand string, value T, usage string)
```

## Generic write target

While in most of the other languages generics are used only to establish relations between types, there is an interesting case in Go where using a generic variable only once makes sense. Can you spot a bug in the code below?

```go
type c Config
err := json.Unmarshal(someData, c)
```

The Unmarshal method must accept a pointer to the target as the second argument, not a value. And since the its type is `any`, type checker won't say anything. While [go vet](https://pkg.go.dev/cmd/vet) can catch this bug for JSON, it won't say anything for YAML, TOML, XML, and countless other third-party serialization libraries.

So, what to do? You can't annotate it as `*any` because [pointer to interface is not interface](https://stackoverflow.com/a/44372954). The solutions is generics:

```go
func Unmarshal[T any](data []byte, v *T) error
```

## Constraints for generics

One detail we glossed over above is that flag and pflag don't support arbitrary types as flags, only specific ones. We lost this information in our generic implementation. The solution is to replace the type constraint `any` by a more specific one. And the great news is that Go supports union types for generic constraints:

```go
type Constraint interface {
  bool | float32 | float64 | int // | ...
}

func VarP[T Constraint](p *T, name, shorthand string, value T, usage string)
```

Now if the user tries to pass an unsupported type like context.Context, they will get an error from type checker. Probably, you still have to have unsafe hacks inside the function until the [type switch on parametric types](https://github.com/golang/go/issues/45380) proposal is accepted, but I believe that for public libraries API type safety is worth a bit of a mess in the internal implementation.

Generic constraints are especially useful for math libraries to support any numeric types as the input (unlike the stdlib [math](https://pkg.go.dev/math) which only works with float64). For example, the [maths](https://github.com/theriault/maths) package. The numeric generic constraints are available in the [golang.org/x/exp/constraints](https://pkg.go.dev/golang.org/x/exp/constraints) package. Hopefully, one day it will make its way into stdlib. Until then, use that package or simply copy-paste the constraints you need because [a little copying is better than a little dependency](https://go-proverbs.github.io/).

## Generics beyond type safety

Generics can be used to prevent not only type errors that will explode in runtime but also some logical errors. For example, I'm currently working on a type safe SQL query builder for Go, and it uses generics a lot. For example, this is how you can construct a `CREATE TABLE` query:

```go
type Place struct {
  Country string
}
p := Place{}
schema := qb.CreateTable(&p,
  qb.ColumnDef(&p.Country, qb.Text()),
)
```

The magic of generics is how it ensures that the database column type you use is compatible with the struct field in your code associated with the column. Here is how signatures look like:

```go
func Text() ColumnType[string]
func ColumnDef[T any](field *T, ctype ColumnType[T]) columnDef[T]
```

If you make the `Country` field an `int` and leave the column type is `TEXT`, the database driver will still work just fine automatically converting the types to and from string, but that's probably not what you want. And thanks to carefully crafted with generics signatures, this mistake will be reported at compile time.

## Functions over structs

So far we've been using functions to construct flags. However, some libraries take a different approach and use structs instead. For example, [urfave/cli](https://github.com/urfave/cli):

```go
app := &cli.App{
  Flags: []cli.Flag{
    &cli.StringFlag{
      Name:        "lang",
      Value:       "english",
      Usage:       "language for the greeting",
      Destination: &language,
    },
  },
}
```

The big advantage ofthis approach is that it's apparent what is name, waht is default value, and what is usage, while, as we discussed earlier, with a constructor function it's easy to mess up the arguments order. Also, some optional arguments can be easily omitted to have less visual noise.

The big disadvantage, however, is that some arguments (`Name` and, in our case, `Destination`) are required for this to work but with structs can be omitted and type checker won't say a word.

That's why we use a constructor function. However, you'll often have a mix of both: some arguments are required and some are optional. Go doesn't have optional function arguments, and how to work it around is a whole new topic. In short, your options are:

1. Config struct as an argument:

  ```go
  F(&addr, "addr", Config{
    Deprecated: "use --host and --port instead"})
  ```

1. Option functions:

  ```go
  F(&addr, "addr",
    WithDeprecated("use --host and --port instead"))
  ```

1. Method chaining:

  ```go
  F(&addr, "addr").Deprecated("use --host and --port instead")
  ```

The first option is unnecessary verbose when you don't want to change anything in the Config (you wtill have to pass `Config{}`), the seconds is verbose when you do provide some options. So I usually prefer the third option but which one to pick is a matter of taste and specifics of your API.

## Field tags

With flag and pflag, for each flag we need to type its name at least 3 times: as struct field name, as value target, and as flag name. It's not just tedious but also error-prone. We already showed earlier how to avoid duplicate flag names (which still doesn't prevent from typos) but we still can have multiple flags pointing to the same struct field.

A solution for the problem is to avoid code duplication with [reflection](https://pkg.go.dev/reflect). Then the user types the field name and type only once and the rest is magically inferred from this. This is the approach that is used by [clap](https://github.com/clap-rs/clap) in Rust (the most popular Rust CLI library), and by [kong](https://github.com/alecthomas/kong) in Go:

```go
var CLI struct {
  Rm struct {
    Force     bool `help:"Force removal."`
    Recursive bool `help:"Recursively remove files."`

    Paths []string `arg:"" name:"path" help:"Paths to remove." type:"path"`
  } `cmd:"" help:"Remove files."`

  Ls struct {
    Paths []string `arg:"" optional:"" name:"path" help:"Paths to list." type:"path"`
  } `cmd:"" help:"List paths."`
}
```

The problem with this approach is that now everything you put into struct field tags is not type safe, not autocompleted, not documented, and even the syntax is not checked. In other words, it's just along raw string that gets parsed only in runtime. This will get better when and if the [introduce structured tags](https://github.com/golang/go/issues/23637) RFC is accepted. until then, this approach with reflection is only good if you don't rely on struct tags too much.

## Opaque types

You may have a type that you want users to see in the documentation and be able to use in signatures of their functions. So you make this type public. The problem is that now the users can instantiate this type directly, bypassing your carefully crafted constructor. You can prevent this by checking in runtime a value of a private field that you know cannot be default:

```go
type Flag struct {name string}

func NewFlag(name string) (*Flag, error) {
  if name == "" {
    return nil, errors.New("name is required")
  }
  return &Flag{name}, nil
}

func (f Flag) Parse() error {
  if f.name == "" {
    return errors.New("Flag must be constructed using NewFlag")
  }
  // ...
}
```

If there are no private fields or all of them may have the default value, you can add a separate field just for this check:

```go
type Flag struct {
  name     string
  internal bool
}

func NewFlag(name string) (*Flag, error) {
  return &Flag{name: name, internal: true}, nil
}

func (f Flag) Parse() error {
  if !f.internal {
    return errors.New("Flag must be constructed using NewFlag")
  }
  // ...
}
```

## Getters

If a struct has a field that you want users to be able to check but not modify, make it private and provide a getter method:

```go
type Flag struct {name string}

func (f Flag) Name() string {
  return f.name
}
```

## Internal package

Go team takes Go 1 compatibility promise seriously and expects the same from you. I recommend reading their blog post [Backward Compatibility, Go 1.21, and Go 2](https://go.dev/blog/compat) that covers some of the techniques they use to achieve this and you may use too. Your library cannot be considered safe to use if it breaks with every release all projects using it.

I think the best advice for keeping backward compatibility is to make public only what actually needs to be public for the users to be able to use the package and nothing else. Here is some tips how to do that:

1. Run [pkgsite](https://pkg.go.dev/golang.org/x/pkgsite/cmd/pkgsite) locally to check the project documentation and, by extend, what's avaiable to your users.
1. Place in the [internal](https://go.dev/doc/go1.4#internalpackages) package everything that needs to be available in your project to all packages but not to the users.
1. Prefer defining tests in a package with `_test` suffix ([the docs](https://pkg.go.dev/testing) call it "black box" testing) so that you can see and use your package as your users would. That's how you now that the public API is sufficient.

## It's ok to break rules

There are lots of guidelines and guides on writing Go code: [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments), [Go test comments](https://github.com/golang/go/wiki/TestComments), [Practical Go](https://dave.cheney.net/practical-go/presentations/gophercon-singapore-2019.html) by Dave Cheney, this blog post you almost finished reading, and so on. But these are merely recommendations. "[A Foolish Consistency is the Hobgoblin of Little Minds](https://peps.python.org/pep-0008/#a-foolish-consistency-is-the-hobgoblin-of-little-minds)" and you often can make for your project better decisions than any "fits all sizes" general suggestions.

As an example, all built-in and stdlib functions return `(T, bool)` instead of `(T, error)` when there is only one error possible. A few examples:

```go
// false if the channel is closed
val, more := <-ch

// false if the value is not in the map
val, exists := m[key]
```

However, when designing API for [genesis](https://github.com/life4/genesis), I made the decision to return from functions like [slices.Min](https://pkg.go.dev/github.com/life4/genesis/slices#Min) an `error` instead of `bool` if the given slice is empty:

```go
val, err := slices.Min(slice)
```

Checking `if err != nil` is a bit more verbose than just `if !ok` but that gives a few advantages:

1. Users can easily add a bit more verbosity to make it apparent what exactly happened:

    ```go
    if err == slices.ErrEmpty
    ```

1. Most often, users will want to return from their function on failure, and with this API they can use the returned error directly instead of making their own:

    ```go
    return err
    ```

1. It can be combined with [lambdas.Must](https://pkg.go.dev/github.com/life4/genesis/lambdas#Must) when we know that the input slice is never empty:

    ```go
    val := lambdas.Must(slices.Min(slice))
    ```

1. It can be extended to return other errors without breaking the API. You should be careful with it, though, the old code might not properly handle these new potential errors.

While these are all small things, small things do matter when it comes to designing packages for others to use.

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
