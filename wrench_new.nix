with builtins;
let
  take =
    n: v:
    if n == 0 then
      [ ]
    else if v == [ ] then
      [ ]
    else
      [ (head v) ] ++ take (n - 1) (tail v);

in {
  wrench = {

  # lib.mkMerge
  # lib.types.submoduleWith

#   options.packages = lib.mkOption {
#     type = lib.types.attrsOf lib.types.package;
#     default = {};
#   };

#   { withSystem, inputs, ... }: {
#     perSystem = { system, ... }: {
#       _module.args.pkgs = import inputs.nixpkgs {
#         inherit system;
#         overlays = [ inputs.foo.overlays.default ];
#         config = {
#           allowUnfree = true;
#         };
#       };
#
#       # Now use this configured pkgs in your packages, devShells, etc.
#       packages.my-package = pkgs.hello;
#     };
#
#     flake.nixosConfigurations.my-machine = inputs.nixpkgs.lib.nixosSystem {
#       modules = [
#         ./configuration.nix
#         inputs.nixpkgs.nixosModules.readOnlyPkgs
#         ({ config, ... }: {
#           # Use the configured pkgs from perSystem
#           nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
#             { pkgs, ... }: # perSystem module arguments
#             pkgs
#           );
#         })
#       ];
#     };
#   }





  # string type or function check
  assert = type: x:
    asset foo "better error message"

  assert.any = types: x:
    let
      ok = builtins.any (t: t x) types;
    in
      assert ok "value has wrong type";
      x;

  assert.all = types: x:
    let
      ok = builtins.any (t: t x) types;
    in
      assert ok "value has wrong type";
      x;


    # type / __type
    typeOf =
      x:
      if isFunction x then
        "function"
      else if isAttrs x then
        x.__type or "attrs"
      else
        builtins.typeOf x;

    # show / __show / __toString
    toString =
      let
        f = {
          null = _: "null";
          int = builtins.toString;
          float = builtins.toString;
          path = builtins.toString;
          bool = b: if b then "true" else "false";
          lambda = _: "<function>";
          string = s: "\"${truncateString 20 s}\"";
          list = l: "[${concatList 3 (map wrench.toString l)}]";
          set =
            a:
            if hasAttr "__toString" a || hasAttr "outPath" a then
              builtins.toString a
            else
              "{${concatList 3 (attrNames a)}}";
        };
        truncateString = n: v: if stringLength v <= n then v else "${substring 0 (n - 1) v}…";
        concatList = n: v: if length v <= n then concatStringsSep ", " v else "${concatList n (take n v)}, …";
      in
      x: f.${builtins.typeOf x} x;
    };

  # TODO __call / __functor

  # TODO __env

  # TODO fromString / read

  Just = value: {
    __type = "Maybe";
    __toString = self: "Just ${wrench.toString self.value}";
    # TODO __map
    # TODO __merge
    inherit value;
  };

  Nothing = {
    __type = "Maybe";
    __toString = _: "Nothing";
    # TODO __map
  };

  isMaybe = m: wrench.typeOf m == "Maybe";
  isJust = m: isMaybe m && hasAttr "value" m;
  isNothing = m: isMaybe m && !hasAttr "value" m;
  withDefault = d: m: m.value or d;

  isSelector = s: wrench.typeOf s == "Selector";
  # isSelector = s: isGetter s && isSetter s;
  isGetter = hasAttr "__get";
  isSetter = hasAttr "__set";

  wrench = {
    # TODO view, over, set

    modify = selector: f: target:
#       if !isSelector selector then
#         throw "Selector modify expects a selector, not ${wrench.typeOf selector}"
#       else if !isFunction f then
#         throw "Selector modify expects a function, not ${wrench.typeOf f}"
#       else
        assert isSelector selector;
        assert isFunction f;
        let part = selector.get target;
        in if Maybe.isJust part then
          selector.set (f part.value) target;
        else
          target;
  };

  Selector = {
#     type = t:
#       let condition =
#         if isString t then (x: wrench.typeOf x == t)
#         else if isFunction t then t
#         else throw "Unsupported type selector ${wrench.typeOf t}"
#       in {
#         __type = "Selector";
#         __toString = self: self.key;
#
#         get = cfg:
#           let v = lib.getAttrFromPath path cfg;
#           in if typeCheck v then v else
#             throw "Type error at ${lib.concatStringsSep "." path}";
#
#         set = cfg: new:
#           if typeCheck new then
#             setAttrByPath path new cfg
#           else
#             throw "Type error when writing to ${lib.concatStringsSep "." path}";
#       };

    value = {
      __type = "Selector";
      __toString = _: "=";
      __get = self: target:
          Maybe.Just target;
      __set = self: value: target:
        if isNothing value then
          Maybe.Nothing
        else if isJust value then
          # or merge values
          target // { ${self.key} = value.value; }
        else
          target // { ${self.key} = value; }
      inherit key;
    };

    attr = key:
      if !isString key then
        throw "attr selector expects a string key, not ${wrench.typeOf key}"
      else {
        __type = "Selector";
        __toString = self: self.key;
        __get = self: target:
          if !isAttrs target then
            throw "attr selector ${wrench.toString self} does not work on ${wrench.typeOf target}"
          else if hasAttr self.key target then
            Maybe.Just target.${self.key}
          else
            Maybe.Nothing;
        __set = self: value: target:
          if !isAttrs target then
            throw "attr selector ${wrench.toString self} does not work on ${wrench.typeOf target}"
          else if isNothing value then
            removeAttrs target [ self.key ];
          else if isJust value then
            target // { ${self.key} = value.value; }
          else
            target // { ${self.key} = value; }
        inherit key;
      };

# list __map

# attrs __map
# attrs __dimap

# function __map
# function __dimap

# getter __map
# setter __map
# selector __dimap

#     function_return = selector:
#       if !isSelector selector then
#         throw "function_return selector expects an inner selector, not ${wrench.typeOf selector}"
#       else {
#         __type = "Selector";
#         __toString = self: "<function_return>.${wrench.toString self.selector}";
#         get = self: target:
#           if !isFunction target then
#             throw "function_return selector ${wrench.toString self} does not work on ${wrench.typeOf target}"
#           else
#             arg: self.selector.get (target arg);
#         set = self: value: target:
#           if !isFunction target then
#             throw "function_return selector ${wrench.toString self} does not work on ${wrench.typeOf target}"
#           else
#             arg: self.selector.set value (target arg);
#         inherit selector;
#       };
#
#     function_arg =
#       if !isSelector selector then
#         throw "function_arg selector expects an inner selector, not ${wrench.typeOf selector}"
#       else {
#         __type = "Selector";
#         __toString = self: "<function_arg>.${wrench.toString self.selector}";
#         get = self: _:
#             arg: self.selector.get (target arg);
#         set = self: value: target:
#           if !isFunction target then
#             throw "function_arg selector ${wrench.toString self} does not work on ${wrench.typeOf target}"
#           else
#             arg: self.selector.set value (target arg);
#         inherit selector;
#       };

    compose = outer: inner:
      if !isSelector outer then
        throw "Selector.compose expects two selectors, not ${wrench.typeOf outer}"
      else if !isSelector inner then
        throw "Selector.compose expects two selectors, not ${wrench.typeOf inner}"
      else {
        __type = "Selector";
        __toString = self: "${wrench.toString self.outer}.${wrench.toString self.inner}";
        get = self: target:
          let part = self.outer.get target;
          in if Maybe.isJust part then
            self.inner.get part.value
          else
            Maybe.Nothing;
        set = self: value: target:
          let part = self.outer.get target;
          ## TODO cascade deletes
          in if Maybe.isJust part then
            self.outer.set (self.inner.set value part.value) target;
          else
            target;
        inherit outer inner;
      };

    split = {getter, setter}:
      if !isGetter getter then
        throw "Selector.split expects a getter, not ${wrench.typeOf getter}"
      else if !isSetter setter then
        throw "Selector.split expects a setter, not ${wrench.typeOf setter}"
      else {
        __type = "Selector";
        __toString = self: "(${wrench.toString self.getter}|${wrench.toString self.setter})";
        get = self: target:
          self.getter.get target;
        set = self: value: target:
          self.setter.set value target;
        inherit getter setter;
      };
  };
};

