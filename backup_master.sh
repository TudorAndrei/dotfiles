#!/bin/sh


cp ~/.zshrc ./zsh/
cp ~/.vimrc ./vim/
cp ~/.config/nvim/init.vim ./nvim/init.vim
cp -ar ~/.config/redshift .
cp ~/.config/starship.toml .

rsync -ar ~/.config/alacritty .
rsync -ar ~/.config/i3 .
rsync -ar ~/.config/i3blocks ./i3
rsync -ar /usr/share/i3blocks ./i3-scripts/
rsync -ar ~/.config/redshift .

echo "Done"
