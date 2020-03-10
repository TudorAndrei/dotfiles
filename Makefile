all:
	cp ~/.zshrc .
	echo "done with zshrc"
	cp ~/.vimrc .
	echo "done with vimrc"
	git add .
	git commit -m "updated dotfiles"
	git push
