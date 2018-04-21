{ R, rWrapper, rPackages }:

(rWrapper.override ({
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
})).overrideAttrs (old: {
  name = "${R.name}-env";

  installPhase = old.installPhase + ''
    # Install info and man pages
    for path in `find ${R}/share`; do
      dest=$out/''${path#${R}}
      if [ -d $path ]; then
        [ -d $dest ] || mkdir -p $dest
      else
        ln -s $path $dest
      fi
    done
  '';

  postBuild = ''
    # Install JuniperKernerl
    kspec=$out/share/jupyter/kernels/juniper-${R.name}
    mkdir -p $kspec
    cat << JSON > $kspec/kernel.json
    {
    "argv": ["$out/bin/R", "--slave", "-e", "JuniperKernel::bootKernel()", "--args", "{connection_file}"],
    "display_name": "${R.name} (Juniper)",
    "language": "R"
    }
    JSON
    chmod 444 $kspec/kernel.json
    ln -s ${rPackages.JuniperKernel}/library/JuniperKernel/extdata/logo-64x64.png $kspec/
  '';
})
