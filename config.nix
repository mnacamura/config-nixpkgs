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
        # devtools  # does not work for some reason
        foreach
        rstan

        ## devtools dependency
        curl
        git2r
        httr
        jsonlite
        memoise
        mime
        openssl
        rstudioapi
        whisker
        withr
      ];
    };
  };
}
