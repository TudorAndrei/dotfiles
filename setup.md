# Keyboard

```
echo "options hid_apple fnmode=0" | sudo tee -a /etc/modprobe.d/hid_apple.conf
```

# Packages

- mamba forge
- Neovim

- # Firefox

# Update

```
sudo pacman -Syu
```

# Yay

```
sudo pacman -S base-devel git
cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $USER:users ./yay
cd yay
makepkg -si
```

# miniconda

```
yay miniconda
```

# Neovim

```
sudo pacman -S neovim
```

# Firefox

# Packages

- mamba forge
- Neovim
- Firefox

add in `/etc/pacman.conf`

```
[extra]
Include = /etc/pacman.d/mirrorlist-arch
```

```
sudo pacman -S artix-archlinux-support
sudo pacman -Sy
sudo pacman -S firefox
```

```
Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`
add userChrome.css
```

- zsh
  <<<<<<< HEAD

```
chsh -s $(which zsh)
```

- alacritty

- starship

# Zsh

=======

```
sudo pacman -S zsh
chsh -s $(which zsh)
```

- alacritty

- starship

```
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
```

- nmapplet

- blueman

- Font
  Nerd Hack Font

- Discord
- Slack
- Transmission-gtk
- Steam
- Lutris
- Spotify
- Feh
- nvtop
- Latex

```
sudo apt install texlive-full
```

- R install

```
sudo apt install r-base
sudo R
> install.package("rmarkdown")
> install.package("reticulate")
```
