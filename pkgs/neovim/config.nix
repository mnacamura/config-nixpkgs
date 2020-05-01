{ config, lib, substituteAll }:

let
  hi = group: args:
  let
    inherit (config.colortheme) nr hex;
  in
  lib.concatStringsSep " " ([
    "hi" group
  ] ++ lib.optionals (args ? cterm) [
    "cterm=${args.cterm}"
  ] ++ lib.optionals (args ? fg) [
    "ctermfg=${toString nr.${args.fg}}"
  ] ++ lib.optionals (args ? bg) [
    "ctermbg=${toString nr.${args.bg}}"
  ] ++ lib.optionals (args ? gui) [
    "gui=${args.gui}"
  ] ++ lib.optionals (args ? fg) [
    "guifg=${hex.${args.fg}}"
  ] ++ lib.optionals (args ? bg) [
    "guibg=${hex.${args.bg}}"
  ] ++ lib.optionals (args ? guisp) [
    "guisp=${hex.${args.guisp}}"
  ]);
in

substituteAll {
  src = ./init.vim;

  hi_pmenusel = hi "PmenuSel" { bg = "orange"; };
  hi_spellcap = hi "SpellCap" { fg = "bryellow"; };
  hi_spellbad = hi "SpellBad" { guisp = "brred"; };
  hi_spelllocal = hi "SpellLocal" { guisp = "brmagenta"; };
  hi_spellrare = hi "SpellRare" { guisp = "brcyan"; };
}
