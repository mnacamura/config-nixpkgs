{ direnv, nix-direnv, substituteAll, writeFishVendorConfig, buildEnv }:

let
  patched = direnv.overrideAttrs (old: {
    name = "${direnv.name}-patched";

    patches = (old.patches or []) ++ [
      (substituteAll {
        src = ./direnvrc.patch;
        direnvrc = "${nix-direnv}/share/nix-direnv/direnvrc";
      })
    ];

  installPhase = (old.installPhase or "") + ''
      # Delete share/fish/vendor_conf.d/direnv.fish for later convenience
      rm -f "$out/share/fish/vendor_conf.d/direnv.fish"
    '';
  });

  fishHook = writeFishVendorConfig "direnv" ''
    ${patched}/bin/direnv hook fish | source
  '';
in

buildEnv {
  name = "${patched.name}-wrapped";

  paths = [ patched fishHook ];
}
