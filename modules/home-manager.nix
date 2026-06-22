{
    lib,
    ...
}: {
    imports = [./nesw.nix];

    options.nesw.home-manager.enable =
        lib.mkEnableOption "NESW Home Manager module bundle";
}
