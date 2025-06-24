# core/Tuples
Contains modules for working with tuples of different sizes.

Usage example:

```motoko
import { Tuple2; Tuple3 } "mo:core/Tuples";
import Bool "mo:core/Bool";
import Nat "mo:core/Nat";

let swapped = Tuple2.swap((1, "hello"));
assert swapped == ("hello", 1);
let text = Tuple3.toText((1, true, 3), Nat.toText, Bool.toText, Nat.toText);
assert text == "(1, true, 3)";
```

## Module `Tuple2`

``` motoko no-repl
module Tuple2
```


### Function `swap`
``` motoko no-repl
func swap<A, B>() : (B, A)
```

Swaps the elements of a tuple.

```motoko
import { Tuple2 } "mo:core/Tuples";

assert Tuple2.swap((1, "hello")) == ("hello", 1);
```


### Function `toText`
``` motoko no-repl
func toText<A, B>(t : (A, B), toTextA : A -> Text, toTextB : B -> Text) : Text
```

Creates a textual representation of a tuple for debugging purposes.

```motoko
import { Tuple2 } "mo:core/Tuples";

import Nat "mo:core/Nat";
assert Tuple2.toText((1, "hello"), Nat.toText, func (x: Text): Text = x) == "(1, hello)";
```


### Function `equal`
``` motoko no-repl
func equal<A, B>(t1 : (A, B), t2 : (A, B), aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool) : Bool
```

Compares two tuples for equality.

```motoko
import { Tuple2 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
assert Tuple2.equal((1, "hello"), (1, "hello"), Nat.equal, Text.equal);
```


### Function `compare`
``` motoko no-repl
func compare<A, B>(t1 : (A, B), t2 : (A, B), aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order) : Types.Order
```

Compares two tuples lexicographically.

```motoko
import { Tuple2 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
assert Tuple2.compare((1, "hello"), (1, "world"), Nat.compare, Text.compare) == #less;
assert Tuple2.compare((1, "hello"), (2, "hello"), Nat.compare, Text.compare) == #less;
assert Tuple2.compare((1, "hello"), (1, "hello"), Nat.compare, Text.compare) == #equal;
assert Tuple2.compare((2, "hello"), (1, "hello"), Nat.compare, Text.compare) == #greater;
assert Tuple2.compare((1, "world"), (1, "hello"), Nat.compare, Text.compare) == #greater;
```


### Function `makeToText`
``` motoko no-repl
func makeToText<A, B>(toTextA : A -> Text, toTextB : B -> Text) : ((A, B)) -> Text
```

Creates a `toText` function for a tuple given `toText` functions for its elements.
This is useful when you need to reuse the same toText conversion multiple times.

```motoko
import { Tuple2 } "mo:core/Tuples";
import Nat "mo:core/Nat";

let tupleToText = Tuple2.makeToText<Nat, Text>(Nat.toText, func x = x);
assert tupleToText((1, "hello")) == "(1, hello)";
```


### Function `makeEqual`
``` motoko no-repl
func makeEqual<A, B>(aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool) : ((A, B), (A, B)) -> Bool
```

Creates an `equal` function for a tuple given `equal` functions for its elements.
This is useful when you need to reuse the same equality comparison multiple times.

```motoko
import { Tuple2 } "mo:core/Tuples";
import Nat "mo:core/Nat";
import Text "mo:core/Text";

let tupleEqual = Tuple2.makeEqual(Nat.equal, Text.equal);
assert tupleEqual((1, "hello"), (1, "hello"));
```


### Function `makeCompare`
``` motoko no-repl
func makeCompare<A, B>(aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order) : ((A, B), (A, B)) -> Types.Order
```

Creates a `compare` function for a tuple given `compare` functions for its elements.
This is useful when you need to reuse the same comparison multiple times.

```motoko
import { Tuple2 } "mo:core/Tuples";
import Nat "mo:core/Nat";
import Text "mo:core/Text";

let tupleCompare = Tuple2.makeCompare(Nat.compare, Text.compare);
assert tupleCompare((1, "hello"), (1, "world")) == #less;
```

