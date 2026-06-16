{ lib, ... }:
let
  inherit (lib) mkOption types mkDefault;
in
{
  options.nesw.theme = {
    fonts = {
      sansSerif = mkOption {
        type = types.str;
        default = mkDefault "DM Sans";
        description = "UI font family (shell, notch, clock). Installed via google-fonts.";
      };

      monospace = mkOption {
        type = types.str;
        default = mkDefault "Monaspace Neon";
        description = "Terminal and editor monospace font family.";
      };

      monospaceNerd = mkOption {
        type = types.str;
        default = mkDefault "JetBrainsMono Nerd Font";
        description = "Nerd Font variant for terminal/editor icons.";
      };
    };

    colors = {
      primary = mkOption {
        type = types.str;
        default = mkDefault "e4e4e7";
        description = "Primary accent color (hex without #).";
      };

      onSurfaceVariant = mkOption {
        type = types.str;
        default = mkDefault "a1a1aa";
        description = "Muted on-surface variant color (hex without #).";
      };

      surface = mkOption {
        type = types.str;
        default = mkDefault "09090b";
        description = "Base surface/background color (hex without #).";
      };

      surfaceContainer = mkOption {
        type = types.str;
        default = mkDefault "1c1c1f";
        description = "Elevated surface container color (hex without #).";
      };
    };
  };
}
