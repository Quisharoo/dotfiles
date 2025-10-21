#!/usr/bin/env bash
set -euo pipefail

# Idempotent bootstrap script for dotfiles
# - Symlink files from home/ into $HOME
# - Backup non-symlink targets with timestamp suffix
# - Link config/* into $HOME/.config/*
# - Link prefs/cursor/User/* into ~/Library/Application Support/Cursor/User/

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="$HOME"
TIMESTAMP=$(date +%Y%m%d%H%M%S)

info() { printf "[INFO] %s\n" "$*"; }
error() { printf "[ERROR] %s\n" "$*" >&2; }

link_file() {
  local src="$1" dst="$2"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ]; then
      if [ "$(readlink "$dst")" = "$src" ]; then
        info "Link exists and correct: $dst -> $src"
        return 0
      else
        info "Updating symlink: $dst (was $(readlink "$dst"))"
        rm "$dst"
      fi
    else
      # not a symlink; back it up
      local backup="$dst.$TIMESTAMP.bak"
      info "Backing up existing file: $dst -> $backup"
      mv "$dst" "$backup"
    fi
  fi

  ln -s "$src" "$dst"
  info "Linked: $dst -> $src"
}

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
  mkdir -p "$dst_dir"

  link_file "$src" "$dst"
done

# Link config/* into ~/.config/*
if [ -d "$DOTFILES_DIR/config" ]; then
  info "Linking config/ -> $HOME_DIR/.config/"
  mkdir -p "$HOME_DIR/.config"
  for cfg in "$DOTFILES_DIR"/config/*; do
    [ -e "$cfg" ] || continue
    name=$(basename "$cfg")
    src="$cfg"
    dst="$HOME_DIR/.config/$name"
    link_file "$src" "$dst"
  done
fi

# Link Cursor prefs
CURSOR_TARGET="$HOME_DIR/Library/Application Support/Cursor/User"
if [ -d "$DOTFILES_DIR/prefs/cursor/User" ]; then
  info "Linking prefs/cursor/User -> $CURSOR_TARGET"
  mkdir -p "$CURSOR_TARGET"
  for f in "$DOTFILES_DIR"/prefs/cursor/User/*; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    src="$f"
    dst="$CURSOR_TARGET/$name"
    link_file "$src" "$dst"
  done
fi

# Inform about iTerm2 preferences location
if [ -d "$DOTFILES_DIR/prefs/iterm2" ]; then
  info "iTerm2 prefs available in: $DOTFILES_DIR/prefs/iterm2"
  info "To load them, open iTerm2 > Preferences > General > Preferences and set 'Load preferences from a custom folder' to: $DOTFILES_DIR/prefs/iterm2"
fi

info "Bootstrap complete."