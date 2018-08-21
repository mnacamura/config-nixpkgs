{ direnv, runCommand, substituteAll, writeFishVendorConfig, buildEnv }:

let
  direnvrc = runCommand "direnvrc" {} ''
    cp "${./direnvrc}" $out
  '';

  direnvPatched = direnv.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      (substituteAll {
        src = ./direnvrc.patch;
        direnvrc = "${direnvrc}";
      })
    ];
  });

  hook = writeFishVendorConfig "direnv" ''
    eval (${wrapper}/bin/direnv hook fish)
  '';

  wrapper = buildEnv {
    name = "${direnvPatched.name}-wrapper-without-hook";

    paths = [ direnvPatched ];

    # Hide ${direnv}/share/fish/vendor_conf.d/direnv.fish
    pathsToLink = [ "/bin" "/share/man" ];
  };
in

buildEnv {
  name = "${direnvPatched.name}-wrapper";
  paths = [ wrapper hook ];
}
