{ stdenv, substituteAll, runCommand, fish, vim }:

let
  nixify = substituteAll {
    src = ./nixify.fish;

    inherit fish vim;
  };
in

runCommand "nixify" {} ''
  install -D ${nixify} $out/bin/nixify
''
