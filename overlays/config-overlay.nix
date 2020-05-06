self: super:

with super.lib;

let
  old = { inherit (super) config; };

  new = evalModules {
    modules = [
      (args: {
        imports = [
          ../modules/assertions.nix
          ../modules/colortheme.nix
        ];
        config = import ../my.nix (args // { pkgs = self; });
      })
    ];
  };
in

recursiveUpdate old new
