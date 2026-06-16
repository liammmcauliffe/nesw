{ ... }:
{
  imports = [
    ../../modules/themes
    ../../modules/shell/fish
    ../../modules/terminal/ghostty
    ../../modules/desktop/hyprland
    ../../modules/editors/nvim
    ../../modules/shell/starship
    ../../modules/browser/zen
    ../../modules/shell/tools
    ../../modules/desktop/quickshell
  ] ++ ( if builtins.pathExists ./local.nix then [ ./local.nix ] else []);
  # ^ for developmental purposes ^
}
