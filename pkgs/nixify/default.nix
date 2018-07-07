{ stdenv, writeText, runCommand, fish, vim }:

let
  nixify = writeText "nixify" ''
    #!${fish}/bin/fish

    if [ ! -e ./.envrc ]
      echo "use_nix" > .envrc
      direnv allow
    end

    if [ ! -e default.nix ]
      echo -n "\
    { nixpkgs ? import <nixpkgs> {} }:

    let
      inherit (nixpkgs) pkgs;
    in

    with pkgs;

    {
      app = stdenv.mkDerivation rec {
        name = \"my-app\";
        version = \"0.0.1\";

        src = ./.;

        buildInputs = [ ];
      };
    }
    " > default.nix
    end

    if [ ! -e shell.nix ]
      echo -n "\
    { nixpkgs ? import <nixpkgs> {} } @ args:

    let
      inherit (nixpkgs) pkgs;
      inherit (import ./default.nix args) app;
    in

    with pkgs;

    stdenv.mkDerivation {
      name = \"my-app-project-env\";

      inherit (app) buildInputs;

      shellHook = '''
      ''';
    }
    " > shell.nix
    end

    if [ -z "$EDITOR" ]
      ${vim}/bin/vim default.nix
    else
      eval $EDITOR default.nix
    end
    '';
in

runCommand "nixify" {} ''
  install -D -m 555 ${nixify} $out/bin/nixify
''
