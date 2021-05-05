{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.environment.colors;

  color256 = with types; ints.between 0 255;

  colorHex = with types; strMatching "^#[0-9abcdefABCDEF]{6}$";

  palettes = {
    srcery = import ./palettes/srcery.nix;
    marnie = import ./palettes/marnie.nix;
  };
in

{
  options = {
    environment.colors.palette = mkOption {
      type = with types; attrsOf (attrsOf (oneOf [
        color256
        colorHex
      ]));
      default = palettes.srcery;
      description = ''
        Color theme to be used for various packages (console, vim, ...). Each
        color is defined by an attrset which have 'nr' and 'hex' attrs:
        'nr' is an xterm color number (e.g., black is 0), and 'hex' is a hex
        color code with prefix '#' (e.g., "#1c1c1a"). It should include colors
        for terminal use, 'term_fg', 'term_bg', 'black', 'red', 'green',
        'yellow', 'blue', 'magenta', 'cyan', 'white', 'brblack', 'brred',
        'brgreen', 'bryellow', 'brblue', 'brmagenta', 'brcyan', 'brwhite',
        and colors for GUI use, 'bg', 'fg', 'menu_fg', 'menu_bg', 'hdr_fg',
        'hdr_bg', 'sel_bg', 'sel_fg', 'accent', 'txt_bg', 'txt_fg', 'btn_bg',
        'btn_fg', 'hdr_btn_bg', 'hdr_btn_fg', 'wm_border_focus',
        'wm_border_unfocus', 'caret1_fg', 'caret2_fg', 'icons_light',
        'icons_medium', 'icons_dark', 'icons_sym_action', and 'icons_sym_panel'.
        For more information about these colors, try to use the Themix GUI
        designer.
      '';
    };

    environment.colors.palettes = mkOption {
      type = with types; attrsOf (attrsOf attrs);
      default = palettes;
      description = ''
        A collection of color themes. For more information, see
        'environment.colors.palette'.
      '';
    };

    environment.colors.nr = mkOption {
      type = with types; attrsOf color256;
      description = ''
        'nr' values of 'environment.colors.palette'.
      '';
    };

    environment.colors.hex = mkOption {
      type = with types; attrsOf colorHex;
      description = ''
        'hex' values of 'environment.colors.palette'.
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
          environment.colors: At least 16 colors should be defined.
        '';
      }
      {
        assertion = all (b: b) (mapAttrsToList (_: c: c ? nr) cfg.palette);
        message = ''
          environment.colors: Color(s) with no 'nr' value found.
        '';
      }
      {
        assertion = all (b: b) (mapAttrsToList (_: c: c ? hex) cfg.palette);
        message = ''
          environment.colors: Color(s) with no 'hex' value found.
        '';
      }
    ];

    environment.colors.nr = mapAttrs (_: c: c.nr) (filterAttrs (_: c: c ?  nr) cfg.palette);

    environment.colors.hex = mapAttrs (_: c: c.hex) cfg.palette;
  };
}
