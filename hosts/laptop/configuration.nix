{ config, pkgs, hyprland, userName, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/themes
  ] ++ (if builtins.pathExists ./local.nix then [ ./local.nix ] else []);

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # host basics
  networking.hostName = "main"; # must match the flake target
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # enable flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # wayland + hyprland
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  programs.fish.enable = true;

  # polkit + keyring
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # location for gammastep
  services.geoclue2.enable = true;
  services.geoclue2.appConfig.gammastep = {
    isAllowed = true;
    isSystem = false;
  };
  location.provider = "geoclue2";

  # bluetooth
  hardware.bluetooth.enable = true;

  services.upower.enable = true;

  # basic packages
  environment.systemPackages = with pkgs; [
    git
    tree-sitter
    app2unit
    grim
    slurp
  ];

  # fonts (families driven by nesw.theme — override in hosts/*/local.nix)
  fonts.packages = let
    fonts = config.nesw.theme.fonts;
  in with pkgs; [
    # UI (shell/notch/clock); pkgs.dm-sans is not this font, it ships
    # "DeepMind Sans" — the real DM Sans comes from google-fonts
    (google-fonts.override { fonts = [ fonts.sansSerif ]; })
    monaspace # terminal/editor (Monaspace Neon)
    nerd-fonts.jetbrains-mono
  ];

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  # sudo
  security.sudo.enable = true;

  system.stateVersion = "25.11";
}
