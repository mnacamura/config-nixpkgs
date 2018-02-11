{
  allowUnfree = true;
  # allowBroken = true;

  packageOverrides = super: let self = super.pkgs; in {

    consoleEnv = with self; lib.lowPrio (buildEnv {
      name = "console-env";
      ignoreCollisions = true;
      paths = [
        (aspellWithDicts (ps: with ps; [ en ]))
        binutils.bintools
        bzip2
        ccache
        coreutils
        diffutils
        fd
        findutils
        fortune
        gawk
        git
        gnugrep
        gnumake
        gnused
        gnutar
        gzip
        neovim
        p7zip
        parallel-rust
        patch
        # patdiff
        ripgrep
        skim
        sl
        tmux
        tree
        universal-ctags
        unrar
        vim-vint
        xz
      ] ++ lib.optionals stdenv.isDarwin [
        reattach-to-user-namespace
      ] ++ lib.optionals stdenv.isLinux [
        patdiff
        trash-cli
        xsel
      ];
    });

    ccacheWrapper = with super; ccacheWrapper.override {
      extraConfig = ''
        export CCACHE_COMPRESS=1
        export CCACHE_DIR=/var/cache/ccache
        export CCACHE_UMASK=007
      '';
    };

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
    };
    version = lib.getVersion myTexlive; in buildEnv {
      name = "texlive-${version}-env";
      paths = [
        ghostscript  # required by LaTeXiT
        myTexlive
      ] ++ (with haskellPackages; [
        pandoc
        pandoc-citeproc
        pandoc-crossref
      ]);
    };

    jupyterEnv = with self; stdenv.mkDerivation rec {
      name = "jupyter-${version}-env";
      version = "2018-02-11";
      nativeBuildInputs = [
        makeWrapper
        pkgconfig
      ];
      buildInputs = [
        libxml2 libxslt  # dependencies for lxml
        libpng freetype  # dependencies for matplotlib
        rEnv
        rPackages.JuniperKernel  # required to install the logo image
      ] ++ (with python36Packages; [
        python36 pip virtualenv
      ]);
      unpackPhase = ":";
      installPhase = ''
        venv=$out/var/venvs/jupyter
        pip="pip --cache-dir=/var/cache/wheel"
        mkdir -p $venv
        # Set SOURCE_DATE_EPOCH so that we can use python wheels
        SOURCE_DATE_EPOCH=$(date +%s)
        virtualenv --no-setuptools $venv
        source $venv/bin/activate
        $pip install jupyter jupyter_contrib_nbextensions
        jupyter contrib nbextension install --sys-prefix
        $pip install jupyterthemes

        # Install JuniperKernerl
        # `jupyter kernelspec install` does not work somehow, so we have to
        # install the kernel manually
        kspec=$venv/share/jupyter/kernels/juniper
        mkdir -p $kspec
        cat << JSON > $kspec/kernel.json
        {
          "argv": ["${rEnv}/bin/R", "--slave", "-e", "JuniperKernel::bootKernel()", "--args", "{connection_file}"],
          "display_name": "${rEnv.name} (Juniper)",
          "language": "R"
        }
        JSON
        chmod 444 $kspec/kernel.json
        ln -s ${rPackages.JuniperKernel}/library/JuniperKernel/extdata/logo-64x64.png $kspec/

        for bin in $venv/bin/{jupyter,jt}; do
            makeWrapper $bin $out/bin/$(basename $bin) --run "source $venv/bin/activate"
        done
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
    };
    version = lib.getVersion R; in buildEnv {
      name = "R-${version}-env";
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

    rustEnv = with self;
    let version = rustc.version; in buildEnv {
      name = "rust-${version}-env";
      paths = [
        cargo
        rustc
        # rustfmt
        # rustracer
      ];
    };

    nodejsEnv = with self;
    let version = nodejs.version; in buildEnv {
      name = "nodejs-${version}-env";
      paths = [
        nodejs
        yarn
      ];
    };
  };
}
