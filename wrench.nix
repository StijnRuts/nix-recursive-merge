with builtins;
let
  typeOf =
    x:
    if isFunction x then
      "function"
    else if isAttrs x then
      "attrs"
    else
      builtins.typeOf x;

  take =
    n: v:
    if n == 0 then
      [ ]
    else if v == [ ] then
      [ ]
    else
      let
        first = head v;
        rest = tail v;
      in
      [ first ] ++ take (n - 1) rest;

  toString =
    x:
    let
      truncateString = n: v: if stringLength v <= n then v else "${substring 0 (n - 1) v}…";
      concatList =
        n: v: if length v <= n then concatStringsSep ", " v else "${concatList n (take n v)}, …";
    in
    {
      null = _: "null";
      int = builtins.toString;
      float = builtins.toString;
      path = builtins.toString;
      bool = v: if v then "true" else "false";
      function = _: "<function>";
      string = v: "\"${truncateString 20 v}\"";
      list = v: "[${concatList 3 (map toString v)}]";
      attrs =
        v:
        if hasAttr "__toString" v || hasAttr "outPath" v then
          builtins.toString v
        else
          "{${concatList 3 (attrNames v)}}";
    }
    .${typeOf x}
    x;
in
rec {
  apply =
    f:
    if isFunction f then
      f
    else
      over.type {
        null = _: v: v;
        path = f: apply (import f);
        list = fs: init: foldl' (v: f: apply f v) init fs;
        attrs = v: apply (v.__functor v);
      } f;

  over = {
    type = f: v: apply (f.${typeOf v} or f._fallback or value.unsupported) v;
    nonNull =
      f:
      over.type {
        null = value.keep;
        _fallback = apply f;
      };
    list =
      f:
      over.type {
        list = map (apply f);
        null = value.keep;
      };
    attrs =
      f:
      over.type {
        attrs = mapAttrs (_: apply f);
        null = value.keep;
      };
    attrs2 =
      f:
      over.type {
        attrs = [
          (mapAttrs (apply2 f))
          merge.attrs
        ];
        null = value.keep;
      };
    path =
      f:
      over.type {
        path = p: apply f (import p);
        _fallback = value.keep;
      };
    function =
      f:
      over.type {
        function = v: args: apply (apply f args) (apply v args);
        _fallback = v: args: apply (apply f args) v;
      };
  };

  to = {
    list = over.type {
      list = value.keep;
      null = _: [ ];
      _fallback = v: [ v ];
    };
    function = over.type {
      function = value.keep;
      _fallback = v: _: v;
    };
  };

  attrs = {
    key = rec {
      get = k: v: v.${k} or null;
      set =
        k: new: v:
        v // { ${k} = new; };
      remove = k: x: removeAttrs x [ k ];
      over =
        k: f: v:
        set k (apply f (get k v)) v;
      extract = k: v: {
        value = get k v;
        rest = remove k v;
      };
      singleton = k: v: set k v { };
      fold =
        f: initial:
        let
          v =
            foldl'
              (
                prev: k:
                let
                  next = extract k prev.rest;
                in
                {
                  value = merge prev.value (apply (f.${k} k) next.value);
                  inherit (next) rest;
                }
              )
              {
                value = null;
                rest = initial;
              }
              (attrNames (removeAttrs f [ "_rest" ]));
        in
        merge v.value (apply (f._rest or value.keep) v.rest);
    };
    path = rec {
      fromString = p: filter isString (split "\\." p);
      toString = concatStringsSep ".";
      get =
        p: v:
        let
          k = head p;
          rest = tail p;
        in
        if isString p then
          get (fromString p) v
        else if v == null then
          null
        else if p == [ ] then
          v
        else
          get rest (attrs.key.get k v);
      set =
        p: new: v:
        let
          k = head p;
          rest = tail p;
        in
        if isString p then
          set (fromString p) new v
        else if v == null then
          set p new { }
        else if p == [ ] then
          new
        else if rest == [ ] then
          attrs.key.set k new v
        else
          attrs.key.over k (set rest new) v;
      remove =
        p: v:
        let
          k = head p;
          rest = tail p;
        in
        if isString p then
          remove (fromString p) v
        else if v == null then
          null
        else if p == [ ] then
          v
        else if rest == [ ] then
          attrs.key.remove k v
        else
          let
            newVal = remove rest (attrs.key.get k v);
          in
          if newVal == { } then attrs.key.remove k v else attrs.key.set k newVal v;
      over =
        p: f: v:
        set p (apply f (get p v)) v;
      extract = p: x: {
        value = get p x;
        rest = remove p x;
      };
      singleton = p: v: set p v { };
      fold =
        f: initial:
        let
          v =
            foldl'
              (
                prev: p:
                let
                  next = extract p prev.rest;
                in
                {
                  value = merge prev.value (apply (f.${p} p) next.value);
                  inherit (next) rest;
                }
              )
              {
                value = null;
                rest = initial;
              }
              (attrNames (removeAttrs f [ "_rest" ]));
        in
        merge v.value (apply (f._rest or value.keep) v.rest);
    };
  };

  value = {
    keep = {
      __functor = _: v: v;
      key = k: over.nonNull (attrs.key.singleton k);
      path = p: over.nonNull (attrs.path.singleton p);
    };
    to = {
      key = k: _: value.keep.key k;
      path = p: _: value.keep.path p;
    };
    discard = _: null;
    unsupported = v: throw "Unsupported ${typeOf v} with value ${toString v}";
  };

  merge = {
    __functor =
      _:
      let
        merge' =
          path: a: b:
          if a == null then
            b
          else if b == null then
            a

          else if isAttrs a && isAttrs b then
            foldl' (
              acc: key: acc // { ${key} = merge' (path ++ [ key ]) (a.${key} or null) (b.${key} or null); }
            ) { } (attrNames (a // b))

          else if isList a && isList b then
            a ++ b

          else if isFunction a || isFunction b then
            x: merge' (path ++ [ "<function>" ]) (to.function a x) (to.function b x)

          else if a == b then
            a

          else
            throw (
              "Cannot merge types ${typeOf a} and ${typeOf b}"
              + " with values ${toString a} and ${toString b}"
              + (if (length path) == 0 then "" else " at " + (concatStringsSep "." path))
            );
      in
      merge' [ ];

    list = foldl' merge null;

    attrs = attrs: merge.list (attrValues attrs);
  };
}
