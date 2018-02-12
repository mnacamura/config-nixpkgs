{ stdenv, makeWrapper, pkgconfig, libxml2, libxslt, libpng, freetype,
python36Packages, python36 }:

stdenv.mkDerivation rec {
  name = "jupyter-${version}-env";
  version = "2018-02-12";

  nativeBuildInputs = [
    makeWrapper
    pkgconfig
  ];

  buildInputs = [
    libxml2 libxslt  # dependencies for lxml
    libpng freetype  # dependencies for matplotlib
  ] ++ (with python36Packages; [ python36 pip virtualenv ]);

  phases = [ "installPhase" ];

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
    for bin in $venv/bin/{jupyter,jt}; do
        makeWrapper $bin $out/bin/$(basename $bin) \
            --run "source $venv/bin/activate"
    done
  '';
}
