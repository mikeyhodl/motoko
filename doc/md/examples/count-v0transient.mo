import Debug "mo:base/Debug";

actor Counter_v0 {
  transient var state : Nat = 0; // explicitly `transient`

  public func increment() : async () {
    state += 1;
    Debug.print(debug_show (state));
  };
};
