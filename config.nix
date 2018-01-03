{
  allowUnfree = true;
  # allowBroken = true;

  packageOverrides = super: let self = super.pkgs; in {
    myUtils = with self; lib.lowPrio (buildEnv {
      name = "my-utils";
      ignoreCollisions = true;
      paths = [
        (aspellWithDicts (ps: with ps; [ en ]))
        coreutils
        fd
        fortune
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
        rust-parallel
        sl
        tmux
        tree
        unrar
      ] ++ lib.optionals stdenv.isDarwin [
        gnome-breeze        # used by GNU Cash
        reattach-to-user-namespace
      ];
    });

    publishEnv = with self; let myTexlive = texlive.combine {
      inherit (texlive)
      scheme-small
      collection-latexrecommended
      collection-latexextra
      collection-fontutils
      latexmk;
    }; in buildEnv {
      name = "publish-env";
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
      version = "2018-01-01";  # Just for convenience to upgrade packages
      nativeBuildInputs = [ makeWrapper ];
      buildInputs = with python36Packages; [ python36 pip virtualenv ];
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
      '';
    };

    rEnv = with self; let myR = rWrapper.override {
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

        ## Jupyter kernel
        JuniperKernel
      ];
    }; in buildEnv {
      name = "${R.name}-env";
      paths = [
        gettext  # required by rstan
        myR
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

    nodejsEnv = with self; buildEnv {
      name = "nodejs-${nodejs.version}-env";
      paths = [
        nodejs
        yarn
      ];
    };
  };
}
