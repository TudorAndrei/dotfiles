sudo apt install -y git gcc g++ cmake compton neovim

sudo apt install -y zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
cp ../zsh/.zshrc ~/
cp ../zsh/dracula.zsh-theme ~/.oh-my-zsh/themes/

git config --global user.name "TudorAndrei"
git config --global user.email "tudorandrei.dumitrascu@gmail.com"

../i3-gaps/install_i3-gaps_utils.sh && ../i3-gaps/install_i3g.sh
