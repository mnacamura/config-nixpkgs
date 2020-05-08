{ stdenv, substituteAll, runCommand, fish }:

let
  nixify = substituteAll {
    src = ./nixify.fish;

    inherit fish;
  };
in

runCommand "nixify" {} ''
  install -D ${nixify} $out/bin/nixify
''
