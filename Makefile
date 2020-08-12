all:
	cp ~/.zshrc .
	cp ~/.vimrc .
	cp ~/.config/i3/config ./i3/.
	cp ~/.config/i3blocks/i3blocks.conf ./i3/.
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
