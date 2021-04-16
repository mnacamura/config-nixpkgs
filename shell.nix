with import <nixpkgs> {};

pkgs.mkShell {
  buildInputs = [
    # shellcheck
    vim-vint
  ];
}
