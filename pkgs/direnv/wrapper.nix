{ direnv, runCommand, writeFishVendorConfig, buildEnv, makeWrapper }:

let
  configHome = runCommand "direnv-config-home" {} ''
    install -D -m 444 "${./direnvrc}" "$out/direnv/direnvrc"
  '';

  hook = writeFishVendorConfig "direnv" ''
    eval (${wrapper}/bin/direnv hook fish)
  '';

  wrapper = buildEnv {
    name = "${direnv.name}-wrapper-without-fish-hook";

    paths = [ direnv ];

    # Hide ${direnv}/share/fish/vendor_conf.d/direnv.fish
    pathsToLink = [ "/share/man" ];

    buildInputs = [ makeWrapper ];

    postBuild = ''
      makeWrapper ${direnv}/bin/direnv $out/bin/direnv \
        --set XDG_CONFIG_HOME "${configHome}"
    '';
  };
in

buildEnv {
  name = "${direnv.name}-wrapper";
  paths = [ wrapper hook ];
}
