{ stdenv }:

stdenv.mkDerivation {
  name = "fish-config";

  src = ./src;

  buildCommand = ''
    for file in $src/conf.d/*; do
      install -D -m 444 "$file" -t $out/etc/fish/conf.d
    done
    for file in $src/functions/*; do
      install -D -m 444 "$file" -t $out/etc/fish/functions
    done
  '';
}
