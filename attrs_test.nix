let
  wrench = import ./wrench.nix;
in
[
  {
    name = "Test attrs.key.get";
    actual = wrench.attrs.key.get "a" {
      a = 1;
      b = 2;
    };
    expected = 1;
  }
  {
    name = "Test attrs.key.get missing key";
    actual = wrench.attrs.key.get "c" {
      a = 1;
      b = 2;
    };
    expected = null;
  }
  {
    name = "Test attrs.key.set";
    actual = wrench.attrs.key.set "a" 3 {
      a = 1;
      b = 2;
    };
    expected = {
      a = 3;
      b = 2;
    };
  }
  {
    name = "Test attrs.key.set missing key";
    actual = wrench.attrs.key.set "c" 3 {
      a = 1;
      b = 2;
    };
    expected = {
      a = 1;
      b = 2;
      c = 3;
    };
  }
  {
    name = "Test attrs.key.remove";
    actual = wrench.attrs.key.remove "a" {
      a = 1;
      b = 2;
    };
    expected = {
      b = 2;
    };
  }
  {
    name = "Test attrs.key.remove missing key";
    actual = wrench.attrs.key.remove "c" {
      a = 1;
      b = 2;
    };
    expected = {
      a = 1;
      b = 2;
    };
  }
  {
    name = "Test attrs.key.over";
    actual = wrench.attrs.key.over "a" (x: x + 1) { a = 1; };
    expected = {
      a = 2;
    };
  }
  {
    name = "Test attrs.key.over missing key";
    actual = wrench.attrs.key.over "b" (x: if x == null then 0 else x + 1) { a = 1; };
    expected = {
      a = 1;
      b = 0;
    };
  }
  {
    name = "Test attrs.key.extract";
    actual = wrench.attrs.key.extract "b" {
      a = 1;
      b = 2;
      c = 3;
    };
    expected = {
      value = 2;
      rest = {
        a = 1;
        c = 3;
      };
    };
  }
  {
    name = "Test attrs.key.singleton";
    actual = wrench.attrs.key.singleton "a" 1;
    expected = {
      a = 1;
    };
  }
  {
    name = "Test attrs.key.fold";
    actual =
      wrench.attrs.key.fold
        {
          b = _: x: { d = x + 2; };
        }
        {
          a = 1;
          b = 2;
          c = 3;
        };
    expected = {
      a = 1;
      c = 3;
      d = 4;
    };
  }
  {
    name = "Test attrs.path.get";
    actual = wrench.attrs.path.get "a.b.c" { a.b.c = 10; };
    expected = 10;
  }
  {
    name = "Test attrs.path.get missing path";
    actual = wrench.attrs.path.get "a.c.b" { a.b.c = 10; };
    expected = null;
  }
  {
    name = "Test attrs.path.set";
    actual = wrench.attrs.path.set "a.b.c" 5 { a.b.c = 1; };
    expected = {
      a.b.c = 5;
    };
  }
  {
    name = "Test attrs.path.set missing path";
    actual = wrench.attrs.path.set "a.b.c" 5 { a.d.c = 1; };
    expected = {
      a.b.c = 5;
      a.d.c = 1;
    };
  }
  {
    name = "Test attrs.path.remove";
    actual = wrench.attrs.path.remove "a.b" {
      a.b.c = 1;
      a.d.c = 2;
    };
    expected = {
      a.d.c = 2;
    };
  }
  {
    name = "Test attrs.path.remove missing path";
    actual = wrench.attrs.path.remove "a.d" {
      a.b = 1;
      a.c = 2;
    };
    expected = {
      a.b = 1;
      a.c = 2;
    };
  }
  {
    name = "Test attrs.path.over";
    actual = wrench.attrs.path.over "a.b" (x: x + 1) { a.b = 10; };
    expected = {
      a = {
        b = 11;
      };
    };
  }
  {
    name = "Test attrs.path.over missing path";
    actual = wrench.attrs.path.over "a.b" (x: if x == null then 0 else x + 1) { a.d = 10; };
    expected = {
      a = {
        b = 0;
        d = 10;
      };
    };
  }
  {
    name = "Test attrs.path.extract";
    actual = wrench.attrs.path.extract "a.b.c" {
      a.b.c = 1;
      a.d.c = 2;
    };
    expected = {
      value = 1;
      rest = {
        a.d.c = 2;
      };
    };
  }
  {
    name = "Test attrs.path.singleton";
    actual = wrench.attrs.path.singleton "a.b.c" 5;
    expected = {
      a = {
        b = {
          c = 5;
        };
      };
    };
  }
  {
    name = "Test attrs.path.fold";
    actual =
      wrench.attrs.path.fold
        {
          "a.b" = _: x: { d = x + 2; };
        }
        {
          a.b = 1;
          a.c = 2;
        };
    expected = {
      a.c = 2;
      d = 3;
    };
  }
]
