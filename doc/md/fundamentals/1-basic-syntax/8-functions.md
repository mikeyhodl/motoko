---
sidebar_position: 8
hide_table_of_contents: true
---

# Functions

Functions in Motoko can have various attributes, the most fundamental being whether they are public or private. Public functions can be called by users or other [canisters](https://internetcomputer.org/docs/building-apps/essentials/canisters), while private functions are only accessible within the program that defines them.

The most basic Motoko [function declaration](https://internetcomputer.org/docs/motoko/fundamentals/declarations/function-declarations) is:

```motoko no-repl
func exampleFunction() : () {};
```

In objects, modules, and actors, all functions are private by default unless explicitly declared as `public`.

```motoko
object Counter  {
   var value = 0;
   func reset() { value := 0 };
   public func inc() { value := 1};
   public func get() : Nat { value }; 
}
```

The object `Counter` has two public methods, the functions `Counter.inc()` and `Counter.get()`. Both `value` and `reset()` are implicitly `private`. Any attempts to access `Counter.reset()` and `Counter.value` produce type errors.

A function should specify a return type. If a return type is not declared or otherwise determined from the context, it defaults to the unit `()` return type.

```motoko no-repl
func exampleFunction(x : Nat) : Nat {
    x;
};
```

:::info Understanding function types

Motoko functions vary by access and behavior:

The public functions of an actor are a special kind of function called shared functions. These functions can only be declared within actors and, unlike ordinary functions, their values can be sent to (i.e., shared with) other actors.
Shared functions come in several forms:

- `shared` functions, which can modify an actor's state.

- `shared query` functions, which can read the actor's state without making observable changes and cannot send further messages.

- `shared composite query` functions, which behave like queries but can also call other queries.
All shared function, unlike ordinary functions, provide access to the identity of their caller, for applications like access control.

[Learn more about function types](https://internetcomputer.org/docs/motoko/fundamentals/types/functions).

:::

For example, you can rewrite the object above as an actor:

``` motoko
persistent actor Digit {
   var value = 0;
   func reset() { value := 0 };
   public shared func inc() : async (){
      value += 1;
      if (value == 10) reset();
   };
   public shared query func get() : async Nat {
      value
   };
}
```

Since the public functions of an actor must be `shared`, you can omit the `shared` keyword:

``` motoko
persistent actor Digit {
   var value = 0;
   func reset() { value := 0 };
   public func inc() : async () {
      value += 1;
      if (value == 10) reset();
   };
   public query func get() : async Nat {
      value
   };
}
```

<img src="https://cdn-assets-eu.frontify.com/s3/frontify-enterprise-files-eu/eyJwYXRoIjoiZGZpbml0eVwvYWNjb3VudHNcLzAxXC80MDAwMzA0XC9wcm9qZWN0c1wvNFwvYXNzZXRzXC8zOFwvMTc2XC9jZGYwZTJlOTEyNDFlYzAzZTQ1YTVhZTc4OGQ0ZDk0MS0xNjA1MjIyMzU4LnBuZyJ9:dfinity:9Q2_9PEsbPqdJNAQ08DAwqOenwIo7A8_tCN4PSSWkAM?width=2400" alt="Logo" width="150" height="150" />