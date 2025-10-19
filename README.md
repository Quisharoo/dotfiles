# macOS Dotfiles

My personal macOS dotfiles with automatic installation of zsh + iTerm2 setup.

## 🚀 Features

- **Automated Installation**: One command to set up everything
- **Homebrew Package Management**: All tools installed via Homebrew
- **Modern Shell Tools**: Includes ripgrep, fd, eza, bat, zoxide, fzf, and more
- **Beautiful Shell**: Pure prompt with syntax highlighting and autosuggestions
- **Snazzy iTerm2 Theme**: Eye-catching color scheme
- **JetBrains Mono Nerd Font**: Great coding font with icon support

## 📦 What's Included

### Development Tools
- **git** - Version control
- **zplug** - Zsh plugin manager
- **fzf** - Fuzzy finder
- **ripgrep** - Fast grep alternative
- **fd** - Fast find alternative
- **eza** - Modern ls replacement
- **bat** - Cat with syntax highlighting
- **zoxide** - Smarter cd command
- **jq** - JSON processor
- **thefuck** - Command corrector
- **starship** - Cross-shell prompt (alternative)

### Applications
- **iTerm2** - Better terminal for macOS
- **JetBrains Mono Nerd Font** - Coding font with icons

### Zsh Plugins
- **mafredri/zsh-async** - Async operations for zsh
- **sindresorhus/pure** - Minimal and fast prompt
- **zsh-users/zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-users/zsh-syntax-highlighting** - Syntax highlighting

## 🔧 Installation

### Quick Install

```bash
git clone https://github.com/Quisharoo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### What the installer does

1. ✅ Checks if running on macOS
2. ✅ Installs Homebrew (if not already installed)
3. ✅ Installs all packages from Brewfile
4. ✅ Sets up zplug
5. ✅ Backs up existing .zshrc (if present)
6. ✅ Copies new .zshrc configuration
7. ✅ Sets zsh as default shell
8. ✅ Downloads Snazzy iTerm2 theme
9. ✅ Sets up fzf key bindings
10. ✅ Installs all zsh plugins

## 🎨 Post-Installation

After running the installer:

1. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc
   ```

2. **Import the Snazzy theme in iTerm2**:
   - Open iTerm2
   - Go to `iTerm2 > Preferences > Profiles > Colors`
   - Click `Color Presets` > `Import`
   - Select: `~/.iterm2/themes/Snazzy.itermcolors`
   - Choose `Snazzy` from the `Color Presets` dropdown

3. **Set JetBrains Mono Nerd Font**:
   - Go to `iTerm2 > Preferences > Profiles > Text`
   - Change font to `JetBrainsMono Nerd Font`
   - Recommended size: 13-14pt

## 📁 Structure

```
.
├── README.md           # This file
├── Brewfile           # Homebrew packages and casks
├── .zshrc             # Zsh configuration with plugins
└── install.sh         # Installation script
```

## 🛠️ Customization

### Modifying Installed Packages

Edit the `Brewfile` to add or remove packages, then run:

```bash
brew bundle --file=~/.dotfiles/Brewfile
```

### Updating Zsh Configuration

Edit `~/.zshrc` directly or modify `.zshrc` in this repo and copy it:

```bash
cp ~/.dotfiles/.zshrc ~/.zshrc
source ~/.zshrc
```

### Using Starship Instead of Pure

The `.zshrc` includes starship but it's commented out. To use it:

1. Comment out the Pure prompt plugin in `.zshrc`
2. Uncomment the starship initialization line
3. Reload: `source ~/.zshrc`

## 🔄 Updating

To update all packages and plugins:

```bash
# Update Homebrew packages
brew update && brew upgrade

# Update zplug plugins
zplug update
```

## 📝 License

Feel free to use and modify these dotfiles for your own setup!

## 🙏 Credits

- [Pure Prompt](https://github.com/sindresorhus/pure) by Sindre Sorhus
- [Snazzy iTerm2 Theme](https://github.com/sindresorhus/iterm2-snazzy) by Sindre Sorhus
- [zplug](https://github.com/zplug/zplug) - Zsh plugin manager
- All the amazing tools included in this setup