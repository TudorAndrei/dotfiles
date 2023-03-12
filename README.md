# dotfiles

Keep track of my dotfiles

## Packages

### Terminal

- [alacritty](https://github.com/alacritty/alacritty)
- [Zsh](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)

  - [zimfw](https://github.com/zimfw/zimfw)

    - environment
    - git
    - archive
    - utility
    - fzf
    - duration-info
    - rimraf/k
    - agkozak/zsh-z
    - zsh-user/zsh-syntax-highlighting
    - zsh-user/zsh-history-substring-search
    - zsh-users/zsh-completions

  - [starship](https://github.com/starship/starship)

- [Bat](https://github.com/sharkdp/bat)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fnm](https://github.com/Schniz/fnm#completions)

- Conda
  - [Mamba](https://github.com/conda-forge/miniforge#mambaforge)
- [Neovim](https://github.com/TudorAndrei/nvim)
- LaTeX

### Window manager

- arandr
- i3
  - i3-blocks
- blueman
- nmapplet

### Font

- Nerd hack Font

### Keyboard

```
echo "options hid_apple fnmode=0" | sudo tee -a /etc/modprobe.d/hid_apple.conf
```

# Firefox

```
Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`
add userChrome.css
```
