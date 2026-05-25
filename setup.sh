#!/usr/bin/env bash
# nesw setup wizard
# Requires: gum (pulled in automatically via nix-shell if missing)

set -euo pipefail

# Ensure gum is available
if ! command -v gum &>/dev/null; then
  echo "gum not found - pulling it in via nix-shell..."
  exec nix-shell -p gum --run "bash $0"
fi

# Determine if we need sudo (handles root vs nixos user on Live USB)
if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Minimal Modern Palette (Zinc/Slate)
BG_SURFACE="#18181b"
BG_PANEL="#27272a"
TEXT_MAIN="#e4e4e7"
TEXT_MUTED="#71717a"
ACCENT="#94a3b8"
SUCCESS="#86efac"
ERROR="#fca5a5"
WARN="#fcd34d"

# UI Helper Functions
header() {
  gum style \
    --border rounded \
    --border-foreground "$ACCENT" \
    --padding "1 4" \
    --margin "1 0" \
    --bold \
    "$@"
}

info() {
  gum style --foreground "$TEXT_MAIN" "  $1"
}

hint() {
  gum style --foreground "$TEXT_MUTED" "    $1"
}

success() {
  gum style --foreground "$SUCCESS" "  + $1"
}

warn() {
  gum style --foreground "$WARN" "  ! $1"
}

error_msg() {
  gum style --foreground "$ERROR" "  x $1"
}

divider() {
  gum style --foreground "$TEXT_MUTED" "  $(printf '%.0s─' $(seq 1 40))"
}

# Welcome
clear
header "nesw" "Hyprland + NixOS Interactive Setup"
echo ""
info "This wizard will configure your system settings and automate the installation."
echo ""

# Check if settings.nix already exists
if [[ -f "$SCRIPT_DIR/settings.nix" ]]; then
  warn "settings.nix already exists."
  if ! gum confirm "Overwrite existing settings?" \
    --prompt.foreground "$WARN" \
    --selected.background "$ACCENT" \
    --selected.foreground "$BG_SURFACE" \
    --unselected.background "" \
    --unselected.foreground "$TEXT_MAIN"; then
    error_msg "Aborted. No files were changed."
    exit 1
  fi
  echo ""
fi

# Detect the current user (handles if they accidentally ran via sudo)
CURRENT_USER=${SUDO_USER:-$USER}

# Username
info "Linux username"
hint "The user account you created during NixOS installation."
while true; do
  USERNAME=$(gum input \
    --value "$CURRENT_USER" \
    --placeholder "$CURRENT_USER" \
    --prompt "> " \
    --prompt.foreground "$ACCENT" \
    --width 40)
  
  # Fallback just in case they clear the input entirely
  USERNAME="${USERNAME:-$CURRENT_USER}"

  if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    error_msg "Invalid. Must start with a-z or _, and contain only a-z, 0-9, _, -"
    continue
  fi
  break
done
success "username: $USERNAME"
echo ""

