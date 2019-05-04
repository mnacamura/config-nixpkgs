{ stdenvNoCC, writeText, fontforge, source-code-pro, rounded-mgenplus }:

let
  pname = "rounded-sgenplus";

  builder = writeText "${pname}-builder" ''
    import os, fontforge
    recipes = [
        {
            "fontname":   "${pname}-1m-regular",
            "familyname": "Rounded Sgen+ 1m",
            "fullname":   "Rounded Sgen+ 1m Regular",
            "src_lt":     "${source-code-pro}/share/fonts/opentype/SourceCodePro-Regular.otf",
            "src_jp":     "${rounded-mgenplus}/share/fonts/rounded-mgenplus/rounded-mgenplus-1m-regular.ttf"
        },
        {
            "fontname":   "${pname}-1m-italic",
            "familyname": "Rounded Sgen+ 1m",
            "fullname":   "Rounded Sgen+ 1m Italic",
            "src_lt":     "${source-code-pro}/share/fonts/opentype/SourceCodePro-It.otf",
            "src_jp": "${rounded-mgenplus}/share/fonts/rounded-mgenplus/rounded-mgenplus-1m-medium.ttf"
        },
        {
            "fontname":   "${pname}-1m-bold",
            "familyname": "Rounded Sgen+ 1m",
            "fullname":   "Rounded Sgen+ 1m Bold",
            "src_lt": "${source-code-pro}/share/fonts/opentype/SourceCodePro-Bold.otf",
            "src_jp": "${rounded-mgenplus}/share/fonts/rounded-mgenplus/rounded-mgenplus-1m-bold.ttf"
        },
        {
            "fontname":   "${pname}-2m-regular",
            "familyname": "Rounded Sgen+ 2m",
            "fullname":   "Rounded Sgen+ 2m Regular",
            "src_lt":     "${source-code-pro}/share/fonts/opentype/SourceCodePro-Regular.otf",
            "src_jp":     "${rounded-mgenplus}/share/fonts/rounded-mgenplus/rounded-mgenplus-2m-regular.ttf"
        },
        {
            "fontname":   "${pname}-2m-italic",
            "familyname": "Rounded Sgen+ 2m",
            "fullname":   "Rounded Sgen+ 2m Italic",
            "src_lt":     "${source-code-pro}/share/fonts/opentype/SourceCodePro-It.otf",
            "src_jp": "${rounded-mgenplus}/share/fonts/rounded-mgenplus/rounded-mgenplus-2m-medium.ttf"
        },
        {
            "fontname":   "${pname}-2m-bold",
            "familyname": "Rounded Sgen+ 2m",
            "fullname":   "Rounded Sgen+ 2m Bold",
            "src_lt": "${source-code-pro}/share/fonts/opentype/SourceCodePro-Bold.otf",
            "src_jp": "${rounded-mgenplus}/share/fonts/rounded-mgenplus/rounded-mgenplus-2m-bold.ttf"
        },
    ]
    for recipe in recipes:
        lt = fontforge.open(recipe["src_lt"])
        lt.em = 1024
        lt.generate("lt.ttf")
        lt.close
        jp = fontforge.open(recipe["src_jp"])
        jp.em = 1024
        jp.generate("jp.ttf")
        jp.close
        dest = fontforge.open("lt.ttf")
        dest.mergeFonts("jp.ttf")
        dest.fontname = recipe["fontname"]
        dest.familyname = recipe["familyname"]
        dest.fullname = recipe["fullname"]
        dest.generate(dest.fontname + ".ttf")
        dest.close
        os.remove("lt.ttf")
        os.remove("jp.ttf")
  '';
in

stdenvNoCC.mkDerivation rec {
  name = "${pname}-${version}";
  version = "2019-05-04";

  nativeBuildInputs = [ fontforge ];

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    fontforge -script ${builder}
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/${pname}
    install -m 444 -D -t $out/share/fonts/${pname} *.ttf
  '';

  meta = with stdenvNoCC.lib; {
    description = "A Japanese monospace font based on Rounded Mgen+ and Source Code Pro";
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = with maintainers; [ mnacamura ];
  };
}
