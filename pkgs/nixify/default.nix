{ stdenv, writeText, runCommand, fish, vim }:

let
  nixify = writeText "nixify" ''
    #!${fish}/bin/fish

    if [ ! -e ./.envrc ]
      echo "use nix" > .envrc
      direnv allow
    end

    if [ ! -e default.nix ]
      echo -n "\
    { nixpkgs ? import <nixpkgs> {} }:

    with nixpkgs;

    stdenv.mkDerivation rec {
      name = \"my-pkg-\''${version}\";
      version = \"0.0.1\";

      src = ./.;

      nativeBuildInputs = [ ];
      buildInputs = [ ];
    };
    " > default.nix
    end

    if [ ! -e shell.nix ]
      echo -n "\
    with import <nixpkgs> {};

    mkShell {
      inputsFrom = [ (import ./default.nix {}) ];
      buildInputs = [ ];

      shellHook = '''
      ''';
    }
    " > shell.nix
    end

    set -l ignore "\
    # Nix direnv related stuff
    .direnv
    result
    "
    if [ ! -e ./.gitignore ]
      echo -n "$ignore" > .gitignore
    else
      echo -n "$ignore" >> .gitignore
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
