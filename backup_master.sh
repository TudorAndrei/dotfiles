#!/bin/sh


cp ~/.zshrc ./zsh/
cp ~/.vimrc ./vim/
cp ~/.config/nvim ./nvim/init.vim

rsync -ar ~/.config/alacritty .
rsync -ar ~/.config/i3 .
rsync -ar ~/.config/i3blocks ./i3
rsync -ar /usr/share/i3blocks ./i3-scripts/
rsync -ar ~/.config/redshift .

rm -rf ./nvim/autoload
cp -ar ~/.config/compton/ ..
echo "Done"
