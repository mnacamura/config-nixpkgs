self: super:

with self.lib;

{
  config = recursiveUpdate super.config {

    colortheme = let  #{{{
      inherit (super.config.colortheme) palette;

      nr = mapAttrs (_: c: c.nr) (filterAttrs (_: c: c ? nr) palette);

      hex = mapAttrs (_: c: c.hex) palette;

      has16Colors = let
        definedNames = attrNames palette;
        expectedNames = [
          "black"   "red"   "green"   "yellow"   "blue"   "magenta"   "cyan"   "white"
          "brblack" "brred" "brgreen" "bryellow" "brblue" "brmagenta" "brcyan" "brwhite"
        ];
      in
      all (n: elem n definedNames) expectedNames;

      hasHexColors = all (b: b) (mapAttrsToList (_: c: c ? hex) palette);

      hasValidXTermColorNr = all isXTermColorNr (attrValues nr);

      hasValidHexColorCode = all isHexColorCode (attrValues hex);

      isXTermColorNr = n: isInt n && 0 <= n && n < 256;

      isHexColorCode = s:
      let
        prefix = substring 0 1 s;
        body = substring 1 7 s;
      in
      stringLength s == 7 && prefix == "#" && isHexString body; 

      isHexString = let
        hexChars = stringToCharacters "0123456789abcdef";
      in
      s: all (c: elem c hexChars) (stringToCharacters (toLower s));
    in
    assert assertMsg has16Colors "colortheme: at least 16 colors should be defined";
    assert assertMsg hasHexColors "colortheme: color(s) with no hex value found";
    assert assertMsg hasValidXTermColorNr "colortheme: invalid xterm color number found";
    assert assertMsg hasValidHexColorCode "colortheme: invalid hex color code found";
    {
      inherit nr hex;
    };  #}}}

  };
}

# vim: fdm=marker
