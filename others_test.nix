let
  wrench = import ./wrench.nix;
in
[
  {
    name = "Test apply on list of functions";
    actual = wrench.apply [
      (x: x + 1)
      (x: x * 2)
    ] 3;
    expected = 8;
  }
  {
    name = "Test apply2";
    actual =
      let
        f = a: b: a + b;
      in
      wrench.apply2 f 3 4;
    expected = 7;
  }
  {
    name = "Test over.type";
    actual = wrench.over.type { int = x: x + 1; } 123;
    expected = 124;
  }
  {
    name = "Test over.type fallback";
    actual = wrench.over.type { _fallback = _: "fallback"; } 123;
    expected = "fallback";
  }
  {
    name = "Test over.nonNull";
    actual = wrench.over.nonNull (x: x + 1) 1;
    expected = 2;
  }
  {
    name = "Test over.nonNull keeps null";
    actual = wrench.over.nonNull (x: x + 1) null;
    expected = null;
  }
  {
    name = "Test over.list";
    actual = wrench.over.list (x: x * 2) [
      1
      2
      3
    ];
    expected = [
      2
      4
      6
    ];
  }
  {
    name = "Test over.attrs";
    actual = wrench.over.attrs (x: x * 2) {
      a = 1;
      b = 2;
      c = 3;
    };
    expected = {
      a = 2;
      b = 4;
      c = 6;
    };
  }
  {
    name = "Test over.attrs2";
    actual = wrench.over.attrs2 (k: v: { ${v} = k; }) {
      a = "x";
      b = "y";
      c = "z";
    };
    expected = {
      x = "a";
      y = "b";
      z = "c";
    };
  }
  {
    name = "Test over.function";
    actual = (wrench.over.function (_: x: x * 2) (x: x + 1)) 5;
    expected = 12;
  }
  {
    name = "Test to.list";
    actual = wrench.to.list [
      1
      2
      3
    ];
    expected = [
      1
      2
      3
    ];
  }
  {
    name = "Test to.list on null";
    actual = wrench.to.list null;
    expected = [ ];
  }
  {
    name = "Test to.list on non-list";
    actual = wrench.to.list 5;
    expected = [ 5 ];
  }
  {
    name = "Test to.function on non-function";
    actual = wrench.to.function 5 "ignored";
    expected = 5;
  }
]
