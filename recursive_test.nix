let
  recursive = import ./recursive.nix;
  safeMerge = a: b: builtins.tryEval (builtins.toJSON (recursive.merge a b));
in
[
  {
    name = "Test basic merge";
    actual = recursive.merge { foo.bar.a = 1; } { foo.bar.b = 2; };
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
      recursive.merge
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
      (recursive.merge f g) 5;
    expected = {
      foo = 6;
      bar = 7;
    };
  }
  {
    name = "Test overlapping attributes";
    actual =
      recursive.merge
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
    actual =
      safeMerge
        {
          a = 1;
          b = 2;
        }
        {
          b = "b";
          c = 3;
        };
    expected = {
      success = false;
      value = false;
    };
  }
  {
    name = "Test mergeList";
    actual = recursive.mergeList [
      { a = 1; }
      { b = 2; }
    ];
    expected = {
      a = 1;
      b = 2;
    };
  }
  {
    name = "Test mergeImports";
    actual = recursive.mergeImports [
      ./test/a.nix
      ./test/b.nix
    ];
    expected = {
      a = 1;
      b = 2;
    };
  }
]
