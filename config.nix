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

    pandocEnv = with self; buildEnv (with haskellPackages; {
      name = "pandoc-${pandoc.version}-env";
      paths = [
        pandoc
        pandoc-citeproc
        pandoc-crossref
      ];
    });

    pythonEnv = with self; python36.withPackages (ps: with ps;
      builtins.filter (p: p != null) [
      pip
      (if !stdenv.isDarwin then jupyter else null)
    ]);

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
        rustfmt
        rustracer
      ];
    };
  };
}
