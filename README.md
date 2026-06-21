# nesw

NixOS + Hyprland + Quickshell enviroment

## Start

### 1. Clone the repository

```bash
nix-shell -p git
git clone https://github.com/liammmcauliffe/nesw.git ~/nesw
cd ~/nesw
```

### 2. Copy hardware configuration

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hosts/laptop/hardware-configuration.nix
```

This file is gitignored

### 3. Set username

In `flake.nix`, set `userName` to your Linux username (`whoami`):

```bash
nano flake.nix
```

```nix
userName = "YOUR_USERNAME";
```

**Must match before the first rebuild!**

### 4. Stage the hardware config (required for flakes)

Stage it, do not need to commit:

```bash
git add -f hosts/laptop/hardware-configuration.nix
```

After your first successful rebuild, `ntest` / `nswitch` stages gitignored files automatically.

### 5. Build

```bash
sudo nixos-rebuild switch --flake .#main
```

Reboot and log in through SDDM, Hyprland is the default session

```bash
reboot
```

### 6. Rebuilds

From any directory (Fish, after HM is active):

```bash
nswitch    # stage changes, rebuild and switch
ntest      # test build (reverted on reboot)
nupdate    # update flake inputs, test build
nrollback  # switch to previous system generation
```

## Optional

```bash
cp hosts/laptop/local.nix.example hosts/laptop/local.nix
nix-shell -p pciutils --run "lspci -k | grep -A 3 -E 'VGA|3D|Display'"
```

```nix
# hosts/laptop/local.nix
{ ... }: {
  nesw.drivers.intel.enable = true;   # or amdgpu / nvidia
}
```

Adjust `time.timeZone` and `i18n.defaultLocale` in `hosts/laptop/configuration.nix` if needed.

## Project layout

```
nesw/
├── flake.nix                      # inputs, nixosConfigurations.main, homeManagerModules
├── hosts/laptop/
│   ├── default.nix                # host entry (configuration + home paths)
│   ├── configuration.nix          # NixOS system config
│   ├── home.nix                   # Home Manager entry
│   ├── local.nix.example          # optional override template
│   ├── local.nix                  # optional - NixOS overrides (gitignored)
│   ├── shared.nix                 # optional - shared overrides (gitignored)
│   ├── home.local.nix             # optional - HM-only overrides (gitignored)
│   └── hardware-configuration.nix # machine-specific (gitignored)
└── modules/
    ├── drivers/                   # nesw.drivers.* (GPU / Mesa / VA-API)
    ├── desktop/                   # hyprland, quickshell
    ├── shell/                     # fish, starship, tools
    ├── terminal/ghostty/
    ├── editors/nvim/
    └── browser/zen/
```
