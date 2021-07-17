# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="${PATH}:${HOME}/.local/bin/"
# Path to your oh-my-zsh installation.

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='nvim'
 fi

# Shortcuts
alias ..="cd .."
alias zc="nvim ~/.zshrc"
alias szsh="source ~/.zshrc"
alias vimconfig="nvim ~/.vimrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias sdown='sudo shutdown now'
alias rr='sudo shutdown -r now'
alias mst='cd ~/projects/mst'
alias pml='cd ~/projects/mst/pml; ca pml'
alias pp='cd ~/projects/mst/pp; ca pp'
alias krr='cd ~/projects/mst/krr; ca krr'
alias btkb="~/.dotfiles/swapcaps.sh"
# nvim
alias n="nvim"
alias vc="nvim ~/.vimrc"
alias nvc="nvim ~/.config/nvim/init.vim"
# TERM
alias urxvtconfig="nvim ~/.Xresources"
alias alaconfig="nvim ~/.config/alacritty/alacritty.yml"
# GPU
alias gput="python -c 'import torch;print(torch.cuda.is_available())'"
alias gputf="python -c 'import tensorflow as tf;tf.config.list_physical_devices('GPU')'"

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
alias tmux="tmux -f /home/tudor/.config/tmux/.tmux.conf"

# Blog
alias newp="thor jekyll:new"
alias opblog="firefox tudorandrei.github.io"

# Conda
alias ca="conda activate"
alias ci="conda install"
alias ccn="conda create --name"
alias cel="conda env list"
alias py="python"
alias jn='jupyter notebook'
alias jl='jupyter lab'

# i3
alias ci3="nvim ~/.config/i3/config"
alias ci3b="nvim ~/.config/i3blocks/i3blocks.conf"

# Django
alias rs='python manage.py runserver'
alias mig='python manage.py migrate'
alias mkmig="python manage.py makemigrations"

# Docker
alias dcu='sudo docker-compose up'
alias dcud='sudo docker-compose up -d'

# Server
alias open_server='ssh tudor@109.99.95.137 -i ~/.ssh/cautorice_key -p 54322'
alias login6='ssh studdumitrascu@login6.informatik.uni-wuerzburg.de -i ~/.ssh/cluster_acces'
alias vingilot='ssh studdumitrascu@vingilot.informatik.uni-wuerzburg.de -i ~/.ssh/cluster_acces'

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
nvm() {
    unset -f nvm
    export NVM_DIR=~/.nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    nvm "$@"
}

node() {
    unset -f node
    export NVM_DIR=~/.nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    node "$@"
}

npm() {
    unset -f npm
    export NVM_DIR=~/.nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
    npm "$@"
}

eval "$(starship init zsh)"
