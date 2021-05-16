{ config, lib, substituteAll, stdenv }:

stdenv.mkDerivation {
  name = "fish-config-base";

  src = ./.;

  buildCommand = ''
    for file in $src/conf.d/*; do
      install -m444 "$file" -Dt $out/etc/fish/conf.d
    done
    for file in $src/functions/*; do
      install -m444 "$file" -Dt $out/etc/fish/functions
    done
  '';
}
