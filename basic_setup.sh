sudo apt install -y git gcc g++ cmake compton neovim

sudo apt install -y zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
cp ./.zshrc ~/
cp ./dracula.zsh-theme ~/.oh-my-zsh/themes/

git config --global user.name "TudorAndrei"
git config --global user.email "tudorandrei.dumitrascu@gmail.com"
