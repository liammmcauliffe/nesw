{ config, pkgs, hyprland, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Host basics
  networking.hostName = "main"; # Must match the flake target
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable flakes on the installed system
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Wayland + Hyprland
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  programs.fish.enable = true;

  # Basic packages
  environment.systemPackages = with pkgs; [
    git
    tree-sitter
    app2unit
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # HARDCODE YOUR USERNAME HERE (e.g. "liam")
  users.users."liam" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  # Needed if you want to use sudo
  security.sudo.enable = true;

  system.stateVersion = "25.11";
}