## Module `Tuple3`

``` motoko no-repl
module Tuple3
```


### Function `toText`
``` motoko no-repl
func toText<A, B, C>(t : (A, B, C), toTextA : A -> Text, toTextB : B -> Text, toTextC : C -> Text) : Text
```

Creates a textual representation of a 3-tuple for debugging purposes.

```motoko
import { Tuple3 } "mo:core/Tuples";

import Nat "mo:core/Nat";
assert Tuple3.toText((1, "hello", 2), Nat.toText, func (x: Text): Text = x, Nat.toText) == "(1, hello, 2)";
```


### Function `equal`
``` motoko no-repl
func equal<A, B, C>(t1 : (A, B, C), t2 : (A, B, C), aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool, cEqual : (C, C) -> Bool) : Bool
```

Compares two 3-tuples for equality.

```motoko
import { Tuple3 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
assert Tuple3.equal((1, "hello", 2), (1, "hello", 2), Nat.equal, Text.equal, Nat.equal);
```


### Function `compare`
``` motoko no-repl
func compare<A, B, C>(t1 : (A, B, C), t2 : (A, B, C), aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order, cCompare : (C, C) -> Types.Order) : Types.Order
```

Compares two 3-tuples lexicographically.

```motoko
import { Tuple3 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
assert Tuple3.compare((1, "hello", 2), (1, "world", 1), Nat.compare, Text.compare, Nat.compare) == #less;
assert Tuple3.compare((1, "hello", 2), (2, "hello", 2), Nat.compare, Text.compare, Nat.compare) == #less;
assert Tuple3.compare((1, "hello", 2), (1, "hello", 2), Nat.compare, Text.compare, Nat.compare) == #equal;
assert Tuple3.compare((2, "hello", 2), (1, "hello", 2), Nat.compare, Text.compare, Nat.compare) == #greater;
```


### Function `makeToText`
``` motoko no-repl
func makeToText<A, B, C>(toTextA : A -> Text, toTextB : B -> Text, toTextC : C -> Text) : ((A, B, C)) -> Text
```

Creates a `toText` function for a 3-tuple given `toText` functions for its elements.
This is useful when you need to reuse the same toText conversion multiple times.

```motoko
import { Tuple3 } "mo:core/Tuples";

import Nat "mo:core/Nat";
let toText = Tuple3.makeToText<Nat, Text, Nat>(Nat.toText, func x = x, Nat.toText);
assert toText((1, "hello", 2)) == "(1, hello, 2)";
```


### Function `makeEqual`
``` motoko no-repl
func makeEqual<A, B, C>(aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool, cEqual : (C, C) -> Bool) : ((A, B, C), (A, B, C)) -> Bool
```

Creates an `equal` function for a 3-tuple given `equal` functions for its elements.
This is useful when you need to reuse the same equality comparison multiple times.

```motoko
import { Tuple3 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
let equal = Tuple3.makeEqual(Nat.equal, Text.equal, Nat.equal);
assert equal((1, "hello", 2), (1, "hello", 2));
```


### Function `makeCompare`
``` motoko no-repl
func makeCompare<A, B, C>(aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order, cCompare : (C, C) -> Types.Order) : ((A, B, C), (A, B, C)) -> Types.Order
```

Creates a `compare` function for a 3-tuple given `compare` functions for its elements.
This is useful when you need to reuse the same comparison multiple times.

```motoko
import { Tuple3 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
let compare = Tuple3.makeCompare(Nat.compare, Text.compare, Nat.compare);
assert compare((1, "hello", 2), (1, "world", 1)) == #less;
```

## Module `Tuple4`

``` motoko no-repl
module Tuple4
```


### Function `toText`
``` motoko no-repl
func toText<A, B, C, D>(t : (A, B, C, D), toTextA : A -> Text, toTextB : B -> Text, toTextC : C -> Text, toTextD : D -> Text) : Text
```