# Hostname
info "Machine hostname"
hint "Lowercase, no spaces, max 63 chars (e.g., desktop, xps15, main)"
while true; do
  HOSTNAME_VAL=$(gum input \
    --placeholder "main" \
    --prompt "> " \
    --prompt.foreground "$ACCENT" \
    --width 40)
  HOSTNAME_VAL="${HOSTNAME_VAL:-main}"

  if [[ ! "$HOSTNAME_VAL" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
    error_msg "Invalid. Must start/end with a-z or 0-9, and contain only a-z, 0-9, -"
    continue
  fi
  break
done
success "hostname: $HOSTNAME_VAL"
echo ""

# Timezone
info "Timezone"
hint "Start typing to search (e.g., New York, London, Tokyo)"

TZ_LIST=$(timedatectl list-timezones 2>/dev/null || find /usr/share/zoneinfo/posix -type f 2>/dev/null | sed 's|.*/zoneinfo/posix/||' | sort)

TIMEZONE=$(echo "$TZ_LIST" | gum filter \
  --placeholder "Search: New York, EST, Europe..." \
  --prompt "> " \
  --prompt.foreground "$ACCENT" \
  --height 12 \
  --indicator ">" \
  --indicator.foreground "$ACCENT" \
  --match.foreground "$TEXT_MAIN" \
  --text.foreground "$TEXT_MUTED")

if [[ -z "$TIMEZONE" ]]; then
  TIMEZONE="America/New_York"
fi
success "timezone: $TIMEZONE"
echo ""

# Locale
info "System Locale"
hint "Start typing to search (e.g., en_US, de_DE, fr_FR)"

LOCALE_LIST="en_US.UTF-8
en_GB.UTF-8
en_AU.UTF-8
en_CA.UTF-8
de_DE.UTF-8
fr_FR.UTF-8
es_ES.UTF-8
it_IT.UTF-8
pt_BR.UTF-8
pt_PT.UTF-8
nl_NL.UTF-8
pl_PL.UTF-8
ru_RU.UTF-8
ja_JP.UTF-8
ko_KR.UTF-8
zh_CN.UTF-8
zh_TW.UTF-8
ar_SA.UTF-8
hi_IN.UTF-8
sv_SE.UTF-8
nb_NO.UTF-8
da_DK.UTF-8
fi_FI.UTF-8
tr_TR.UTF-8
cs_CZ.UTF-8
ro_RO.UTF-8
hu_HU.UTF-8
el_GR.UTF-8
he_IL.UTF-8
th_TH.UTF-8
vi_VN.UTF-8
uk_UA.UTF-8
id_ID.UTF-8"

LOCALE=$(echo "$LOCALE_LIST" | gum filter \
  --placeholder "Search: en_US, German, fr..." \
  --prompt "> " \
  --prompt.foreground "$ACCENT" \
  --height 12 \
  --indicator ">" \
  --indicator.foreground "$ACCENT" \
  --match.foreground "$TEXT_MAIN" \
  --text.foreground "$TEXT_MUTED")

if [[ -z "$LOCALE" ]]; then
  LOCALE="en_US.UTF-8"
fi
success "locale: $LOCALE"
echo ""

# Summary & Confirmation
clear
header "Review Configuration"
echo ""
gum style \
  --border normal \
  --border-foreground "$TEXT_MUTED" \
  --padding "1 2" \
  --margin "0 0 1 0" \
  "  Username:  $USERNAME" \
  "  Hostname:  $HOSTNAME_VAL" \
  "  Timezone:  $TIMEZONE" \
  "  Locale:    $LOCALE"
echo ""

if ! gum confirm "Does this look correct?" \
  --prompt.foreground "$ACCENT" \
  --selected.background "$ACCENT" \
  --selected.foreground "$BG_SURFACE" \
  --unselected.background "" \
  --unselected.foreground "$TEXT_MAIN"; then
  error_msg "Aborted. No files were changed."
  exit 1
fi

# Write settings.nix
echo ""
info "Writing settings.nix..."
cat > "$SCRIPT_DIR/settings.nix" <<EOF
{
  username = "$USERNAME";
  hostname = "$HOSTNAME_VAL";
  timezone = "$TIMEZONE";
  locale   = "$LOCALE";
}
EOF
success "settings.nix updated"
echo ""

# Automation Steps
divider
header "Automated Setup Steps"
echo ""

# 1. Hardware Configuration
info "Copying hardware-configuration.nix..."
HW_SRC="/etc/nixos/hardware-configuration.nix"
HW_DEST="$SCRIPT_DIR/hosts/main/hardware-configuration.nix"

if [[ -f "$HW_SRC" ]]; then
  if [[ ! -d "$(dirname "$HW_DEST")" ]]; then
    mkdir -p "$(dirname "$HW_DEST")"
  fi
  $SUDO cp "$HW_SRC" "$HW_DEST"
  success "Hardware configuration copied"
else
  warn "Could not find $HW_SRC"
  hint "You may need to generate it first or copy it manually."
fi
echo ""

# 2. NixOS Rebuild
info "Building and switching to your new NixOS configuration..."
hint "This will download packages and build your system. It may take a while."
echo ""

if gum confirm "Run nixos-rebuild switch now?" \
  --prompt.foreground "$ACCENT" \
  --selected.background "$ACCENT" \
  --selected.foreground "$BG_SURFACE" \
  --unselected.background "" \
  --unselected.foreground "$TEXT_MAIN"; then
  info "Starting build... (Output will appear below)"
  echo ""
  if $SUDO nixos-rebuild switch --flake "$SCRIPT_DIR#$HOSTNAME_VAL"; then
    success "System built and switched successfully"
  else
    error_msg "Build failed. Check the output above for errors."
    exit 1
  fi
else
  warn "Skipped build. You can run it later with:"
  hint "cd ~/nesw && sudo nixos-rebuild switch --flake .#$HOSTNAME_VAL"
fi
echo ""

# 3. Reboot
divider
if gum confirm "Reboot into your new system now?" \
  --prompt.foreground "$ACCENT" \
  --selected.background "$ACCENT" \
  --selected.foreground "$BG_SURFACE" \
  --unselected.background "" \
  --unselected.foreground "$TEXT_MAIN"; then
  info "Rebooting in 3 seconds..."
  sleep 3
  $SUDO reboot
else
  echo ""
  success "Setup complete"
  info "Next steps:"
  hint "1. Reboot your machine: sudo reboot"
  hint "2. Log into TTY with your new username: $USERNAME"
  hint "3. Start Hyprland: start-hyprland"
fi