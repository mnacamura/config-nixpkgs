{ stdenv, buildEnv, R, rWrapper, rPackages }:

let
  myR = rWrapper.override {
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

  version = stdenv.lib.getVersion R;
in

buildEnv rec {
  name = "R-${version}-env";

  ignoreCollisions = true;

  pathsToLink = [ "/bin" "/lib" "/share" ];

  paths = [
    (stdenv.lib.lowPrio R)  # installs man pages etc.
    myR
  ];

  postBuild = ''
    # Install JuniperKernerl
    kspec=$out/share/jupyter/kernels/juniper-r-${version}
    mkdir -p $kspec
    cat << JSON > $kspec/kernel.json
    {
      "argv": ["$out/bin/R", "--slave", "-e", "JuniperKernel::bootKernel()", "--args", "{connection_file}"],
      "display_name": "${name} (Juniper)",
      "language": "R"
    }
    JSON
    chmod 444 $kspec/kernel.json
    ln -s ${rPackages.JuniperKernel}/library/JuniperKernel/extdata/logo-64x64.png $kspec/
  '';
}
