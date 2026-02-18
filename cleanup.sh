#!/bin/bash

# A script to surgically clean up caches and temporary files on Arch Linux.
# Targeted at freeing space without losing critical user data (bookmarks, passwords, etc.).

echo "--- Starting System Cleanup ---"

# 1. Clean pacman cache
if command -v paccache &>/dev/null; then
  echo "[1/7] Cleaning pacman cache (keeping 2 versions)..."
  sudo paccache -rk2
  sudo paccache -ruk0
else
  echo "[1/7] paccache not found, using pacman -Sc..."
  sudo pacman -Sc --noconfirm
fi

# 2. Remove orphaned packages
orphans=$(pacman -Qtdq)
if [ -z "$orphans" ]; then
  echo "[2/7] No orphaned packages found."
else
  echo "[2/7] Removing orphaned packages..."
  sudo pacman -Rns $orphans --noconfirm
fi

# 3. Vacuum systemd journal logs
echo "[3/7] Vacuuming systemd journal (2 weeks / 100MB)..."
sudo journalctl --vacuum-time=2w
sudo journalctl --vacuum-size=100M

# 4. Surgical Browser Profile Cleanup
echo "[4/7] Analyzing browser profiles for hidden caches..."

# Firefox profile paths
FF_PATHS=(~/.mozilla/firefox/*.default*)
for ff_profile in "${FF_PATHS[@]}"; do
  if [ -d "$ff_profile" ]; then
    if pgrep -x "firefox" >/dev/null; then
      echo "  [!] Firefox is running. Skipping profile: $(basename "$ff_profile")"
    else
      echo "  Cleaning Firefox profile: $(basename "$ff_profile")"
      rm -rf "$ff_profile/cache2"/* 2>/dev/null || true
      rm -rf "$ff_profile/startupCache"/* 2>/dev/null || true
      rm -rf "$ff_profile/storage/default"/* 2>/dev/null || true
      rm -rf "$ff_profile/entries"/* 2>/dev/null || true
    fi
  fi
done

# Chromium-based (Chrome, Brave, Chromium)
CHROME_CONFIGS=(
  "$HOME/.config/chromium"
  "$HOME/.config/google-chrome"
  "$HOME/.config/BraveSoftware/Brave-Browser"
)

for config_dir in "${CHROME_CONFIGS[@]}"; do
  if [ -d "$config_dir" ]; then
    browser_name=$(basename "$config_dir")
    if pgrep -fi "$browser_name" >/dev/null; then
      echo "  [!] $browser_name is running. Skipping."
    else
      echo "  Cleaning $browser_name profile caches..."
      find "$config_dir" -type d \( -name "Cache" -o -name "Code Cache" -o -name "GPUCache" -o -name "CacheStorage" -o -name "ScriptCache" \) -exec rm -rf {}/* + 2>/dev/null || true
    fi
  fi
done

# 5. General ~/.cache cleanup
echo "[5/7] Cleaning ~/.cache (excluding running browsers)..."
# We exclude the root directories of running browsers to prevent simple file-lock issues
EXCLUDES=""
if pgrep -x "firefox" >/dev/null; then EXCLUDES="$EXCLUDES -not -path '*/mozilla/*'"; fi
if pgrep -fi "chromium" >/dev/null; then EXCLUDES="$EXCLUDES -not -path '*/chromium/*'"; fi
if pgrep -fi "brave" >/dev/null; then EXCLUDES="$EXCLUDES -not -path '*/BraveSoftware/*'"; fi

eval "find ~/.cache -mindepth 1 $EXCLUDES -delete 2>/dev/null || true"

# 6. Thumbnails and Trash
echo "[6/7] Emptying thumbnails and trash..."
rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
rm -rf ~/.local/share/Trash/* 2>/dev/null || true

# 7. AUR Helpers
if command -v yay &>/dev/null; then
  echo "[7/7] Cleaning yay cache..."
  yay -Sc --noconfirm
elif command -v paru &>/dev/null; then
  echo "[7/7] Cleaning paru cache..."
  paru -Sc --noconfirm
else
  echo "[7/7] No AUR helper (yay/paru) found."
fi

echo "--- Cleanup Complete! ---"
