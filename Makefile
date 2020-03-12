all:
	cp ~/.zshrc .
	cp ~/.vimrc .
	cp ~/.config/i3/config .
	cp ~/.config/i3blocks/config ./i3blocks
	git add .
	git commit -m "updated dotfiles"
	git push
