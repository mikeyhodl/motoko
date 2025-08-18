import Prim "mo:prim";

actor {
  stable let value: ?{} = ?{};

  public func print() : async () {
    Prim.debugPrint(debug_show (value));
  };
};
