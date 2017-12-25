{
  allowUnfree = true;
  # allowBroken = true;

  packageOverrides = super: let self = super.pkgs; in {
    myUtils = with self; buildEnv {
      name = "my-utils";
      paths = [
        (aspellWithDicts (ps: with ps; [ en ]))
        coreutils
        fortune
        gettext             # required by rstan
        git
        gnumake
        imagemagick
        neovim
        nkf
        omake
        openssl
        p7zip
        # patdiff
        ripgrep
        sl
        tmux
        tree
        unrar
      ] ++ lib.optionals stdenv.isDarwin [
        gnome-breeze        # used by GNU Cash
        reattach-to-user-namespace
      ];
    };

    publishEnv = with self; buildEnv ({
      name = "publish-env";
      paths = [
        ghostscript                      # required by LaTeXiT
        haskellPackages.pandoc
        haskellPackages.pandoc-citeproc
        haskellPackages.pandoc-crossref
        texliveCustomized
      ];

    });

    texliveCustomized = with self; texlive.combine {
      inherit (texlive)
      scheme-small
      collection-latexrecommended
      collection-latexextra
      collection-fontutils
      latexmk;
    };

    jupyterEnv = with self; stdenv.mkDerivation {
      name = "jupyter-env";
      buildInputs = [
        python36
        python36Packages.pip
        python36Packages.virtualenv
      ];
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/venv/jupyter
        cd $out
        # set SOURCE_DATE_EPOCH so that we can use python wheels
        SOURCE_DATE_EPOCH=$(date +%s)
        virtualenv --no-setuptools venv/jupyter
        export PATH=venv/jupyter/bin:$PATH
        pip --no-cache-dir install jupyter jupyter_contrib_nbextensions
      '';
    };

    rEnv = with self; rWrapper.override {
      packages = with rPackages; [
        ## Development
        devtools

        ## tidyverse and related packages
        tidyverse
        readxl
        stringr
        lubridate
        forcats
        hms
        rlang
        magrittr
        GGally

        ## Parallel computing
        doParallel
        foreach

        ## Bayesian inference
        rstan

        ## Jupyter IRkernel dependencies
        IRdisplay
        crayon
        digest
        evaluate
        jsonlite
        pbdZMQ
        repr
        uuid
      ];
    };

    juliaEnv = with self; let julia = julia_06; in buildEnv {
      name = "julia-${julia.version}-env";
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
      name = "rust-${rustc.version}-env";
      paths = [
        cargo
        rustc
        # rustfmt
        # rustracer
      ];
    };
  };
}
