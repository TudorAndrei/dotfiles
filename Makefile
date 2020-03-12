all:
	cp ~/.zshrc .
	cp ~/.vimrc .
	cp ~/.config/i3/config .
	rsync -av ~/.config/i3blocks . --exclude .git --exclude .gitignore	
	git add .
	git commit -m "updated dotfiles"
	git push
