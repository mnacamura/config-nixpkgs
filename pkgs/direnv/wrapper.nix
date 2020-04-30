{ direnv, runCommand, substituteAll, writeFishVendorConfig, buildEnv }:

let
  direnvrc = runCommand "direnvrc" {} ''
    cp "${./direnvrc}" $out
  '';

  patched = direnv.overrideAttrs (old: {
    name = "${direnv.name}-patched";

    patches = (old.patches or []) ++ [
      (substituteAll {
        src = ./direnvrc.patch;
        direnvrc = "${direnvrc}";
      })
    ];

  installPhase = (old.installPhase or "") + ''
      # Delete share/fish/vendor_conf.d/direnv.fish for later convenience
      rm -f "$bin/share/fish/vendor_conf.d/direnv.fish"
    '';
  });

  fishHook = writeFishVendorConfig "direnv" ''
    eval (${patched}/bin/direnv hook fish)
  '';
in

buildEnv {
  name = "${patched.name}-wrapped";

  paths = [ patched fishHook ];
}
