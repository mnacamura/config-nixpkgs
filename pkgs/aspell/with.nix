{ aspell, writeText, symlinkJoin, buildEnv, makeWrapper }:

{ lang, dicts }:

let
  configFile = writeText "aspell-config-${lang}" ''
    lang ${lang}
    dict-dir ${dicts'}/lib/aspell
  '';

  dicts' = symlinkJoin {
    name = "aspell-dicts-${lang}";
    paths = dicts;
  };
in

buildEnv {
  name = "${aspell.name}-${lang}";

  paths = [ aspell ];

  pathsToLink = [ "/share" ];

  buildInputs = [ makeWrapper ];

  postBuild = ''
    mkdir $out/bin
    makeWrapper ${aspell}/bin/aspell $out/bin/aspell \
      --add-flags "--conf ${configFile}"
    for path in ${aspell}/bin/*; do
      name="$(basename "$path")"
      [ "$name" != aspell ] && ln -s "$path" "$out/bin/$name"
    done
  '';
}
