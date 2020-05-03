{ stdenv, fetchFromGitHub, gettext, python3
, wrapGAppsHook, gtk3, gobject-introspection
}:

stdenv.mkDerivation rec {
  pname = "themix-gui";
  version = "1.13.2";

  src = fetchFromGitHub {
    owner = "themix-project";
    repo = "oomox";
    rev = version;
    sha256 = "1sdnyns3xby2shjy7xa3m9zpbj2g7zydpzlvwc7qqanalwh1xqbn";
  };

  postPatch = ''
    patchShebangs .
    for path in packaging/bin/*; do
        sed -i "$path" -e "s@\(/opt/oomox/\)@$out\1@"
        sed -i "$path" -e "s@exec \(python3\)@exec ${python3}/bin/\1@"
    done

    # No need to remove .git*
    sed -i Makefile -e '/$(RM) -r .\+\.git\*/d'
  '';

  nativeBuildInputs = [ wrapGAppsHook ];

  buildInputs = [ gettext gtk3 gobject-introspection ] ++

  # propagatedBuildInputs =
    [ python3 ] ++ (with python3.pkgs; [ pygobject3 ]);

  buildPhase = ''
    runHook preBuild
    python -O -m compileall oomox_gui
    runHook postBuild
  '';

  doCheck = false; 

  installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  installTargets = "install_gui";

  postInstall = ''
    sed -i "$out/share/applications/com.github.themix_project.Oomox.desktop" \
        -e "s@Exec=\(oomox-gui\)@Exec=$out/bin/\1@"
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix PYTHONPATH : "$PYTHONPATH")
  '';

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "Plugin-based theme designer GUI for desktop environments";
    platforms = platforms.all;
    maintainers = with maintainers; [ mnacamura ];
    license = licenses.gpl3;
  };
}
