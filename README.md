# Nix recursive merge

Utility functions to recursively merge values in Nix.

Import with:

```nix
let
recursive = (
  import (
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/StijnRuts/nix-recursive-merge/289afa0337338737c3d61da12eaea3cd2f30bf03/recursive.nix";
      sha256 = "sha256:1a6wlrj21hgwc2gbfcdggyxgvg68vm3i1gvgbxdzqs47phqk3il0";
    }
  )
);
in
recursive.<someFunction>
```

Merge attribute sets:

```nix
recursive.merge { foo.bar.a = 1; } { foo.bar.b = 2; }
# { foo = { bar = { a = 1; b = 2; }; }; }
```

Merge lists:

```nix
recursive.merge { foo = [ 1 2 ]; } { foo = [ 3 4 ]; }
# { foo = [ 1 2 3 4 ]; }
```

Even merge functions:

```nix
recursive.merge { f = x: { foo = x + 1; }; } { f = x: { bar = x + 2; }; }
# { f = x: { foo = x + 1; bar = x + 2; }; }
```

Merge a longer list:

```nix
recursive.mergeList [
  { a = 1; }
  { b = 2; }
  { c = 3; }
]
# { a = 1; b = 2; c = 3; }
```

Or define a list of nix files to import and merge:

```nix
recursive.mergeImports [
  ./a.nix
  ./b.nix
]
```
