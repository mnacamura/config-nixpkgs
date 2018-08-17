{ direnv, runCommand, buildEnv, makeWrapper }:

let
  configHome = runCommand "direnv-config-home" {} ''
    install -D -m 444 "${./direnvrc}" "$out/direnv/direnvrc"
  '';
in

buildEnv {
  name = "${direnv.name}-wrapper";

  paths = [ direnv ];

  pathsToLink = [ "/share" ];

  buildInputs = [ makeWrapper ];

  postBuild = ''
    makeWrapper ${direnv}/bin/direnv $out/bin/direnv \
      --set XDG_CONFIG_HOME "${configHome}"
  '';
}
