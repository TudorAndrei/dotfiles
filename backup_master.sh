#!/bin/sh


cp ~/.config/nvim/init.vim ./nvim/init.vim
rsync -ar ~/.config/redshift .

echo "Done"
