self: super:

{
  fishPlugins = super.fishPlugins // (self.callPackage ../pkgs/fish/plugins {
    inherit (super.fishPlugins) callPackage;
  });

  configFiles.fish = self.callPackage ../pkgs/fish/config.nix {
    base = self.callPackage ../pkgs/fish/config-base.nix {};
  };

  inherit (self.callPackage ../pkgs/fish/lib.nix {})
  writeFishConfig
  writeFishVendorConfig;

  consoleEnv = let
    version = "2021-12-09";
  in self.buildEnv {
    name = "console-${version}-env";
    paths = with self; [
      configFiles.fish
      fishPlugins.skim-fish
      lsd
      bat
      fd
      ripgrep
      skim
      patdiff
      gnumake
      file
      tree
      p7zip
      unrar
      sl
      htop
      glow
    ] ++ lib.optionals stdenv.isLinux [
      trash-cli
      xsel
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.trash
      reattach-to-user-namespace
    ];
    meta.priority = 6;
  };
}
