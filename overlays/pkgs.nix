self: super:

{
  terminalEnv = self.buildEnv {
    name = "terminal-env";
    paths = with self; [
      # p7zip
      # unrar
      glow
    ] ++ lib.optionals stdenv.isLinux [
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.trash
      reattach-to-user-namespace
    ];
    meta.priority = 6;
  };
}
