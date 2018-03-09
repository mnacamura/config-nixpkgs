{ stdenv, makeWrapper, cacert, curl, git, pkgconfig, libxml2, libxslt, libpng, freetype,
python36Packages, python36 }:

stdenv.mkDerivation rec {
  name = "jupyter-${version}-env";
  version = "2018-03-09";

  nativeBuildInputs = [
    makeWrapper
    cacert
    curl
    git
    pkgconfig
    python36Packages.pip
  ];

  buildInputs = with python36Packages; [
    python36 virtualenv
  ];

  phases = [ "installPhase" ];

  installPhase = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    venv=$out/var/venvs/jupyter
    pip="pip --cache-dir=/nix/var/cache/python"
    mkdir -p $venv
    # Set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH=$(date +%s)
    virtualenv --no-setuptools $venv
    source $venv/bin/activate

    # Install JupyterLab
    $pip install jupyterlab
    jupyter serverextension enable --py jupyterlab --sys-prefix

    # Install full MathJax including more fonts
    mathjax_ver="2.7.3"
    pushd $venv/lib/python3.6/site-packages/notebook/static/components
    rm -rf MathJax
    curl -LO https://github.com/mathjax/MathJax/archive/$mathjax_ver.tar.gz
    tar zxf $mathjax_ver.tar.gz
    mv MathJax-$mathjax_ver MathJax
    rm -f $mathjax_ver.tar.gz
    popd

    for bin in $venv/bin/jupyter; do
        makeWrapper $bin $out/bin/$(basename $bin) \
            --run "source $venv/bin/activate"
    done
  '';
}
