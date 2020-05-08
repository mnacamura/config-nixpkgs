{ substituteAll, runCommand, fish }:

let
  nixify = substituteAll {
    src = ./nixify.fish;

    inherit fish;
    default_template = ./templates/default.nix;
    shell_template = ./templates/shell.nix;
  };
in

runCommand "nixify" {} ''
  install -D ${nixify} $out/bin/nixify
''
