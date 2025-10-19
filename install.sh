#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get the directory where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_info "Starting macOS dotfiles installation..."
echo ""

# ========================================
# Check if running on macOS
# ========================================
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only!"
    exit 1
fi

print_success "Running on macOS"

# ========================================
# Install Homebrew
# ========================================
print_info "Checking for Homebrew..."

if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    print_success "Homebrew installed successfully"
else
    print_success "Homebrew already installed"
fi

# ========================================
# Run Brew Bundle
# ========================================
print_info "Installing packages from Brewfile..."

if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    cd "$DOTFILES_DIR"
    brew bundle --no-lock
    print_success "Packages installed successfully"
else
    print_error "Brewfile not found in $DOTFILES_DIR"
    exit 1
fi

# ========================================
# Setup zplug
# ========================================
print_info "Setting up zplug..."

if [[ ! -d ~/.zplug ]]; then
    print_info "Installing zplug..."
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    print_success "zplug installed"
else
    print_success "zplug already installed"
fi

# ========================================
# Copy .zshrc
# ========================================
print_info "Setting up .zshrc..."

if [[ -f ~/.zshrc ]]; then
    print_warning "Existing .zshrc found. Creating backup..."
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    print_success "Backup created"
fi

cp "$DOTFILES_DIR/.zshrc" ~/.zshrc
print_success ".zshrc copied successfully"

# ========================================
# Set zsh as default shell
# ========================================
print_info "Checking default shell..."

if [[ "$SHELL" != */zsh ]]; then
    print_warning "Current shell is not zsh. Changing default shell to zsh..."
    chsh -s "$(which zsh)"
    print_success "Default shell changed to zsh"
else
    print_success "zsh is already the default shell"
fi

# ========================================
# Import Snazzy iTerm2 theme
# ========================================
print_info "Setting up Snazzy iTerm2 theme..."

# Create iTerm2 preferences directory if it doesn't exist
ITERM_THEMES_DIR="$HOME/.iterm2/themes"
mkdir -p "$ITERM_THEMES_DIR"

# Download Snazzy theme
SNAZZY_THEME_URL="https://raw.githubusercontent.com/sindresorhus/iterm2-snazzy/main/Snazzy.itermcolors"
SNAZZY_THEME_PATH="$ITERM_THEMES_DIR/Snazzy.itermcolors"

if [[ ! -f "$SNAZZY_THEME_PATH" ]]; then
    print_info "Downloading Snazzy theme..."
    curl -fsSL "$SNAZZY_THEME_URL" -o "$SNAZZY_THEME_PATH"
    print_success "Snazzy theme downloaded to $SNAZZY_THEME_PATH"
else
    print_success "Snazzy theme already exists"
fi

# ========================================
# Setup fzf
# ========================================
print_info "Setting up fzf key bindings and fuzzy completion..."

if command -v fzf &> /dev/null; then
    # Install fzf shell integration
    if [[ ! -f ~/.fzf.zsh ]]; then
        "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
        print_success "fzf shell integration installed"
    else
        print_success "fzf shell integration already configured"
    fi
fi

# ========================================
# Install zsh plugins via zplug
# ========================================
print_info "Installing zsh plugins via zplug..."

# Source zplug and install plugins non-interactively
export ZPLUG_HOME=~/.zplug
if [[ -d "$ZPLUG_HOME" ]]; then
    source "$ZPLUG_HOME/init.zsh"
    
    # Load plugin definitions from .zshrc
    zplug "mafredri/zsh-async", from:github, defer:0
    zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
    zplug "zsh-users/zsh-autosuggestions", from:github, defer:2
    zplug "zsh-users/zsh-syntax-highlighting", from:github, defer:3
    
    # Install plugins without prompting
    if ! zplug check; then
        zplug install
    fi
    
    print_success "zsh plugins installed"
fi

# ========================================
# Final instructions
# ========================================
echo ""
print_success "Installation complete! 🎉"
echo ""
print_info "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Open iTerm2 and import the Snazzy theme:"
echo "     - Go to iTerm2 > Preferences > Profiles > Colors"
echo "     - Click 'Color Presets' > 'Import'"
echo "     - Select: $SNAZZY_THEME_PATH"
echo "     - Select 'Snazzy' from the 'Color Presets' dropdown"
echo "  3. Set JetBrains Mono Nerd Font in iTerm2:"
echo "     - Go to iTerm2 > Preferences > Profiles > Text"
echo "     - Change font to 'JetBrainsMono Nerd Font'"
echo ""
print_info "Enjoy your new setup!"
