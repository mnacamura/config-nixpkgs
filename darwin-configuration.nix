{ config, lib, pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    nix-repl
  ];
  environment.variables.EDITOR = "vim";  # Available by default on macOS

  # Create /etc/fish that loads the nix-darwin environment.
  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];
  environment.variables.SHELL = "/run/current-system/sw/bin/fish";

  # Recreate /run/current-system symlink after boot.
  services.activate-system.enable = true;
  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 2;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 4;

  # Customize $NIX_PATH
  nix.nixPath = [
    "nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs"
    "darwin=$HOME/.nix-defexpr/channels/darwin"
    "darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
    "$HOME/.nix-defexpr/channels"
  ];
}
