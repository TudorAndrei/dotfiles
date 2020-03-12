all:
	cp ~/.zshrc .
	cp ~/.vimrc .
	cp ~/.config/i3/config .
	cp -r ~/.config/i3blocks/. ./i3blocks
	git add .
	git commit -m "updated dotfiles"
	git push
