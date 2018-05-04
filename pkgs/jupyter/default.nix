{ stdenv, makeWrapper, pkgconfig, libxml2, libxslt, libpng, freetype,
python3, mathjax }:

stdenv.mkDerivation rec {
  name = "jupyter-${version}";
  version = "2018-05-05";

  nativeBuildInputs = [ makeWrapper pkgconfig ];

  buildInputs = [
    libxml2 libxslt  # dependencies for lxml
    libpng freetype  # dependencies for matplotlib
    (python3.withPackages (ps: with ps; [ pip virtualenv ]))
    mathjax
  ];

  buildCommand = ''
    PIP='pip --cache-dir=/var/cache/python'

    # Set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH="$(date +%s)"

    venv="$out/libexec/jupyter-venv"
    mkdir -p "$venv"
    virtualenv "$venv"
    . "$venv/bin/activate"

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

    (
      cd "$venv"
      for script in bin/{jupyter*,jt}; do
        makeWrapper "$venv/$script" "$out/$script" \
          --run ". \"$venv/bin/activate\""
      done
    )
  '';
}
