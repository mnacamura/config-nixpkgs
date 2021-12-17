# See nixpkgs/nixos/modules/misc/assertions.nix,
# nixpkgs/nixos/modules/system/activation/top-level.nix, and
# nixpkgs/lib/asserts.nix

{ config, lib, ... }:

with lib;

let
  withWarnings = x:
  fold (w: _: builtins.trace "[1;33mwarning: ${w}[0m" _)
  x config.warnings;

  withAssertions = x:
  if (failedOnes == [])
  then x
  else throw ''
    [1;31mErrors:
    ${concatStringsSep "" (map (_: "- ${_}") failedOnes)}[0m
  '';

  failedOnes = map (x: x.message) (filter (x: !x.assertion) config.assertions);
in

{
  options = {
    assertions = mkOption {
      type = with types; listOf unspecified;
      internal = true;
      default = [];
    };

    warnings = mkOption {
      type = with types; listOf str;
      internal = true;
      default = [];
    };

    _phantom = mkOption {
      internal = true;
      type = types.bool;
      default = withAssertions (withWarnings true);
      description = ''
        Fake option to show assertions and warnings when evaluating 'config'.
      '';
    };
  };
}
