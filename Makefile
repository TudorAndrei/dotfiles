all:
	cp ~/.zshrc .
	cp ~/.vimrc .
	cp ~/.config/i3/config .
	cp ~/.config/i3/i3blocks.conf .
	git add .
	git commit -m "updated dotfiles"
	git push

zsh:
	cp ~/.zshrc .

vim:
	cp ~/.vimrc .


git: 
	git add .
	git commit -m "updated dotfiles"
	git push

base: zsh vim git
