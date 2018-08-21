{ direnv, runCommand, substituteAll, writeFishVendorConfig, buildEnv }:

let
  direnvrc = runCommand "direnvrc" {} ''
    cp "${./direnvrc}" $out
  '';

  patched = direnv.overrideAttrs (old: {
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
    name = "${patched.name}-wrapper-without-hook";
    paths = [ patched ];
    # Hide ${direnv}/share/fish/vendor_conf.d/direnv.fish
    pathsToLink = [ "/bin" "/share/man" ];
  };
in

buildEnv {
  name = "${patched.name}-wrapper";
  paths = [ wrapper hook ];
}
