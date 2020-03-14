all:
	cp ~/.zshrc .
	cp ~/.vimrc .
	cp ~/.config/i3/config .
	cp ~/.config/i3/i3blocks.conf .
	git add .
	git commit -m "updated dotfiles"
	git push
