{ direnv, runCommand, writeFishVendorConfig, buildEnv, makeWrapper }:

let
  configDir = runCommand "direnv-config-dir" {} ''
    install -D -m 444 "${./direnvrc}" "$out/direnvrc"
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
        --set DIRENV_CONFIG "${configDir}"
    '';
  };
in

buildEnv {
  name = "${direnv.name}-wrapper";
  paths = [ wrapper hook ];
}
