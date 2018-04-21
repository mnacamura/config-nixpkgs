{ stdenv, makeWrapper, pkgconfig, python36, mathjax }:

stdenv.mkDerivation rec {
  name = "jupyter-${version}-env";
  version = "2018-04-21";

  nativeBuildInputs = [
    makeWrapper
    pkgconfig
  ];

  buildInputs = [
    (python36.withPackages (ps: with ps; [
      pip
      virtualenv
    ]))
    mathjax
  ];

  buildCommand = ''
    pip="pip --cache-dir=/var/cache/python"

    # Set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH=$(date +%s)

    venv=$out/var/venvs/jupyter
    mkdir -p $venv
    virtualenv $venv
    source $venv/bin/activate

    # Install JupyterLab
    $pip install jupyterlab
    jupyter serverextension enable --py jupyterlab --sys-prefix

    # Install full MathJax including more fonts
    pushd $venv/lib/python3.6/site-packages/notebook/static/components
    rm -rf MathJax
    ln -s ${mathjax}/share/MathJax
    popd

    for bin in $venv/bin/jupyter*; do
        makeWrapper $bin $out/bin/$(basename $bin) \
            --run "source $venv/bin/activate"
    done
  '';
}
