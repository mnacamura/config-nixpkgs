{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nix-repl
  ];
  environment.variables.EDITOR = "vim";  # Available by default on macOS

  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];

  services.nix-daemon.enable = true;

  nix.trustedUsers = [ "@admin" ];
  # nix.useSandbox = true;  # still does not work 2018-01-20
  nix.package = pkgs.nix;
  nix.maxJobs = 4;
  nix.nixPath = [
    "darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix"
    "darwin=$HOME/.nix-defexpr/channels/darwin"
    "nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs"
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 2;
}
