sudo apt install texlive-full r-base bat git gcc g++ cmake compton zsh alacritty rofi -y
# starship
curl -sS https://starship.rs/install.sh | sh

# Bat install
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat


git config --global user.name "TudorAndrei"
git config --global user.email "tudorandrei.dumitrascu@gmail.com"

# cp ../zsh/.zshrc ~/
# cp ../zsh/dracula.zsh-theme ~/.oh-my-zsh/themes/
