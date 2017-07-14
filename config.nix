{
  allowUnfree = true;

  packageOverrides = super: let self = super.pkgs; in {
    texliveEnv = with self; texlive.combine {
      inherit (texlive)
      scheme-small
      collection-latexrecommended
      collection-latexextra
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

    pythonEnv = self.python36.withPackages (ps: with ps; [
      pip
      # jupyter
    ]);

    rEnv = with self; rWrapper.override {
      packages = with rPackages; [
        ## The tidyverse packages
        dplyr
        forcats
        ggplot2
        # haven
        lubridate
        magrittr
        purrr
        readr
        # readxl
        stringr
        tibble
        tidyr

        ## Misc
        GGally
        devtools
        foreach
        rstan

        ## Jupyter IRkernel dependencies
        repr
        evaluate
        IRdisplay
        pbdZMQ
        crayon
        jsonlite
        uuid
        digest
      ];
    };

    juliaEnv = with self; buildEnv {
      name = "julia-${julia_05.version}-env";
      paths = [
        julia_05
      ];
    };

    julia_05 = with super; julia_05.overrideAttrs (as: with as; {
      ## Required to use ZMQ on NixOS
      LD_LIBRARY_PATH = if !stdenv.isDarwin
        then "${zlib}/lib:${LD_LIBRARY_PATH}"
        else LD_LIBRARY_PATH;
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
