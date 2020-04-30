{ config, lib, substituteAll }:

let
  colortheme = lib.mapAttrs (_: c: c.hex) config.colortheme;
in

substituteAll (colortheme // {
  src = ./zathurarc;
})
