{
  description = "My personal nixpkgs package set";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }: {
    overlay = nixpkgs.lib.composeManyExtensions [
      (import ./overlays/pkgs.nix)
    ];
  } // (flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      config = import ./config.nix;
      overlays = [ self.overlay ];
    };
  in rec {
    packages = {
      inherit (pkgs)
      terminalEnv
      ;
    };
    defaultPackage = packages.terminalEnv;
  }));
}
