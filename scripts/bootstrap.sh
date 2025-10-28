#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# Idempotent bootstrap script for dotfiles
# - Symlink files from home/ into $HOME
# - Backup non-symlink targets with timestamp suffix
# - Link config/* into $HOME/.config/*
# - Link prefs/cursor/User/* into ~/Library/Application Support/Cursor/User/

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="$HOME"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
DRY_RUN=false

info() { printf "[INFO] %s\n" "$*"; }
warn() { printf "[WARN] %s\n" "$*"; }
error() { printf "[ERROR] %s\n" "$*" >&2; }

usage() {
  cat <<EOF
Usage: $(basename "$0") [--dry-run|-n] [--help|-h]

Options:
  --dry-run, -n   Show actions without modifying the filesystem
  --help,   -h    Display this help message
EOF
}

maybe_run() {
  if [ "$DRY_RUN" = true ]; then
    info "[dry-run] $*"
  else
    "$@"
  fi
}

link_file() {
  local src="$1" dst="$2"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ]; then
      if [ "$(readlink "$dst")" = "$src" ]; then
        info "Link exists and correct: $dst -> $src"
        return 0
      else
        info "Updating symlink: $dst (was $(readlink "$dst"))"
        maybe_run rm "$dst"
      fi
    else
      # not a symlink; back it up
      local backup="$dst.$TIMESTAMP.bak"
      info "Backing up existing file: $dst -> $backup"
      maybe_run mv "$dst" "$backup"
    fi
  fi

  maybe_run ln -s "$src" "$dst"
  info "Linked: $dst -> $src"
}

ensure_prereqs() {
  local platform
  platform=$(uname -s)
  if [ "$platform" != "Darwin" ]; then
    error "Unsupported platform: $platform. This bootstrap currently targets macOS."
    exit 1
  fi

  for cmd in git; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Missing required dependency: $cmd"
      exit 1
    fi
  done

  if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew not found. Installation of optional packages will be skipped."
  fi
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n)
      DRY_RUN=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [ "$DRY_RUN" = true ]; then
  info "Dry run enabled: filesystem changes will be skipped."
fi

ensure_prereqs

CURSOR_TARGET="${CURSOR_USER_DIR:-$HOME_DIR/Library/Application Support/Cursor/User}"
VSCODE_TARGET="${VSCODE_USER_DIR:-$HOME_DIR/Library/Application Support/Code/User}"

# Symlink everything in home/ to $HOME
info "Symlinking home/ -> $HOME_DIR"
for path in "$DOTFILES_DIR"/home/.* "$DOTFILES_DIR"/home/*; do
  # skip current/parent
  base=$(basename "$path")
  if [ "$base" = "." ] || [ "$base" = ".." ]; then
    continue
  fi
  src="$path"
  dst="$HOME_DIR/$base"

  # skip directories that are meant to be under ~/.config
  if [ -d "$src" ] && [[ "$base" = ".config" ]]; then
    continue
  fi

  # create parent dir if needed
  dst_dir=$(dirname "$dst")
  maybe_run mkdir -p "$dst_dir"

  link_file "$src" "$dst"
done

# Link config/* into ~/.config/*
if [ -d "$DOTFILES_DIR/config" ]; then
  info "Linking config/ -> $HOME_DIR/.config/"
  maybe_run mkdir -p "$HOME_DIR/.config"
  for cfg in "$DOTFILES_DIR"/config/*; do
    [ -e "$cfg" ] || continue
    name=$(basename "$cfg")
    src="$cfg"
    dst="$HOME_DIR/.config/$name"
    link_file "$src" "$dst"
  done
fi

# Link Cursor prefs
if [ -d "$DOTFILES_DIR/prefs/cursor/User" ]; then
  info "Linking prefs/cursor/User -> $CURSOR_TARGET"
  maybe_run mkdir -p "$CURSOR_TARGET"
  for f in "$DOTFILES_DIR"/prefs/cursor/User/*; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    src="$f"
    dst="$CURSOR_TARGET/$name"
    link_file "$src" "$dst"
  done
fi

# Link VSCode prefs
if [ -d "$DOTFILES_DIR/prefs/vscode/User" ]; then
  info "Linking prefs/vscode/User -> $VSCODE_TARGET"
  maybe_run mkdir -p "$VSCODE_TARGET"
  for f in "$DOTFILES_DIR"/prefs/vscode/User/*; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    src="$f"
    dst="$VSCODE_TARGET/$name"
    link_file "$src" "$dst"
  done
fi

# Generate and link Claude settings from template
if [ -f "$DOTFILES_DIR/prefs/claude/settings.json.template" ]; then
  info "Generating Claude settings from template..."
  maybe_run mkdir -p "$HOME_DIR/.claude"

  # Generate settings.json from template with actual paths
  CLAUDE_SETTINGS="$HOME_DIR/.claude/settings.json"
  if [ "$DRY_RUN" = true ]; then
    info "[dry-run] Would generate $CLAUDE_SETTINGS from template"
  else
    sed -e "s|{{HOME}}|$HOME_DIR|g" \
        -e "s|{{DOTFILES_DIR}}|$DOTFILES_DIR|g" \
        "$DOTFILES_DIR/prefs/claude/settings.json.template" > "$CLAUDE_SETTINGS"
    info "Generated: $CLAUDE_SETTINGS"
  fi
fi

# Inform about iTerm2 preferences location
if [ -d "$DOTFILES_DIR/prefs/iterm2" ]; then
  info "iTerm2 prefs available in: $DOTFILES_DIR/prefs/iterm2"
  info "To load them, open iTerm2 > Preferences > General > Preferences and set 'Load preferences from a custom folder' to: $DOTFILES_DIR/prefs/iterm2"
fi

# Auto-install Homebrew bundle
BUNDLE_FILE="$DOTFILES_DIR/brew/Brewfile"
if command -v brew >/dev/null 2>&1 && [ -f "$BUNDLE_FILE" ]; then
  if [ "$DRY_RUN" = true ]; then
    info "Dry run: skipping brew bundle (brew bundle --file=\"$BUNDLE_FILE\")"
  else
    info "Installing Homebrew packages from Brewfile..."
    brew bundle --file="$BUNDLE_FILE" || warn "Some brew packages failed to install, continuing anyway..."
  fi
fi

# Auto-install oh-my-zsh if missing
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  if [ "$DRY_RUN" = true ]; then
    info "Dry run: would install oh-my-zsh"
  else
    info "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || warn "oh-my-zsh installation failed, continuing anyway..."
  fi
fi

# zplug should be installed via Brewfile, but verify
if command -v brew >/dev/null 2>&1; then
  ZPLUG_HOME="$(brew --prefix)/opt/zplug"
  if [ ! -d "$ZPLUG_HOME" ]; then
    info "zplug not found. It should be installed via 'brew bundle' above."
  fi
fi

info "Bootstrap complete."
# Configure global .gitignore on first run
if ! git config --global --get core.excludesfile >/dev/null; then
  maybe_run cp -n "$DOTFILES_DIR/templates/gitignore_global" "$HOME/.gitignore_global"
  maybe_run git config --global core.excludesfile "$HOME/.gitignore_global"
fi
