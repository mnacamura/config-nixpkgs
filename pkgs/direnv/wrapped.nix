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

  fishHook = writeFishVendorConfig "direnv" ''
    eval (${wrapped}/bin/direnv hook fish)
  '';

  wrapped = buildEnv {
    name = "${patched.name}-wrapped-without-hook";
    paths = [ patched ];
    # Hide ${direnv}/share/fish/vendor_conf.d/direnv.fish
    pathsToLink = [ "/bin" "/share/man" ];
  };
in

buildEnv {
  name = "${patched.name}-wrapped";
  paths = [ wrapped fishHook ];
}
