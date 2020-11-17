#!/bin/sh


cp ~/.zshrc ./zsh/
cp ~/.vimrc ./vim/

rsync -ar --exclude=~/.config/nvim/autoload ~/.config/nvim .
rsync -ar ~/.config/alacritty .
rsync -ar ~/.config/i3 ./i3/

rm -rf ./nvim/autoload
cp -ar ~/.config/compton/ ..
echo "Done"
