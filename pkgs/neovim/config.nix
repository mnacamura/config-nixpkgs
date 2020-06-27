{ config, lib, substituteAll, bashInteractive }:

let
  hi = group: args:
  lib.concatStringsSep " " ([
    "hi" group
  ] ++ lib.optionals (args ? cterm) [
    "cterm=${args.cterm}"
  ] ++ lib.optionals (args ? fg) [
    "ctermfg=${toString args.fg.nr}"
  ] ++ lib.optionals (args ? bg) [
    "ctermbg=${toString args.bg.nr}"
  ] ++ lib.optionals (args ? gui) [
    "gui=${args.gui}"
  ] ++ lib.optionals (args ? fg) [
    "guifg=${args.fg.hex}"
  ] ++ lib.optionals (args ? bg) [
    "guibg=${args.bg.hex}"
  ] ++ lib.optionals (args ? guisp) [
    "guisp=${args.guisp.hex}"
  ]);
in

with config.colortheme.palette;
substituteAll {
  src = ./init.vim;

  shell = "${bashInteractive}/bin/sh";

  hi_pmenusel = hi "PmenuSel" { fg = black; bg = brorange; };
  hi_spellcap = hi "SpellCap" { fg = bryellow; };
  hi_spellbad = hi "SpellBad" { guisp = brred; };
  hi_spelllocal = hi "SpellLocal" { guisp = brmagenta; };
  hi_spellrare = hi "SpellRare" { guisp = brcyan; };
}
