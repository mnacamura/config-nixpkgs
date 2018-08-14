{ ctags, lib, writeText, buildEnv, makeWrapper }:

{ options }:

let
  configFile = writeText "ctags-config" (lib.concatStringsSep "\n" options);
in

buildEnv {
  name = "${ctags.name}-wrapper";

  paths = [ ctags ];

  pathsToLink = [ "/share" ];

  buildInputs = [ makeWrapper ];

  postBuild = ''
    mkdir $out/bin
    makeWrapper ${ctags}/bin/ctags $out/bin/ctags \
      --add-flags "--options ${configFile}"
    for path in ${ctags}/bin/*; do
      name="$(basename "$path")"
      [ "$name" != ctags ] && ln -s "$path" "$out/bin/$name"
    done
  '';
}
