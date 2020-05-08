{ pkgs ? import <nixpkgs> {} }:

with pkgs;

stdenv.mkDerivation rec {
  pname = "my-pkg";
  version = "0.0.1";

  src = ./.;

  nativeBuildInputs = [ ];

  buildInputs = [ ];
}
