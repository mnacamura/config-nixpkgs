{ config, lib, substituteAll }:

let
  hi = group: args:
  let
    nr = lib.mapAttrs (_: c: toString c.nr) config.colortheme;
    hex = lib.mapAttrs (_: c: c.hex) config.colortheme;
  in
  lib.concatStringsSep " " ([
    "hi" group
  ] ++ lib.optionals (args ? cterm) [
    "cterm=${args.cterm}"
  ] ++ lib.optionals (args ? fg) [
    "ctermfg=${nr.${args.fg}}"
  ] ++ lib.optionals (args ? bg) [
    "ctermbg=${nr.${args.bg}}"
  ] ++ lib.optionals (args ? gui) [
    "gui=${args.gui}"
  ] ++ lib.optionals (args ? fg) [
    "guifg=${hex.${args.fg}}"
  ] ++ lib.optionals (args ? bg) [
    "guibg=${hex.${args.bg}}"
  ]);
in

substituteAll {
  src = ./init.vim;

  hi_search = hi "Search" { fg = "brwhite"; bg = "orange"; };
  hi_incsearch = hi "IncSearch" { fg = "brwhite"; bg = "brorange"; };
  hi_pmenusel = hi "PmenuSel" { fg = "brwhite"; bg = "orange"; };
  hi_spellbad = hi "SpellBad" { fg = "brred"; gui = "undercurl"; };
}
