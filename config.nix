{
  allowUnfree = true;
  # allowBroken = true;

  packageOverrides = super: let self = super.pkgs; in {

    consoleEnv = with self; lib.lowPrio (buildEnv {
      name = "console-env";
      ignoreCollisions = true;
      paths = [
        (aspellWithDicts (ps: with ps; [ en ]))
        fd
        fortune
        git
        gnumake
        neovim
        p7zip
        parallel-rust
        # patdiff
        ripgrep
        skim
        sl
        tmux
        tree
        universal-ctags
        unrar
        vim-vint
      ] ++ lib.optionals stdenv.isDarwin [
        reattach-to-user-namespace
      ] ++ lib.optionals stdenv.isLinux [
        patdiff
        trash-cli
        xsel
      ];
    });

    neovim = with super; neovim.override {
      withRuby = false;
      configure = {
        customRC = ''
          let $MYVIMRC = $HOME . '/.config/nvim/init.vim'
          if filereadable($MYVIMRC)
            source $MYVIMRC
          else
            echomsg 'Warning: ' . $MYVIMRC . ' is not readable'
          endif
        '';
        packages.default = with vimPlugins; {
          start = [ skim ];
          opt = [];
        };
      };
    };

    desktopEnv = with self; buildEnv {
      name = "desktop-env";
      ignoreCollisions = true;
      paths = lib.optionals stdenv.isDarwin [
        gnome-breeze  # used by GNU Cash
      ] ++ lib.optionals stdenv.isLinux [
        dropbox-cli
        firefox-devedition-bin
        gimp
        inkscape
        kdeApplications.okular
        kdeApplications.spectacle
        mathematica
      ];
    };

    mathematica = super.mathematica.override { lang = "ja"; };

    texliveEnv = with self; let myTexlive = texlive.combine {
      inherit (texlive)
      scheme-basic  # installs collection-{basic,latex}
      collection-luatex
      collection-latexrecommended
      collection-latexextra
      collection-bibtexextra
      collection-fontsrecommended
      collection-fontsextra
      collection-fontutils
      collection-langjapanese
      latexmk
      latexdiff
      revtex;
    }; in buildEnv {
      name = "texlive-env";
      paths = [
        ghostscript  # required by LaTeXiT
        myTexlive
      ] ++ (with haskellPackages; [
        pandoc
        pandoc-citeproc
        pandoc-crossref
      ]);
    };

    jupyterEnv = with self; stdenv.mkDerivation {
      name = "jupyter-env";
      version = "2018-02-02";  # Just for convenience to upgrade packages
      nativeBuildInputs = [ makeWrapper ];
      buildInputs = [
        libxml2 libxslt  # dependencies for lxml
      ] ++ (with python36Packages; [
        python36 pip virtualenv
      ]);
      phases = [ "installPhase" ];
      installPhase = ''
        venv=$out/var/venvs/jupyter
        mkdir -p $venv
        # set SOURCE_DATE_EPOCH so that we can use python wheels
        SOURCE_DATE_EPOCH=$(date +%s)
        virtualenv --no-setuptools $venv
        source $venv/bin/activate
        pip --no-cache-dir install jupyter jupyter_contrib_nbextensions
        jupyter contrib nbextension install --sys-prefix
        makeWrapper $venv/bin/jupyter $out/bin/jupyter \
          --run "source $venv/bin/activate"
        pip --no-cache-dir install jupyterthemes
      '';
    };

    rEnv = with self; let myR = rWrapper.override {
      packages = with rPackages; [
        GGally
        JuniperKernel
        doParallel
        dplyr
        forcats
        foreach
        ggplot2
        glue
        hms
        jsonlite
        lubridate
        magrittr
        purrr
        readr
        readxl
        rlang
        rstan
        stringr
        tibble
        tidyr
      ];
    }; in buildEnv {
      name = "r-env";
      paths = [
        (lib.lowPrio R)  # installs man pages etc.
        myR
      ];
    };

    juliaEnv = with self; let julia = julia_06; in buildEnv {
      name = "${julia.name}-env";
      paths = [
        julia
      ];
    };

    julia_06 = with super; julia_06.overrideAttrs (as: with as; {
      ## Required to use ZMQ on NixOS
      LD_LIBRARY_PATH = if !stdenv.isDarwin
        then "${zlib}/lib:${LD_LIBRARY_PATH}"
        else LD_LIBRARY_PATH;

      ## FIXME: Running socket test says "UDP send failed: network is unreachable"
      doCheck = false;
    });

    rustEnv = with self; buildEnv {
      name = "rust-env";
      paths = [
        cargo
        rustc
        # rustfmt
        # rustracer
      ];
    };

    nodeEnv = with self; buildEnv {
      name = "node-env";
      paths = [
        nodejs
        yarn
      ];
    };
  };
}
