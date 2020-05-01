{ config, lib, substituteAll }:

let
  inherit (config) colortheme;
in

substituteAll (colortheme.hex // {
  src = ./zathurarc;
})
