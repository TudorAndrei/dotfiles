all: backup git

zsh:
	cp ~/.zshrc .

vim:
	cp ~/.vimrc .
	cp -avr ~/.config/nvim .
i3:
	cp ~/.config/i3/config ./i3/.
	cp ~/.config/i3blocks/i3blocks.conf ./i3/.

backup:
	cp ~/.zshrc .
	cp ~/.vimrc .
	cp ~/.config/i3/config ./i3/.
	cp ~/.config/i3blocks/i3blocks.conf ./i3/.
	cp -avr ~/.config/nvim/ .

git:
	git add .
	git commit -m "updated dotfiles"
	git push

