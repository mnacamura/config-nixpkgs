{ stdenv, makeWrapper, cacert, git, pkgconfig, libxml2, libxslt, libpng, freetype,
python36Packages, python36 }:

stdenv.mkDerivation rec {
  name = "jupyter-${version}-env";
  version = "2018-02-12";

  nativeBuildInputs = [
    makeWrapper
    cacert
    git
    pkgconfig
    python36Packages.pip
  ];

  buildInputs = [
    libxml2 libxslt  # dependencies for lxml
    libpng freetype  # dependencies for matplotlib
  ] ++ (with python36Packages; [ python36 virtualenv ]);

  phases = [ "installPhase" ];

  installPhase = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
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
    jupyter nbextension install \
        https://raw.githubusercontent.com/lambdalisue/jupyter-vim-binding/master/vim_binding.js \
        --nbextensions=$venv/share/jupyter/nbextensions/vim_binding
    # Install full MathJax including more fonts
    pushd $venv/lib/python3.6/site-packages/notebook/static/components
    rm -r MathJax
    git clone https://github.com/mathjax/MathJax.git
    popd
    for bin in $venv/bin/{jupyter,jt}; do
        makeWrapper $bin $out/bin/$(basename $bin) \
            --run "source $venv/bin/activate"
    done
  '';
}
