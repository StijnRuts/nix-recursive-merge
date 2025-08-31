rec {
  merge' =
    path: a: b:
    if a == null then
      b
    else if b == null then
      a

    else if builtins.isAttrs a && builtins.isAttrs b then
      builtins.foldl' (
        acc: key:
        let
          aVal = a.${key} or null;
          bVal = b.${key} or null;
          newPath = path ++ [ key ];
        in
        if aVal == null then
          acc // { ${key} = bVal; }
        else if bVal == null then
          acc // { ${key} = aVal; }
        else
          acc // { ${key} = merge' newPath aVal bVal; }
      ) { } (builtins.attrNames (a // b))

    else if builtins.isList a && builtins.isList b then
      a ++ b

    else if builtins.isFunction a && builtins.isFunction b then
      x: merge' (path ++ [ "<function>" ]) (a x) (b x)

    else if a == b then
      a

    else
      throw (
        "Conflict at '${builtins.concatStringsSep "." path}':"
        + " cannot merge values of types '${builtins.typeOf a}' and '${builtins.typeOf b}'"
        + " with values '${builtins.toString a}' and '${builtins.toString b}'"
      );

  merge = merge' [ ];

  mergeList = builtins.foldl' merge null;

  mergeImports = paths: mergeList (map import paths);
}
