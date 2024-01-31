export EDITOR='nvim'
export VISUAL='nvim'
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
# Start configuration added by Zim install {{{
# User configuration sourced by interactive shells
# -----------------
# Zsh configuration
# -----------------
# History
# Remove older command from the history if a duplicate is to be added.
setopt HIST_IGNORE_ALL_DUPS

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
zstyle ':zim:zmodule' use 'degit'

# --------------------
# Module configuration
# --------------------

#
# git
#

# Set a custom prefix for the generated aliases. The default prefix is 'G'.
zstyle ':zim:git' aliases-prefix 'G'

#
# input
#

# Disable automatic widget re-binding on each precmd. This can be set when
# zsh-users/zsh-autosuggestions is the last module in your ~/.zimrc.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Customize the style that the suggestions are shown with.
# See https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#suggestion-highlight-style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Customize the main highlighter styles.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md#how-to-tweak-it
#typeset -A ZSH_HIGHLIGHT_STYLES
#ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------

#
# zsh-history-substring-search
#

zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key
# }}} End configuration added by Zim install

# If you come from bash you might have to change your $PATH.
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:/home/hyperion/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="${PATH}:${HOME}/.local/share/bob/nvim-bin"
export PATH="${PATH}:${HOME}/.local/bin/"
export PATH="$HOME/cave/bits:$PATH"
export PATH="${PATH}:/usr/local/go/bin"
export PATH="${PATH}:/home/tudor/.surrealdb"
export PATH="$DENO_INSTALL/bin:$PATH"
export JAVA_HOME="/usr/bin/javac"
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
alias sshc="nvim ~/.ssh/config"
alias k="k -Aht"
alias mk="minikube"
alias ld="lazydocker"
alias afz="alias | fzf"
alias sshc="nvim ~/.ssh/config"
# Git
alias gcm="git commit -a --allow-empty-message -m ''"
alias gdocs="git add docs/* mkdocs.yml && git commit -m 'Update Docs' && git push"
alias gl="git log --pretty=oneline"
alias glg="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

alias sdown='sudo shutdown now'
alias rr='sudo shutdown -r now'
alias mst='cd ~/cave/mst'
alias btkb="~/.dotfiles/swapcaps.sh"
alias listfnt="fc-list -f '%{family}\n' | awk '!x[$0]++' "
alias bigfiles='du -hs $(ls -A) | sort -rh | head -5'
alias blog='cd ~/cave/blog/'
# Tmux
alias rtmux="tmux source-file ~/.tmux.conf"
alias tconf="nvim ~/.tmux.conf"
alias tsess='tmux new -s mysession'
# nvim
alias n="nvim"
alias vc="nvim ~/.vimrc"
alias nvc="cd ~/.config/nvim && nvim"
# TERM
alias uconfig="nvim ~/.Xresources"
alias aconfig="nvim ~/.config/alacritty/alacritty.toml"
alias kconf="nvim ~/.config/kitty/kitty.conf"
# GPU
alias gput="python -c 'import torch;print(torch.cuda.is_available())'"
alias gputf="python -c 'import tensorflow as tf;tf.config.list_physical_devices()'"
# Random
alias rpdf="zathura"
alias mpdf="pdflatex"
alias nvd="watch -n 2 nvidia-smi"
alias nvi="nvitop --monitor compact"
alias mergepdf="gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -sOutputFile=merged.pdf"


pdfcompress ()
{
   gs -q -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite -dCompatibilityLevel=1.3 -dPDFSETTINGS=/screen -dEmbedAllFonts=true -dSubsetFonts=true -dColorImageDownsampleType=/Bicubic -dColorImageResolution=144 -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=144 -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=144 -sOutputFile=${1%.*}.compressed.pdf $1;
}
alias makebmr="cp ~/cave/littlebrain/templates/beamer_template.rmd ."
alias makermd="cp ~/cave/littlebrain/templates/pdf_template.rmd ."
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
alias mcn="mamba create --file ~/dotfiles/conda/spec-file.txt --name"
alias mel="mamba env list"

# python
alias sr="streamlit run"
alias py="python"
alias jn='jupyter notebook'
alias jl='jupyter lab'
alias svd="source .venv_dev/bin/activate"
alias svp="source .venv_prod/bin/activate"
alias sv="source .venv/bin/activate"

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

alias stoptunnel='[[ -f /tmp/sshuttle.pid ]] && kill `cat /tmp/sshuttle.pid`'
# Server
alias open_server='ssh tudor@109.99.95.137 -i ~/.ssh/cautorice_key -p 54322'
alias pods='ssh vingilot  "/bin/zsh | gp"'

alias luamake=/home/tudor/cave/lua-language-server/3rd/luamake/luamake
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
export TERMINAL="/usr/bin/kitty"

# fnm
export PATH=/home/tudor/.fnm:$PATH
eval "`fnm env`"

PATH="/home/tudor/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/tudor/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/tudor/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/tudor/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/tudor/perl5"; export PERL_MM_OPT;


# bun completions
[ -s "/home/tudor/.bun/_bun" ] && source "/home/tudor/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# # pnpm
# export PNPM_HOME="/home/tudor/.local/share/pnpm"
# case ":$PATH:" in
#   *":$PNPM_HOME:"*) ;;
#   *) export PATH="$PNPM_HOME:$PATH" ;;
# esac
# pnpm end
export MODULAR_HOME="/home/tudor/.modular"
export PATH="/home/tudor/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

# fnm
export PATH="/home/tudor/.local/share/fnm:$PATH"
eval "`fnm env`"

source "$HOME/.rye/env"

eval "$(starship init zsh)"
