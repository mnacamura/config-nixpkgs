with import <nixpkgs> {};

mkShell {
  inputsFrom = [ (callPackage ./. {}) ];
  buildInputs = [ ];

  shellHook = ''
  '';
}
