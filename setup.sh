#!/usr/bin/env bash
# nesw setup wizard
# Requires: gum (pulled in automatically via nix-shell if missing)

set -euo pipefail

# Ensure gum is available
if ! command -v gum &>/dev/null; then
  echo "gum not found - pulling it in via nix-shell..."
  exec nix-shell -p gum --run "bash $0"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colours / Style
ACCENT="212" # purple
FAINT="240" # grey
HEADER_BORDER="rounded"

header() {
  gum style \
    --border "$HEADER_BORDER" \
    --border-foreground "$ACCENT" \
    --padding "1 3" \
    --margin "1 0" \
    --bold \
    "$@"
}

info() {
  gum style --foreground "$FAINT" --italic "  $1"
}

success() {
  gum style --foreground "10" --bold "  ✓ $1"
}

# Welcome
clear
header "nesw" "Hyprland + NixOS setup"
echo ""

# Username
info "Linux username (lowercase, no spaces, max 32 chars)"
while true; do
  USERNAME=$(gum input \
    --placeholder "nixos" \
    --prompt "username › " \
    --prompt.foreground "$ACCENT" \
    --width 40)
  USERNAME="${USERNAME:-nixos}"

  # Validate: lowercase letters, digits, hyphens, underscores. Must start with letter.
  if [[ ! "$USERNAME" =~ ^[a-z][a-z0-9_-]{0,31}$ ]]; then
    gum style --foreground "9" "  ✗ Must start with a lowercase letter, only a-z 0-9 _ - allowed, max 32 chars."
    continue
  fi
  break
done
success "username: $USERNAME"
echo ""

# Hostname
info "Machine hostname (lowercase, no spaces, max 63 chars)"
while true; do
  HOSTNAME_VAL=$(gum input \
    --placeholder "main" \
    --prompt "hostname › " \
    --prompt.foreground "$ACCENT" \
    --width 40)
  HOSTNAME_VAL="${HOSTNAME_VAL:-main}"

  # Validate: lowercase letters, digits, hyphens. Must start/end with alphanumeric.
  if [[ ! "$HOSTNAME_VAL" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
    gum style --foreground "9" "  ✗ Must start/end with a-z or 0-9, only a-z 0-9 - allowed, max 63 chars."
    continue
  fi
  break
done
success "hostname: $HOSTNAME_VAL"
echo ""

# Timezone
info "Start typing your timezone (city, region, or abbreviation)"

# Build the timezone list from the system's tz database
TZ_LIST=$(timedatectl list-timezones 2>/dev/null || find /usr/share/zoneinfo/posix -type f 2>/dev/null | sed 's|.*/zoneinfo/posix/||' | sort)

TIMEZONE=$(echo "$TZ_LIST" | gum filter \
  --placeholder "Search: New York, EST, Europe..." \
  --prompt "timezone › " \
  --prompt.foreground "$ACCENT" \
  --height 12 \
  --indicator "→" \
  --indicator.foreground "$ACCENT" \
  --match.foreground "$ACCENT")

if [[ -z "$TIMEZONE" ]]; then
  TIMEZONE="America/New_York"
fi
success "timezone: $TIMEZONE"
echo ""

# Locale
info "Start typing your locale"

# Common locales - covers the vast majority of users
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
  --prompt "locale › " \
  --prompt.foreground "$ACCENT" \
  --height 12 \
  --indicator "→" \
  --indicator.foreground "$ACCENT" \
  --match.foreground "$ACCENT")

if [[ -z "$LOCALE" ]]; then
  LOCALE="en_US.UTF-8"
fi
success "locale: $LOCALE"
echo ""

# Confirm
echo ""
gum style \
  --border "rounded" \
  --border-foreground "$FAINT" \
  --padding "1 2" \
  "  username:  $USERNAME" \
  "  hostname:  $HOSTNAME_VAL" \
  "  timezone:  $TIMEZONE" \
  "  locale:    $LOCALE"
echo ""

if ! gum confirm "Write these settings?" --prompt.foreground "$ACCENT"; then
  gum style --foreground "9" "  Aborted. No files were changed."
  exit 1
fi

# Write settings.nix
cat > "$SCRIPT_DIR/settings.nix" <<EOF
{
  username = "$USERNAME";
  hostname = "$HOSTNAME_VAL";
  timezone = "$TIMEZONE";
  locale   = "$LOCALE";
}
EOF

echo ""
success "settings.nix written!"
echo ""
info "Next steps:"
echo "  1. Copy your hardware config:"
echo "     sudo cp /etc/nixos/hardware-configuration.nix ./hosts/main/hardware-configuration.nix"
echo ""
echo "  2. Build your system:"
echo "     sudo nixos-rebuild switch --flake .#$HOSTNAME_VAL"
echo ""
