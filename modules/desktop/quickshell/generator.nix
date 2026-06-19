# nesw-recolor - matugen wallpaper → ~/.local/state/nesw/scheme.json
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.quickshell.nesw;

  recolor = pkgs.writeShellScriptBin "nesw-recolor" ''
    set -euo pipefail
    wallpaper="''${1:?usage: nesw-recolor <wallpaper-path>}"
    scheme_dir="''${HOME}/.local/state/nesw"
    scheme_path="''${scheme_dir}/scheme.json"
    mkdir -p "$scheme_dir"
    ${pkgs.matugen}/bin/matugen image "$wallpaper" -m dark --json hex_stripped \
      | ${pkgs.jq}/bin/jq '
        def snake_to_camel:
          split("_")
          | .[0] + (.[1:] | map((.[0:1] | ascii_upcase) + .[1:]) | join(""));
        { colors: (.colors.dark | with_entries(.key |= snake_to_camel)) }
      ' > "$scheme_path"
    printf 'Wrote %s\n' "$scheme_path"
  '';
in
lib.mkIf cfg.enable {
  home.packages = [ recolor ];
}
