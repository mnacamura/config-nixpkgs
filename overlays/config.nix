self: super:

with super.lib;

let
  old = { inherit (super) config; };

  new = evalModules {
    modules = [
      (args: {
        imports = [
          ../modules/assertions.nix
          ../modules/colors
        ];
        config = import ../my.nix (args // { pkgs = self; });
      })
    ];
  };
in

recursiveUpdate old new
