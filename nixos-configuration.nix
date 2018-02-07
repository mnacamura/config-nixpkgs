# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use kernel 4.15.
  boot.kernelPackages = pkgs.linuxPackages_4_15;

  networking.hostName = "sagnier"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.enableIPv6 = true;
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "ja_JP.UTF-8";
    inputMethod = {
       enabled = "fcitx";
       fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    } ;
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Fonts
  fonts = {
    fonts = with pkgs; [
      cantarell_fonts
      noto-fonts-cjk
      source-code-pro
      fira-code
    ];
    # fontconfig = {
    #   defaultFonts = {
    #     serif = [
    #     ];
    #     sansSerif = [
    #     ];
    #     monospace = [
    #       "Source Code Pro"
    #       "Fira Code"
    #     ];
    #   };
    # };
  };

  # Nix options
  nix.trustedUsers = [ "@wheel" ];
  # nix.useSandbox = "true";
  nix.package = pkgs.nixUnstable;
  nix.maxJobs = 4;
  nix.buildCores = 6;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    nix-repl
  ];
 
  # List services that you want to enable:

  # Enable the fish shell.
  programs.fish.enable = true;
  
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 17886 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.videoDrivers = [ "amdgpu" ];
  # services.xserver.resolutions = [ { x = 1920; y = 1080; } ];
  # services.xserver.xkbOptions = "eurosign:e";
  services.xserver.serverFlagsSection =
    ''
    Option "BlankTime"   "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime"     "0"
    '';

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.mnacamura = {
    isNormalUser = true;
    description = "Mitsuhiro Nakamura";
    createHome = true;
    extraGroups = [ "wheel" "networkmanager" ];
    uid = 1000;
    shell = "/run/current-system/sw/bin/fish";
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwsh6tCcIYa86dD6m2hy4n1bSttp+zqwn2ptvUtHbuVbymNvOcD449lSwDXV4ATfAyowC9cTfUXFicPtpNfq5BUS1ln3XN8L5KcJdGXM8JiD7J/kdzVZf6yyLhBZDUzcfoXNpsxaB2Cln1fB6ym3a1Npa9rw0k40KpA7vqp26eo+r7iJCcO8BOxlUYie6fCOD5jSE0DHNBe8NLQ2v6M1seq9FSNSbeijh5yu/bT+gjkqQYboN5pkVvb8xncsXUuanKP8R+fvTAPx9CwHMPPrZtG2iEoMoKsK0Eiiq9wDl/UyueMXlwNl/ei7qnV3zxNzxWGsmBI2f091l0AFXeerEj mnacamura@suzon.local" ];
  };

  # Keep the NixOS system up-to-date.
  # system.autoUpgrade.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";

}
