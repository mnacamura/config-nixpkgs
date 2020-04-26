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

  wrappedWithoutHook = buildEnv {
    name = "${patched.name}-wrapped-without-hook";
    paths = [ patched ];
    # Hide ${direnv}/share/fish/vendor_conf.d/direnv.fish
    pathsToLink = [ "/bin" "/share/man" ];
  };

  fishHook = writeFishVendorConfig "direnv" ''
    eval (${wrappedWithoutHook}/bin/direnv hook fish)
  '';
in

buildEnv {
  name = "${patched.name}-wrapped";
  paths = [ wrappedWithoutHook fishHook ];
}
