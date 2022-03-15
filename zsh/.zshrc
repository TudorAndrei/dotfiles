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
# alias ohmyzsh="nvim ~/.oh-my-zsh"
alias sdown='sudo shutdown now'
alias rr='sudo shutdown -r now'
alias mst='cd ~/projects/mst'
alias btkb="~/.dotfiles/swapcaps.sh"
alias listfnt="fc-list -f '%{family}\n' | awk '!x[$0]++' "
alias bigfiles='du -hs $(ls -A) | sort -rh | head -5'
alias blog='cd ~/projects/blog/'
# Tmux
alias rtmux="tmux source-file ~/.tmux.conf"
alias tconf="nvim ~/.tmux.conf"
alias tsess='tmux new -s mysession'
# nvim
alias n="nvim"
alias vc="nvim ~/.vimrc"
alias nvc="cd ~/.config/nvim && nvim ~/.config/nvim/init.vim"
# TERM
alias urxvtconfig="nvim ~/.Xresources"
alias alaconfig="nvim ~/.config/alacritty/alacritty.yml"
# GPU
alias gput="python -c 'import torch;print(torch.cuda.is_available())'"
alias gputf="python -c 'import tensorflow as tf;tf.config.list_physical_devices()'"
# Random
alias rpdf="zathura"
alias mpdf="pdflatex"
alias nvd="watch -n 2 nvidia-smi"
alias code="codium ."
alias si3="cp /usr/share/i3blocks"
alias mergepdf="gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=merged.pdf"
pdfcompress ()
{
   gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dPDFSETTINGS=/screen -dEmbedAllFonts=true -dSubsetFonts=true -dColorImageDownsampleType=/Bicubic -dColorImageResolution=144 -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=144 -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=144 -sOutputFile=${1%.*}.compressed.pdf $1;
}
alias makebmr="cp ~/projects/littlebrain/templates/beamer_template.rmd ."
alias makermd="cp ~/projects/littlebrain/templates/pdf_template.rmd ."
alias xd='xdg-open'
# alias docker="sudo docker"

# Blog
# alias newp="thor jekyll:new"
alias opblog="firefox blog.tudorandrei.xyz"

# Conda
alias ca="conda activate"
alias ci="conda install"
alias ccn="conda create --name"
alias cel="conda env list"
alias cex='conda env export | grep -v "^prefix: " > environment.yml'

# Mamba
alias ma="mamba activate"
alias mi="mamba install"
alias mcn="mamba create --file ~/.dotfiles/conda/spec-file.txt --name"
alias mel="mamba env list"

# python
alias py="python"
alias jn='jupyter notebook'
alias jl='jupyter lab'

# i3
alias ci3="nvim ~/.config/i3/config"
alias ci3b="nvim ~/.config/i3blocks/i3blocks.conf"

# Flask
alias fr="FLASK_APP=app.py flask run"

# Django
alias rs='python manage.py runserver'
alias mig='python manage.py migrate'
alias mkmig="python manage.py makemigrations"

# Docker
alias dcu='sudo docker-compose up'
alias dcud='sudo docker-compose up -d'

# Server
alias stoptunnel='[[ -f /tmp/sshuttle.pid ]] && kill `cat /tmp/sshuttle.pid`'
alias open_server='ssh tudor@109.99.95.137 -i ~/.ssh/cautorice_key -p 54322'
alias pods='ssh vingilot  "/bin/zsh | gp"'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/tudor/.mamba/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/tudor/.mamba/etc/profile.d/conda.sh" ]; then
        . "/home/tudor/.mamba/etc/profile.d/conda.sh"
    else
        export PATH="/home/tudor/.mamba/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/home/tudor/.mamba/etc/profile.d/mamba.sh" ]; then
    . "/home/tudor/.mamba/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

export GEM_HOME="$HOME/.config/gems"
export PATH="$HOME/.config/gems/bin:$PATH"
export TERMINAL="/usr/bin/alacritty"
# fnm
export PATH=/home/tudor/.fnm:$PATH
eval "`fnm env`"
eval "$(starship init zsh)"

alias luamake=/home/tudor/projects/lua-language-server/3rd/luamake/luamake
