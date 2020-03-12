all:
	cp ~/.zshrc .
	echo "done with zshrc"
	cp ~/.vimrc .
	echo "done with vimrc"
	cp ~/.config/i3/config .
	echo "done with i3"
	git add .
	git commit -m "updated dotfiles"
	git push
