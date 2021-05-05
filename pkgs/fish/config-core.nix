{ config, lib, substituteAll, stdenv }:

let
  colors = lib.mapAttrs (_: s: lib.strings.substring 1 6 s) config.environment.colors.hex;

  color_fish = substituteAll (colors // { src = ./conf.d/color.fish; });
in

stdenv.mkDerivation {
  name = "fish-config-core";

  src = ./.;

  buildCommand = ''
    mkdir -p $out/etc/fish/conf.d
    for file in $src/conf.d/*; do
        if [ "$(basename "$file")" = color.fish ]; then
            ln -s ${color_fish} $out/etc/fish/conf.d/color.fish
        else
            install -D -m 444 "$file" -t $out/etc/fish/conf.d
        fi
    done
    mkdir -p $out/etc/fish/functions
    for file in $src/functions/*; do
      install -D -m 444 "$file" -t $out/etc/fish/functions
    done
  '';
}
