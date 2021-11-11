self: super:

{
  wrapped.aspell = self.aspellWith {
    lang = "en_US";
    dicts = with self.aspellDicts; [
      en
      en-computers
      en-science
    ];
  };

  aspellWith = self.callPackage ../pkgs/aspell/with.nix {};

  wrapped.ctags = self.ctagsWith {
    options = with self.ctagsOptions; [
    ];
  };

  ctagsWith = self.callPackage ../pkgs/ctags/with.nix {
    ctags = super.universal-ctags;
  };

  ctagsOptions = import ../pkgs/ctags/options.nix;

  ccacheWrapper = super.ccacheWrapper.override {
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_DIR=/var/cache/ccache
      export CCACHE_UMASK=007
      if [ ! -d "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' does not exist"
        echo "Please create it with:"
        echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
        echo "  sudo chown root:nixbld '$CCACHE_DIR'"
        echo "====="
        exit 1
      fi
      if [ ! -w "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
        echo "Please verify its access permissions"
        echo "====="
        exit 1
      fi
    '';
  };

  nix-direnv = super.nix-direnv.overrideAttrs (old: {
    version = "1.5.0";
    src = self.fetchFromGitHub {
      owner = "nix-community";
      repo = "nix-direnv";
      rev = "083ac16bf52102bb3a4bf25c30bce192b3f7b79a";
      sha256 = "0c2ksyp3ylpv7pmjvzvj419ykzfjplcj1ig2gzs379pnwvik249g";
    };
  });

  wrapped.direnv = self.callPackage ../pkgs/direnv/wrapper.nix {};

  configFiles.fish = self.callPackage ../pkgs/fish/config.nix {
    base = self.callPackage ../pkgs/fish/config-base.nix {};
  };

  inherit (self.callPackage ../pkgs/fish/lib.nix {})
  writeFishConfig
  writeFishVendorConfig;

  neovim = self.wrapNeovim self.neovim-nightly {};

  neovim-nightly = with self.lib;
  let
    neovim-nightly-overlay = builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    };
    self' = fix (extends (import neovim-nightly-overlay) (_: super));
  in
  self'.neovim-nightly;

  configFiles.neovim = self.callPackage ../pkgs/neovim/config.nix {};

  wrapped.neovim = self.callPackage ../pkgs/neovim/wrapper.nix {
    configFile = self.configFiles.neovim;
  };

  vimPlugins = super.vimPlugins // (self.callPackage ../pkgs/vim-plugins {});

  # Don't forget to delete cache after bumping revision: $(pubsdir)/.cache
  pubs = super.pubs.overridePythonAttrs (_: {
    version = "2021-02-03";
    src = super.fetchFromGitHub {
      owner = "pubs";
      repo = "pubs";
      rev = "29e8fecfa9c7bdd991ef231a8fb1d250d9ebd8a9";
      sha256 = "1fdlznn9i8n6xhbiz7zzcf3vgwwi8dzn1pw47afra6r3vmij1s2f";
    };
  });

  SDL2 = super.SDL2.override {
    fcitxSupport = self.stdenv.isLinux;
  };

  configFiles.zathura = self.callPackage ../pkgs/zathura/config.nix {};

  wrapped.zathura = self.callPackage ../pkgs/zathura/wrapper.nix {
    configFile = self.configFiles.zathura;
  };

  adminEnv = with self; let
    version = "2018-06-18";
  in buildEnv {
    name = "admin-${version}-env";
    paths = [
      gptfdisk
      nvme-cli
      pciutils
      powertop
      usbutils
      xorg.xdpyinfo
      xorg.xev
    ];
  };

  consoleEnv = let
    version = "2021-05-31";
  in self.buildEnv {
    name = "console-${version}-env";
    paths = with self; [
      configFiles.fish
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
      wrapped.direnv
      sl
      htop
      glow
      pubs
    ] ++ lib.optionals stdenv.isLinux [
      trash-cli
      xsel
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.trash
      reattach-to-user-namespace
    ];
    meta.priority = 6;
  };

  neovimEnv = let
    # neovim = self.wrapped.neovim;
    neovim = self.neovim-nightly;
  in
  self.buildEnv {
    name = "${neovim.name}-env";
    paths = with self; [
      wrapped.aspell
      wrapped.ctags
      neovim
      tree-sitter   # required to compile tree-sitter parsers
      stdenv.cc.cc  # required to compile tree-sitter parsers
      nodejs        # required to compile tree-sitter parsers
      skim
    ];
  };

  desktopEnv = with self; let
    version = "2020-06-01";
  in buildEnv {
    name = "desktop-${version}-env";
    paths = lib.optionals stdenv.isLinux [
      # latest.firefox-nightly-bin
      wrapped.zathura
      # mgenplus
      # rounded-mgenplus
      # slack
      # tdesktop
    ] ++ lib.optionals stdenv.isDarwin [
    ];
  };
}