Creates a textual representation of a 4-tuple for debugging purposes.

```motoko
import { Tuple4 } "mo:core/Tuples";

import Nat "mo:core/Nat";
assert Tuple4.toText((1, "hello", 2, 3), Nat.toText, func (x: Text): Text = x, Nat.toText, Nat.toText) == "(1, hello, 2, 3)";
```


### Function `equal`
``` motoko no-repl
func equal<A, B, C, D>(t1 : (A, B, C, D), t2 : (A, B, C, D), aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool, cEqual : (C, C) -> Bool, dEqual : (D, D) -> Bool) : Bool
```

Compares two 4-tuples for equality.

```motoko
import { Tuple4 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
assert Tuple4.equal((1, "hello", 2, 3), (1, "hello", 2, 3), Nat.equal, Text.equal, Nat.equal, Nat.equal);
```


### Function `compare`
``` motoko no-repl
func compare<A, B, C, D>(t1 : (A, B, C, D), t2 : (A, B, C, D), aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order, cCompare : (C, C) -> Types.Order, dCompare : (D, D) -> Types.Order) : Types.Order
```

Compares two 4-tuples lexicographically.

```motoko
import { Tuple4 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
assert Tuple4.compare((1, "hello", 2, 3), (1, "world", 1, 3), Nat.compare, Text.compare, Nat.compare, Nat.compare) == #less;
assert Tuple4.compare((1, "hello", 2, 3), (2, "hello", 2, 3), Nat.compare, Text.compare, Nat.compare, Nat.compare) == #less;
assert Tuple4.compare((1, "hello", 2, 3), (1, "hello", 2, 3), Nat.compare, Text.compare, Nat.compare, Nat.compare) == #equal;
assert Tuple4.compare((2, "hello", 2, 3), (1, "hello", 2, 3), Nat.compare, Text.compare, Nat.compare, Nat.compare) == #greater;
```


### Function `makeToText`
``` motoko no-repl
func makeToText<A, B, C, D>(toTextA : A -> Text, toTextB : B -> Text, toTextC : C -> Text, toTextD : D -> Text) : ((A, B, C, D)) -> Text
```

Creates a `toText` function for a 4-tuple given `toText` functions for its elements.
This is useful when you need to reuse the same toText conversion multiple times.

```motoko
import { Tuple4 } "mo:core/Tuples";

import Nat "mo:core/Nat";
let toText = Tuple4.makeToText(Nat.toText, func (x: Text): Text = x, Nat.toText, Nat.toText);
assert toText((1, "hello", 2, 3)) == "(1, hello, 2, 3)";
```


### Function `makeEqual`
``` motoko no-repl
func makeEqual<A, B, C, D>(aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool, cEqual : (C, C) -> Bool, dEqual : (D, D) -> Bool) : ((A, B, C, D), (A, B, C, D)) -> Bool
```

Creates an `equal` function for a 4-tuple given `equal` functions for its elements.
This is useful when you need to reuse the same equality comparison multiple times.

```motoko
import { Tuple4 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
let equal = Tuple4.makeEqual(Nat.equal, Text.equal, Nat.equal, Nat.equal);
assert equal((1, "hello", 2, 3), (1, "hello", 2, 3));
```


### Function `makeCompare`
``` motoko no-repl
func makeCompare<A, B, C, D>(aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order, cCompare : (C, C) -> Types.Order, dCompare : (D, D) -> Types.Order) : ((A, B, C, D), (A, B, C, D)) -> Types.Order
```

Creates a `compare` function for a 4-tuple given `compare` functions for its elements.
This is useful when you need to reuse the same comparison multiple times.

```motoko
import { Tuple4 } "mo:core/Tuples";

import Nat "mo:core/Nat";
import Text "mo:core/Text";
let compare = Tuple4.makeCompare(Nat.compare, Text.compare, Nat.compare, Nat.compare);
assert compare((1, "hello", 2, 3), (1, "world", 1, 3)) == #less;
```
