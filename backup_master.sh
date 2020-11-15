#!/bin/sh


cp ~/.zshrc .
cp ~/.vimrc .
cp ~/.config/i3/config ./i3/.
cp ~/.config/i3blocks/i3blocks.conf ./i3/.
rsync -ar --exclude=~/.config/nvim/autoload ~/.config/nvim .
rm -rf ./nvim/autoload
cp -ar ~/.config/compton/ .
echo "Done"
