#!@fish@/bin/fish

if [ ! -e ./.envrc ]
    echo "use nix" > .envrc
    direnv allow
end

if [ ! -e default.nix ]
    echo -n "\
{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation rec {
  pname = \"my-pkg\";
  version = \"0.0.1\";

  src = ./.;

  nativeBuildInputs = [ ];
  buildInputs = [ ];
}
" > default.nix
end

if [ ! -e shell.nix ]
    echo -n "\
with import <nixpkgs> {};

mkShell {
  inputsFrom = [ (callPackage ./. {}) ];
  buildInputs = [ ];

  shellHook = ''
  '';
}
" > shell.nix
end

set -l ignore "\
# Nix and direnv stuff
.direnv
result
"
if [ ! -e ./.gitignore ]
    echo -n "$ignore" > .gitignore
else
    echo -n "$ignore" >> .gitignore
end

if [ -n "$EDITOR" ]
    eval $EDITOR default.nix
else
    set_color yellow
    echo (status -f): Please set EDITOR environment variable to edit nix files >&2 
    set_color normal
end
