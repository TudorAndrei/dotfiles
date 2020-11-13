# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="${PATH}:${HOME}/.local/bin/"
# Path to your oh-my-zsh installation.
export ZSH="/home/tudor/.oh-my-zsh"

ZSH_THEME="dracula"


plugins=(git
      	colored-man-pages
       	colorize
       	extract
       	zsh-syntax-highlighting
      	pep8
        pylint)


ZSH_COLORIZE_TOOL=pygmentize
ZSH_COLORIZE_STYLE="colorful"
source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='nvim'
 fi

# Shortcuts
alias zshconfig="nvim ~/.zshrc"
alias szsh="source ~/.zshrc"
alias vimconfig="nvim ~/.vimrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias sdown='sudo shutdown now'
alias rr='sudo shutdown -r now'
# nvim
alias n="nvim"
alias vimconfig="nvim ~/.vimrc"
alias nvimconfig="nvim ~/.config/nvim/init.vim"
alias nvimplug="nvim ~/.config/nvim/vim-plug/plugins.vim"
alias nvimsettings="nvim ~/.config/nvim/general/settings.vim"
# TERM
alias urxvtconfig="nvim ~/.Xresources"
alias alaconfig="nvim ~/.config/alacritty/alacritty.yml"
# Random
alias rpdf="zathura"
alias mpdf="pdflatex"
alias nvsmi="nvidia-smi --loop=2"
alias gonotes="cd ~/Documents/notes"
alias code="codium ."
alias gh="firefox https://github.com/"
alias si3="cp /usr/share/i3blocks"
alias mergepdf="gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=merged.pdf"
alias makebmr="cp ~/Documents/templates/beamer_template.rmd ."
alias makermd="cp ~/Documents/templates/pdf_template.rmd"
alias xd='xdg-open'
alias docker="sudo docker"
# Blog
alias newp="thor jekyll:new"
alias opblog="firefox tudorandrei.github.io"
# Conda
alias ca="conda activate"
alias ci="conda install"
alias ccn="conda create --name"
alias cel="conda env list"
alias py="python"
# i3
alias ci3="nvim ~/.config/i3/config"
alias ci3b="nvim ~/.config/i3blocks/i3blocks.conf"
# Django
alias rs='python manage.py runserver'
alias mig='python manage.py migrate'
alias mkmig="python manage.py makemigrations"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/tudor/.miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/tudor/.miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/tudor/.miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/tudor/.miniconda3/bin"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export GEM_HOME="$HOME/.config/gems"
export PATH="$HOME/.config/gems/bin:$PATH"
export TERMINAL="/usr/bin/alacritty"

lazynvm(){
  unset -f nvm node npm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

nvm() {
  lazynvm
  nvm $@
}

node() {
  lazynvm
  node $@
}

npm() {
  lazynvm
  npm $@
}
