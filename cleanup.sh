#!/bin/bash

# Comprehensive Arch Linux Cleanup Script
# Targets heavy-hitting caches (GBs) while preserving user data.

echo "--- Starting Aggressive Space Cleanup ---"

# 1. System Package Manager (Pacman)
if command -v paccache &>/dev/null; then
  echo "[1/9] Cleaning pacman cache (keeping last 2 versions)..."
  sudo paccache -rk2
  sudo paccache -ruk0
else
  echo "[1/9] paccache not found, using pacman -Sc..."
  sudo pacman -Sc --noconfirm
fi

# 2. Orphaned Packages
orphans=$(pacman -Qtdq)
if [ -n "$orphans" ]; then
  echo "[2/9] Removing orphaned packages..."
  sudo pacman -Rns $orphans --noconfirm
else
  echo "[2/9] No orphaned packages to remove."
fi

# 3. Systemd Journal
echo "[3/9] Vacuuming journal logs (keeping 2 weeks or 100MB)..."
sudo journalctl --vacuum-time=2w
sudo journalctl --vacuum-size=100M

# 4. Browser Profile Caches (Surgical)
echo "[4/9] Cleaning browser profile-internal caches..."
# Firefox
for ff_profile in ~/.mozilla/firefox/*.default*; do
  [ -d "$ff_profile" ] || continue
  if pgrep -x "firefox" >/dev/null; then
    echo "  [!] Firefox is running, skipping profile: $(basename "$ff_profile")"
  else
    echo "  Cleaning Firefox: $(basename "$ff_profile")"
    rm -rf "$ff_profile/cache2"/* "$ff_profile/startupCache"/* "$ff_profile/storage/default"/* 2>/dev/null
  fi
done

# Chromium-based
CHROME_DIRS=(~/.config/chromium ~/.config/google-chrome ~/.config/BraveSoftware/Brave-Browser)
for dir in "${CHROME_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  browser=$(basename "$dir")
  if pgrep -fi "$browser" >/dev/null; then
    echo "  [!] $browser is running, skipping."
  else
    echo "  Cleaning $browser caches..."
    find "$dir" -type d \( -name "Cache" -o -name "Code Cache" -o -name "GPUCache" -o -name "CacheStorage" \) -exec rm -rf {}/* + 2>/dev/null
  fi
done

# 5. Electron App Junk
echo "[5/9] Hunting for Electron & generic app junk in ~/.config..."
# Targets Discord, Slack, Spotify, etc.
find ~/.config -maxdepth 3 -type d \( \
  -name "GPUCache" -o \
  -name "Code Cache" -o \
  -name "Cache" -o \
  -name "CacheStorage" -o \
  -name "blob_storage" \
  \) -not -path "*/node_modules/*" -exec rm -rf {}/* + 2>/dev/null

# 6. Development Tools (The real space hogs)
echo "[6/9] Cleaning development caches (npm, pip, cargo)..."
[ -d ~/.npm ] && echo "  Cleaning npm cache..." && npm cache clean --force 2>/dev/null
if command -v pip &>/dev/null; then
  echo "  Cleaning pip cache..."
  pip cache purge 2>/dev/null
fi
if [ -d ~/.cargo/registry ]; then
  echo "  Cleaning cargo registry (sources only, keeping binaries)..."
  rm -rf ~/.cargo/registry/src/* ~/.cargo/registry/cache/* 2>/dev/null
fi

# 7. Media & Game Caches
echo "[7/9] Cleaning media and game caches..."
# Steam Shader Cache - can grow to tens of gigabytes
STEAM_SHADER_CACHE=~/.local/share/Steam/shadercache
if [ -d "$STEAM_SHADER_CACHE" ]; then
  if pgrep -x "steam" >/dev/null; then
    echo "  [!] Steam is running, skipping shader cache."
  else
    echo "  Cleaning Steam shader cache..."
    rm -rf "$STEAM_SHADER_CACHE"/* 2>/dev/null
  fi
fi

# Spotify Cache
if [ -d ~/.cache/spotify ]; then
  echo "  Cleaning Spotify cache..."
  rm -rf ~/.cache/spotify/* 2>/dev/null
fi

# 8. General ~/.cache & Trash
echo "[8/9] Cleaning ~/.cache and Trash..."
# Exclude folders of running browsers to prevent lock issues
EXCLUDES=""
pgrep -x "firefox" >/dev/null && EXCLUDES="$EXCLUDES -not -path '*/mozilla/*'"
pgrep -fi "chromium" >/dev/null && EXCLUDES="$EXCLUDES -not -path '*/chromium/*'"
pgrep -fi "brave" >/dev/null && EXCLUDES="$EXCLUDES -not -path '*/BraveSoftware/*'"

eval "find ~/.cache -mindepth 1 $EXCLUDES -delete 2>/dev/null || true"
rm -rf ~/.local/share/Trash/* 2>/dev/null || true

# 9. AUR Helpers
if command -v yay &>/dev/null; then
  echo "[9/9] Cleaning yay cache..."
  yay -Sc --noconfirm
elif command -v paru &>/dev/null; then
  echo "[9/9] Cleaning paru cache..."
  paru -Sc --noconfirm
fi

echo "--- Cleanup Complete! ---"
