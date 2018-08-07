{ stdenv }:

stdenv.mkDerivation {
  name = "fish-config";

  src = ./.;

  buildCommand = ''
    for file in $src/functions/*; do
      install -D -m 444 "$file" -t $out/etc/fish/functions
    done
  '';
}
