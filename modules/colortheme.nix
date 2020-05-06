{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.colortheme;

  color256 = with types; ints.between 0 255;

  colorHex = with types; strMatching "^#[0-9abcdefABCDEF]{6}$";

  defaultPalette = {
    black     = { nr =  0; hex = "#000000"; };
    red       = { nr =  1; hex = "#800000"; };
    green     = { nr =  2; hex = "#008000"; };
    yellow    = { nr =  3; hex = "#808000"; };
    blue      = { nr =  4; hex = "#000080"; };
    magenta   = { nr =  5; hex = "#800080"; };
    cyan      = { nr =  6; hex = "#008080"; };
    white     = { nr =  7; hex = "#c0c0c0"; };
    brblack   = { nr =  8; hex = "#808080"; };
    brred     = { nr =  9; hex = "#ff0000"; };
    brgreen   = { nr = 10; hex = "#00ff00"; };
    bryellow  = { nr = 11; hex = "#ffff00"; };
    brblue    = { nr = 12; hex = "#0000ff"; };
    brmagenta = { nr = 13; hex = "#ff00ff"; };
    brcyan    = { nr = 14; hex = "#00ffff"; };
    brwhite   = { nr = 15; hex = "#ffffff"; };
  };
in

{
  options = {
    colortheme.palette = mkOption {
      type = with types; attrsOf (attrsOf (oneOf [
        color256
        colorHex
      ]));
      default = defaultPalette;
      description = ''
        Color theme to be used for various packages (console, vim, ...). Each
        color is defined by an attrset which have at least 'nr' and 'hex' attrs:
        'nr' is an xterm color number (e.g., black is 0), and 'hex' is a hex
        color code with prefix '#' (e.g., "#1c1c1a"). It should include at
        least 16 colors: 'black', 'red', 'green', 'yellow', 'blue', 'magenta',
        'cyan', 'white', 'brblack', 'brred', 'brgreen', 'bryellow', 'brblue',
        'brmagenta', 'brcyan', and 'brwhite'.
      '';
    };

    colortheme.nr = mkOption {
      type = with types; attrsOf color256;
      description = ''
        'nr' values of 'colortheme.palette'.
      '';
    };

    colortheme.hex = mkOption {
      type = with types; attrsOf colorHex;
      description = ''
        'hex' values of 'colortheme.palette'.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = let
          definedNames = attrNames cfg.palette;
          expectedNames = [
            "black"   "red"   "green"   "yellow"   "blue"   "magenta"   "cyan"   "white"
            "brblack" "brred" "brgreen" "bryellow" "brblue" "brmagenta" "brcyan" "brwhite"
          ];
        in all (n: elem n definedNames) expectedNames;
        message = ''
          colortheme: At least 16 colors should be defined.
        '';
      }
      {
        assertion = all (b: b) (mapAttrsToList (_: c: c ? nr) cfg.palette);
        message = ''
          colortheme: Color(s) with no 'nr' value found.
        '';
      }
      {
        assertion = all (b: b) (mapAttrsToList (_: c: c ? hex) cfg.palette);
        message = ''
          colortheme: Color(s) with no 'hex' value found.
        '';
      }
    ];

    colortheme.nr = mapAttrs (_: c: c.nr) (filterAttrs (_: c: c ?  nr) cfg.palette);

    colortheme.hex = mapAttrs (_: c: c.hex) cfg.palette;
  };
}
