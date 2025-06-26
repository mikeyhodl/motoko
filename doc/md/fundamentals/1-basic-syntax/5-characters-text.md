---
sidebar_position: 5
---

# Characters & text

## Characters

The `Char` type in Motoko represents a single Unicode character delimited with a single quotation mark (`'`).

```motoko
let letter : Char = 'A';
let symbol : Char = '✮';

// Comparing characters
'I' == 'i' // False
```


:::info [Iter](https://internetcomputer.org/docs/motoko/base/Iter)
An `Iter<T>` is an object that sequentially produces values of specified type `T` until no more values remain.
:::
``` motoko
import Char "mo:base/Char";

func reverse(t: Text) : Text {
  var result = "";
  for (c in t.chars()) {
    result := Char.toText(c) # result
  };
  result;
};

reverse("Motoko");
```

The operator `#` concatenates two `Text` values.

```motoko
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Char "mo:base/Char";

persistent actor Alternator {

  // Turn text into an iterator of Char
  func textToChars(t: Text) : Iter.Iter<Char> {
    t.chars();
  };

  // Alternate capitalization
  public func alternateCaps(t: Text) : async Text {
    let chars = textToChars(t);
    var index = 0;
    // Apply a case function to each char
    let modified = Iter.map<Char, Text>(chars, func(c: Char) : Text {
      let charAsText = Char.toText(c);
      let transformedText =
        if (index % 2 == 0) {
          Text.toUppercase(charAsText)
        } else {
          Text.toLowercase(charAsText)
        };
      index += 1;
      transformedText;
    });

    return Text.join("", modified);
  };
};
```

:::note Conversions

- `Char` can be converted to a single-character `Text` using `Char.toText(c)`.
- `Char` can be converted to its 32-bit Unicode scalar value using `Char.toNat32(c)`.
- A `Char` can be converted from a 32-bit Unicode scalar value using `Char.fromNat32(n)` (the function traps on invalid codes).
:::

## Text

Strings of characters, familiar from other languages, are called **text** in Motoko, and represented using the [`Text`](https://internetcomputer.org/docs/motoko/base/Text) type. A text value is an immutable sequence of Unicode characters delimited with a double quotation mark (`"`).

```motoko
let greeting : Text = "Hello, world!";
```

The `#` operator concatenates two `Text` values:

``` motoko
// Concatenating text

"ICP " # "❤️" # " Motoko" // "ICP ❤️ Motoko"
```

`t.size()` can be used to return the number of characters in the text `t`.

```motoko
"abc".size() == 3
```

`t.chars()` returns an iterator enumerating the characters in `t`. For example:

```motoko
import Char "mo:base/Char";
import Debug "mo:base/Debug";

for (c in "abc".chars()) {
  Debug.print(Char.toText(c));
}
```

Text values can be compared using "==", "<" and all the other relational operators.

## Resources

- [`Char`](https://internetcomputer.org/docs/motoko/base/Char)
- [`Text`](https://internetcomputer.org/docs/motoko/base/Text)
- [`Iter`](https://internetcomputer.org/docs/motoko/base/Iter)

