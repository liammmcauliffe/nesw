{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 20;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
  };
  xdg.configFile."hypr" = {
    source = ./.;
    recursive = true;
  };

  # autostart deps (see config/execs.lua)
  home.packages = with pkgs; [
    wl-clipboard # wl-paste
    cliphist     # clipboard history
    trash-cli    # trash-empty
    glib         # gsettings
  ];

  # polkit auth agent (hyprland has no DE to autostart one)
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      WantedBy = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # night light (uses system geoclue2 for location)
  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    temperature = {
      day = 5500;
      night = 3700;
    };
  };
}
