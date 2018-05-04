{ stdenv, makeWrapper, writeText,
cacert, git, mbedtls, zlib, zeromq3, julia, jupyter,
libpng, pixman, libffi, gettext, glib, freetype, fontconfig, cairo, pango,
}:

let
  extraLibs = [ mbedtls zlib zeromq3
    libpng pixman libffi gettext glib freetype fontconfig cairo pango.out
  ];

  majorMinor = version:
  with stdenv.lib;
  concatStringsSep "." (take 2 (splitString "." version));

  patches = with stdenv.lib; {
    ZMQ = writeText "ZMQ.patch" (readFile ./patches/ZMQ.patch);
    MbedTLS = writeText "MbedTLS.patch" (readFile ./patches/MbedTLS.patch);
    Rmath = writeText "Rmath.patch" (readFile ./patches/Rmath.patch);
    Cairo = writeText "Cairo.patch" (readFile ./patches/Cairo.patch);
  };
in

stdenv.mkDerivation rec {
  name = "julia-${version}-env";
  version = julia.version;

  nativeBuildInputs = [
    makeWrapper
    cacert
    git
    # pkgconfig
    # which
    jupyter
  ];

  buildInputs = [ julia ] ++ extraLibs;

  phases = [ "installPhase" ];

  installPhase = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    export LD_LIBRARY_PATH=${stdenv.lib.makeLibraryPath extraLibs}
    export JULIA_PKGDIR=$out/share/julia/site
    mkdir -p $JULIA_PKGDIR
    julia -e "Pkg.init()"
    pushd $JULIA_PKGDIR/v${majorMinor version}

    # Install ZMQ.jl manually to remove dependnecy to Homebrew.jl
    git clone https://github.com/JuliaInterop/ZMQ.jl.git ZMQ
    pushd ZMQ
    patch -p1 < ${patches.ZMQ}
    julia -e "Pkg.resolve(); Pkg.build(\"ZMQ\")"
    popd

    # Install MbedTLS.jl manually to remove dependnecy to Homebrew.jl
    git clone https://github.com/JuliaWeb/MbedTLS.jl.git MbedTLS
    pushd MbedTLS
    patch -p1 < ${patches.MbedTLS}
    julia -e "Pkg.resolve(); Pkg.build(\"MbedTLS\")"
    popd

    # Install Rmath.jl manually to remove dependnecy to xcode-select
    git clone https://github.com/JuliaStats/Rmath.jl.git Rmath
    pushd Rmath
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    patch -p1 < ${patches.Rmath}
  '' + ''
    julia -e "Pkg.resolve(); Pkg.build(\"Rmath\")"
    popd

    # Install Cairo.jl manually to remove dependnecy to Homebrew.jl
    git clone https://github.com/JuliaGraphics/Cairo.jl.git Cairo
    pushd Cairo
    patch -p1 < ${patches.Cairo}
    julia -e "Pkg.resolve(); Pkg.build(\"Cairo\")"
    popd

    export JUPYTER=${jupyter}/bin/jupyter
    export HOME=.
    julia -e "Pkg.add(\"IJulia\")"

    # Modify IJulia kernel
    kspec=$out/share/jupyter/kernels/julia-${majorMinor version}
    mkdir -p $kspec
    cat << JSON > $kspec/kernel.json
    {
      "argv": [
        "$out/bin/julia", "-i", "--startup-file=yes", "--color=yes",
        "$out/share/julia/site/v${majorMinor version}/IJulia/src/kernel.jl",
        "{connection_file}"
      ],
      "display_name": "${name} (IJulia)",
      "language": "julia"
    }
    JSON
    chmod 444 $kspec/kernel.json
    ln -s $JULIA_PKGDIR/v${majorMinor version}/IJulia/deps/logo-32x32.png $kspec/
    ln -s $JULIA_PKGDIR/v${majorMinor version}/IJulia/deps/logo-64x64.png $kspec/

    popd
    makeWrapper ${julia}/bin/julia $out/bin/julia \
        --prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH" \
        --set JULIA_LOAD_PATH $JULIA_PKGDIR/v${majorMinor version}
  '';
}
