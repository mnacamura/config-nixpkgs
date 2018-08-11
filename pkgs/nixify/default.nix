{ stdenv, substituteAll, runCommand, fish, vim }:

let
  nixify = substituteAll {
    src = ./nixify.fish;
    inherit fish vim;
  };
in

runCommand "nixify" {} ''
  install -D -m 555 ${nixify} $out/bin/nixify
''
