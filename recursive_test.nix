let
  wrench = import ./wrench.nix;
  strict = x: builtins.deepSeq x x;
  safe = x: builtins.tryEval (strict x);
in
[
  {
    name = "Test basic merge";
    actual = wrench.merge { foo.bar.a = 1; } { foo.bar.b = 2; };
    expected = {
      foo = {
        bar = {
          a = 1;
          b = 2;
        };
      };
    };
  }
  {
    name = "Test list merge";
    actual =
      wrench.merge
        {
          a = [
            1
            2
          ];
        }
        {
          a = [
            3
            4
          ];
        };
    expected = {
      a = [
        1
        2
        3
        4
      ];
    };
  }
  {
    name = "Test function merge";
    actual =
      let
        f = x: { foo = x + 1; };
        g = x: { bar = x + 2; };
      in
      (wrench.merge f g) 5;
    expected = {
      foo = 6;
      bar = 7;
    };
  }
  {
    name = "Test function and attrs merge";
    actual =
      let
        f = x: { foo = x + 1; };
        g = {
          bar = 2;
        };
      in
      (wrench.merge f g) 5;
    expected = {
      foo = 6;
      bar = 2;
    };
  }
  {
    name = "Test overlapping attributes";
    actual =
      wrench.merge
        {
          a = 1;
          b = 2;
        }
        {
          b = 2;
          c = 3;
        };
    expected = {
      a = 1;
      b = 2;
      c = 3;
    };
  }
  {
    name = "Test mismatched attributes";
    actual = safe (
      wrench.merge
        {
          a = 1;
          b = 2;
        }
        {
          b = "b";
          c = 3;
        }
    );
    expected = {
      success = false;
      value = false;
    };
  }
  {
    name = "Test merge with nulls";
    actual = wrench.merge { a = null; } { a = 5; };
    expected = {
      a = 5;
    };
  }
  {
    name = "Test merge with both null";
    actual = wrench.merge { a = null; } { a = null; };
    expected = {
      a = null;
    };
  }
  {
    name = "Test merge identical primitive";
    actual = wrench.merge { a = 10; } { a = 10; };
    expected = {
      a = 10;
    };
  }
  {
    name = "Test merge mismatched primitive types";
    actual = safe (wrench.merge { a = 1; } { a = true; });
    expected = {
      success = false;
      value = false;
    };
  }
  {
    name = "Test merge deep nested attributes";
    actual = wrench.merge { a.b.c = 1; } { a.b.d = 2; };
    expected = {
      a = {
        b = {
          c = 1;
          d = 2;
        };
      };
    };
  }
  {
    name = "Test merge deep conflicting attributes";
    actual = safe (wrench.merge { a.b.c = 1; } { a.b.c = "x"; });
    expected = {
      success = false;
      value = false;
    };
  }
  {
    name = "Test merge list with null";
    actual = wrench.merge {
      a = [
        1
        2
      ];
    } { a = null; };
    expected = {
      a = [
        1
        2
      ];
    };
  }
  {
    name = "Test merge null with list";
    actual = wrench.merge { a = null; } {
      a = [
        3
        4
      ];
    };
    expected = {
      a = [
        3
        4
      ];
    };
  }
  {
    name = "Test merge functions returning matched types";
    actual = (
      (wrench.merge (x: { a = x; }) (_: {
        a = [
          3
          4
        ];
      }))
        [
          1
          2
        ]
    );
    expected = {
      a = [
        1
        2
        3
        4
      ];
    };
  }
  {
    name = "Test merge functions returning mismatched types";
    actual = safe (
      (wrench.merge (x: { a = x; }) (_: {
        a = "string";
      }))
        3
    );
    expected = {
      success = false;
      value = false;
    };
  }
  {
    name = "Test merge.list";
    actual = wrench.merge.list [
      { a = 1; }
      { b = 2; }
    ];
    expected = {
      a = 1;
      b = 2;
    };
  }
  {
    name = "Test merge.attrs";
    actual = wrench.merge.attrs {
      a = [ 1 ];
      b = [ 2 ];
    };
    expected = [
      1
      2
    ];
  }
]
