---
sidebar_position: 11
---

# Whitespace

Whitespace characters (spaces, tabs, newlines) are generally ignored in Motoko, but are essential for separating syntax components like keywords and identifiers. Proper use of whitespace enhances code readability.

### Incorrect use of whitespace

```motoko
persistent actor Counter{var x : Nat = 0; public func inc(): async Int{x+1; }};
```

### Proper whitespace usage

```motoko
persistent actor Counter {
  var x : Nat = 0;
  public func inc() : async Int {
    x + 1;
  };
};
```

## Resources

- [Motoko style guide](https://internetcomputer.org/docs/motoko/motoko-style)

<img src="https://cdn-assets-eu.frontify.com/s3/frontify-enterprise-files-eu/eyJwYXRoIjoiZGZpbml0eVwvYWNjb3VudHNcLzAxXC80MDAwMzA0XC9wcm9qZWN0c1wvNFwvYXNzZXRzXC8zOFwvMTc2XC9jZGYwZTJlOTEyNDFlYzAzZTQ1YTVhZTc4OGQ0ZDk0MS0xNjA1MjIyMzU4LnBuZyJ9:dfinity:9Q2_9PEsbPqdJNAQ08DAwqOenwIo7A8_tCN4PSSWkAM?width=2400" alt="Logo" width="150" height="150" />