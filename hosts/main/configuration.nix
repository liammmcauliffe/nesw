{ config, pkgs, hyprland, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Host basics
  networking.hostName = "main";
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable flakes on the installed system
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  # Basic packages
  environment.systemPackages = with pkgs; [
    git
    neovim
    ghostty
  ];

  # Replace this user block with your real username before rebuild
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.bash;
  };
  # Keep Home Manager user in flake.nix in sync with this username.

  # Needed if you want to use sudo
  security.sudo.enable = true;

  system.stateVersion = "24.11";
}
