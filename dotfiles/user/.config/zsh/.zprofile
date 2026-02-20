# Eliminates duplicates in *paths
typeset -gU cdpath fpath mailpath path

# XDG Base Directory
#export XDG_CACHE_HOME="/tmp/$USER/.cache"
#export XDG_CONFIG_HOME="$HOME/.config"
#export XDG_DATA_HOME="$HOME/.local/share"
#export XDG_LIB_HOME="$HOME/.local/lib"
#export XDG_STATE_HOME="$HOME/.local/state"

# Function to set environment variables if a command exists
set_env_if_command() {
    local cmd="$1"
    shift
    if [[ -x "$(command -v "$cmd")" ]]; then
        for var in "$@"; do
            export "$var"
        done
    fi
}

# Function to create directories if they do not exist
ensure_directory() {
    for dir in "$@"; do
        [[ ! -d "$dir" ]] && mkdir -p "$dir"
    done
}

# Python
set_env_if_command python "PYTHONUSERBASE=${XDG_LIB_HOME}/python"

# Python virtualenvs
set_env_if_command venv "WORKON_HOME=${XDG_LIB_HOME}/python/virtualenvs"

# Pylint
set_env_if_command pylint "PYLINTHOME=${XDG_CACHE_HOME}/pylint"

# Go
set_env_if_command go \
    "GOPATH=${XDG_LIB_HOME}/go" \
    "GOBIN=${XDG_LIB_HOME}/go/bin"

# Rust
set_env_if_command rustc \
    "RUSTUP_HOME=${XDG_LIB_HOME}/rust/rustup" \
    "CARGO_HOME=${XDG_LIB_HOME}/rust/cargo" \
    "CARGO_NAME=etircopyh"

# Docker
set_env_if_command docker "DOCKER_CONFIG=${XDG_CONFIG_HOME}/docker"

# Parallel
set_env_if_command parallel "PARALLEL_HOME=${XDG_CACHE_HOME}/parallel"

# Node.js and npm
set_env_if_command node \
    "NODE_REPL_HISTORY=${XDG_STATE_HOME}/node/node_repl_history"

set_env_if_command npm \
    "NPM_CONFIG_USERCONFIG=${XDG_CONFIG_HOME}/npm/npmrc" \
    "NPM_CONFIG_CACHE=${XDG_CACHE_HOME}/npm"

# Wget
set_env_if_command wget "WGETRC=${XDG_CONFIG_HOME}/wget/wgetrc"

# Xauth and Xinit
set_env_if_command xauth "XAUTHORITY=${XDG_RUNTIME_DIR}/Xauthority"

set_env_if_command xinit \
    "XINITRC=${XDG_CONFIG_HOME}/X11/xinitrc" \
    "XSERVERRC=${XDG_CONFIG_HOME}/X11/xserverrc"

# Android
set_env_if_command adb \
    "ANDROID_PREFS_ROOT=${XDG_CONFIG_HOME}/android" \
    "ADB_KEYS_PATH=${XDG_CONFIG_HOME}/android" \
    "ANDROID_SDK_ROOT=${XDG_CONFIG_HOME}/android" \
    "ANDROID_SDK_HOME=${XDG_CONFIG_HOME}/android" \
    "ANDROID_EMULATOR_HOME=${XDG_CONFIG_HOME}/android"

# SQLite
set_env_if_command sqlite3 "SQLITE_HISTORY=${XDG_STATE_HOME}/sqlite/sqlite_history"

# Readline
set_env_if_command bash "INPUTRC=${XDG_CONFIG_HOME}/readline/inputrc"

# NSS
set_env_if_command nss-config \
    "NSS_USE_SHARED_DB=1" \
    "NSS_SHARED_DB_PATH=${XDG_DATA_HOME}/pki/nssdb"

# GPG
set_env_if_command gpg "GNUPGHOME=${XDG_DATA_HOME}/gnupg"

# Flatpak
set_env_if_command flatpak \
    "FLATPAK_CONFIG_DIR=${XDG_CONFIG_HOME}/flatpak" \
    "FLATPAK_SYSTEM_CACHE_DIR=${XDG_CACHE_HOME}/flatpak" \
    "FLATPAK_USER_DIR=${XDG_DATA_HOME}/flatpak"

ensure_directory \
    "$FLATPAK_CONFIG_DIR" \
    "$FLATPAK_SYSTEM_CACHE_DIR" \
    "$FLATPAK_USER_DIR"



# GDB
set_env_if_command gdb GDBHISTFILE="${XDG_STATE_HOME}/gdb/history"

# Zsh completion dump file
set_env_if_command zsh "COMPDUMPFILE=${XDG_CACHE_HOME}/zsh/zcompdump"

# Ripgrep
set_env_if_command rg "RIPGREP_CONFIG_PATH=${XDG_CONFIG_HOME}/ripgrep.conf"

# Password Store
set_env_if_command pass "PASSWORD_STORE_DIR=${XDG_DATA_HOME}/pass"

# Less
ensure_directory "${XDG_STATE_HOME}/less"
set_env_if_command less \
    "LESSKEY=${XDG_CONFIG_HOME:-$HOME/.config}/less/lesskey" \
    "LESSHISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/less/history"

# KDE Plasma
set_env_if_command plasmashell "KDEHOME=${XDG_CONFIG_HOME:-$HOME/.config}/kde"




fpath=("$ZHOME/.zsrc" "${fpath[@]}")

# XDG Runtime Dir fallback
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
    export LESSOPEN="| $(command -v env) ${commands[(i)lesspipe(|.sh)]} %s 2>&-"
fi
