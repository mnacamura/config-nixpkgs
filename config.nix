{
  allowUnfree = true;

  packageOverrides = super: let self = super.pkgs; in {
    tlEnv = super.texlive.combine {
      inherit (super.texlive)
      scheme-small
      collection-latexrecommended
      collection-latexextra
      latexmk;
    };

    hsEnv = super.haskellPackages.ghcWithPackages (ps: with ps; [
      pandoc
      pandoc-citeproc
      pandoc-crossref
    ]);

    pyEnv = super.python36.withPackages (ps: with ps; [
      pip
      # jupyter
    ]);

    rEnv = super.rWrapper.override {
      packages = with self.rPackages; [
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

    julia_05 = super.julia_05.overrideAttrs (as: with as; {
      ## Required to use ZMQ on NixOS
      LD_LIBRARY_PATH = if !super.stdenv.isDarwin
        then "${super.zlib}/lib:${LD_LIBRARY_PATH}"
        else LD_LIBRARY_PATH;

      ## FIXME: Running test says "UDP send failed: network is unreachable"
      doCheck = false;
    });
  };
}
