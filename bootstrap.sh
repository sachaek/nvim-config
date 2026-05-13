#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Neovim Python IDE — Linux bootstrap
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}>>>${NC} $*"; }
ok()    { echo -e "${GREEN}OK${NC} $*"; }
err()   { echo -e "${RED}ERROR${NC} $*"; exit 1; }

# --- 1. Установка Neovim ---
install_neovim() {
  if command -v nvim &>/dev/null; then
    info "Neovim already installed: $(nvim --version | head -1)"
    return
  fi

  if command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y neovim python3-pip
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y neovim python3-pip
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm neovim python-pip
  elif command -v zypper &>/dev/null; then
    sudo zypper install -y neovim python3-pip
  else
    info "Package manager not detected. Trying AppImage..."
    mkdir -p ~/.local/bin
    curl -Lo ~/.local/bin/nvim https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod +x ~/.local/bin/nvim
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

# --- 2. Python-пакеты ---
install_python_packages() {
  local pip_cmd
  pip_cmd=$(command -v pip3 || command -v pip) || err "pip not found. Install python3-pip."
  info "Installing Python packages (pynvim, ruff, debugpy)..."
  $pip_cmd install --user pynvim ruff debugpy -q
}

# --- 3. Копирование конфига ---
deploy_config() {
  local src="$1/nvim"
  local dst="$HOME/.config/nvim"

  if [ ! -d "$src" ]; then
    err "Folder 'nvim' not found next to bootstrap.sh"
  fi

  if [ -d "$dst" ]; then
    local backup="$dst.backup-$(date +%Y%m%d-%H%M%S)"
    info "Backing up existing config -> $backup"
    mv "$dst" "$backup"
  fi

  mkdir -p "$HOME/.config"
  cp -r "$src" "$dst"
  ok "Config copied to $dst"
}

# --- 4. Установка плагинов ---
install_plugins() {
  info "First launch — lazy.nvim will install all plugins..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  ok "Plugins installed (or ready on next launch)"
}

# --- MAIN ---
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   NEOVIM PYTHON IDE — BOOTSTRAP     ║"
echo "╚══════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

install_neovim
install_python_packages
deploy_config "$SCRIPT_DIR"
install_plugins

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   READY! Run:  nvim                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
