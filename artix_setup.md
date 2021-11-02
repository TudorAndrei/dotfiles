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

Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`
add userChrome.css

# Zsh
```
sudo pacman -S zsh
chsh -s $(which zsh)
```
# Alacritty
```
sudo yay -S alacritty
```
# Starship
```
sh -c "$(curl -fsSL https://starship.rs/install.sh)"
```
