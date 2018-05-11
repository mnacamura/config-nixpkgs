{ R, rWrapper, rPackages }:

let
  packages = with rPackages; [
    # Package development
    devtools lintr roxygen2 testthat

    # Tidyverse
    dplyr forcats ggplot2 glue jsonlite lubridate magrittr purrr readr readxl
    tibble tidyr

    # RStan
    rstan rstantools
    usethis  # required by rstantools::rstan_package_skeleton

    # Publication
    rmarkdown revealjs

    # Others
    GGally JuniperKernel doParallel
  ];

in

(rWrapper.override ({ inherit packages; })).overrideAttrs (old: {
  name = "${R.name}-env";

  installPhase = old.installPhase + ''
    # Install info and man pages
    (
      cd ${R}
      for path in $(find share/{info,man}); do
        dest="$out/$path"
        if [ -d "$path" ]; then
          [ -d "$dest" ] || mkdir -p "$dest"
        else
          ln -s "${R}/$path" "$dest"
        fi
      done
    )
  '';

  postBuild = ''
    # Install JuniperKernerl
    kspec="$out/share/jupyter/kernels/juniper-${R.name}"
    mkdir -p "$kspec"
    cat << EOF > "$kspec/kernel.json"
    {
    "language": "R",
    "display_name": "${R.name} (Juniper)",
    "argv": ["$out/bin/R", "--slave", "-e", "JuniperKernel::bootKernel()", "--args", "{connection_file}"]
    }
    EOF
    ln -s ${rPackages.JuniperKernel}/library/JuniperKernel/extdata/logo-64x64.png "$kspec"
  '';
})
