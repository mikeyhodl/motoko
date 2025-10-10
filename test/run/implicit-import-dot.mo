//MOC-FLAG --implicit-lib-vals
//MOC-FLAG --package core ../core-stub/src

import Map "mo:core/Map";

// The mo:core/Text import should not be necessary for the implicit Text.compare to be resolved
// Same for Nat and Int

func mainText() {
  let map = Map.empty<Text, Nat>();
  map.add("abc", 3)
};

func mainNat() {
  let map = Map.empty<Nat, Int>();
  map.add(1, 3)
};

func mainInt() {
  let map = Map.empty<Int, Int>();
  map.add(-1, 3)
};

func mainCompareText() {
  let n = "abcxyz";
  ignore n.compare("abc")
};

// We have no disambiguation for context dot
// func mainCompareNat() {
//   let n = 1;
//   ignore n.compare(2)
// };

func mainCompareInt() {
  let n = -1;
  ignore n.compare(-2)
};

mainText();
mainNat();
mainInt();
mainCompareText();
// mainCompareNat();
mainCompareInt();

//SKIP run-low
//SKIP run
//SKIP run-ir
