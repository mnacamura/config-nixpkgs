{ stdenv, makeWrapper, pkgconfig, libxml2, libxslt, libpng, freetype,
python3, mathjax }:

stdenv.mkDerivation rec {
  name = "jupyter-${version}-env";
  version = "2018-05-04";

  nativeBuildInputs = [ makeWrapper pkgconfig ];

  buildInputs = [
    libxml2 libxslt  # dependencies for lxml
    libpng freetype  # dependencies for matplotlib
    (python3.withPackages (ps: with ps; [ pip virtualenv ]))
    mathjax
  ];

  buildCommand = ''
    PIP="pip --cache-dir=/var/cache/python"

    # Set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH="$(date +%s)"

    venv="$out/libexec/jupyter-venv"
    mkdir -p "$venv"
    virtualenv "$venv"
    source "$venv/bin/activate"

    # Install Jupyter and extensions
    $PIP install jupyter jupyter_contrib_nbextensions
    jupyter contrib nbextension install --sys-prefix
    $PIP install jupyterthemes

    # Install JupyterLab
    # TODO: Plot does not render in jupyterlab
    $PIP install jupyterlab
    jupyter serverextension enable --py jupyterlab --sys-prefix

    # Install full MathJax including more fonts
    (
      cd "$venv/lib/${python3.libPrefix}/site-packages/notebook/static/components"
      rm -r MathJax
      ln -s ${mathjax}/lib/js/mathjax MathJax
    )

    for bin in "$venv"/bin/{jupyter*,jt}; do
      makeWrapper "$bin" "$out/''${bin#$venv}" \
        --run "source $venv/bin/activate"
    done
  '';
}
