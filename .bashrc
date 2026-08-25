# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
# [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

alias ls="ls /"

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='lsd --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='lsd -alF'
alias la='lsd -A'
alias l='tree "$(pwd)" -L 3'
alias vim='nvim'
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias watch='watch -n 0.5'
alias silent-alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias alert='notify-send -t 0 -h string:sound-name:complete-download "$([ $? -eq 0 ] && echo Done || echo Failed)" "$(history | tail -n1 | sed -E '\''s/^[[:space:]]*[0-9]+[[:space:]]*//; s/[;&|][[:space:]]*alert$//'\'' )"'
alias al='alert'
alias ai="echo 'AI: ' && ollama run llama3.2"
alias ai2="echo 'AI: ' && ollama run llama2-uncensored"
alias vag="vagrant"
alias pupsik="chafa $HOME/.config/pupsik.jpg --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1"
alias ip="ip -c"
alias tree="tree --dirsfirst"
alias pacman="sudo pacman"
alias c="clear"
alias d="docker"
alias vi="vim"
alias v="vim"
alias findprojectbyip="python3 /home/mivanchenko/Projects/pythonOpenstack/findProjectByIp.py"
alias k="kubectl"
alias p3="python3"
alias ":q"="exit"
alias ":wq"="exit"
alias "hometunnel"="ssh -D 1080 -C -N mivanchenko@mivanchenko.de"
alias "openstacksource"="source ~/python-venv/openstack/bin/activate; export CLIFF_FIT_WIDTH=1"
alias "os-staging"="export OS_CLOUD=staging; source ~/python-venv/openstack/bin/activate"
alias "os-production"="export OS_PROJECT_NAME=21020-openstack-eee84; export OS_CLOUD=; source ~/python-venv/openstack/bin/activate; source ~/nws-id-openstack-rc.sh"
alias "nwd"="source ~/python-venv/openstack/bin/activate; source nwd-id-openstack-rc.sh"
os-project() {
    export OS_PROJECT_NAME=$1
}
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
# if [ -S ~/.ssh/socket ]; then
#     eval $(ssh-agent)
#     ln -sf "$SSH_AUTH_SOCK" ~/.ssh/socket
# fi
set_openstack_ps1() {
    local project="${OS_PROJECT_NAME:-${OS_CLOUD:-}}"
    local prefix=""

    [[ -n "$VIRTUAL_ENV" ]] && prefix="$(basename "$VIRTUAL_ENV")"
    [[ -n "$project" ]] && prefix="${prefix:+$prefix | }$project"
    [[ -n "$prefix" ]] && prefix="($prefix) "

    PS1="${prefix}\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ "
}

PROMPT_COMMAND=set_openstack_ps1
# export SSH_AUTH_SOCK=~/.ssh/socket
# eval "$(starship init bash)"
export EDITOR=nvim
# shopt -s autocd
# Disabled: was fighting with dracula/tmux (~/.tmux.conf) on every new
# pane/window/shell, overwriting its colors right after they applied.
# [ -n "$TMUX" ] && eval "$(/home/mivanchenko/.tmux/nord.tmux)"
# Reuse keychain's cached agent env instead of forking the keychain script
# on every shell start (~0.12s); only re-run keychain if the cached socket
# is actually dead (e.g. after a reboot).
_keychain_sh="$HOME/.keychain/$HOSTNAME-sh"
[ -f "$_keychain_sh" ] && . "$_keychain_sh"
if [ -z "$SSH_AUTH_SOCK" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
    eval $(keychain --eval --quiet id_ed25519 id_ed25519_sk)
fi
unset _keychain_sh
# export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
# source <(carapace _carapace)
[ -f '/home/mivanchenko/.config/.bash_completions/comfy.sh' ] && source '/home/mivanchenko/.config/.bash_completions/comfy.sh'
export PATH="$HOME/.local/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
# Lazy-load nvm: real nvm.sh (and its bash_completion) is only sourced the
# first time nvm/node/npm/npx is actually invoked, instead of on every shell start.
nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
}
node() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    node "$@"
}
npm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    npm "$@"
}
npx() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    npx "$@"
}
export PATH="/usr/local/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$PATH:/usr/sbin:/sbin"
export PATH="$PATH:/usr/games"



# >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/mivanchenko/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/mivanchenko/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/mivanchenko/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/mivanchenko/miniconda3/bin:$PATH"
#     fi
# fi
unset __conda_setup
# <<< conda initialize <<<


# opencode
export PATH=/home/mivanchenko/.opencode/bin:$PATH

# brew shellenv output is static for a fixed linuxbrew prefix; hardcode it
# instead of forking brew (a Ruby-backed binary) on every shell start.
if [ -x "$HOME/.linuxbrew/bin/brew" ]; then
    export HOMEBREW_PREFIX="$HOME/.linuxbrew"
    export HOMEBREW_CELLAR="$HOME/.linuxbrew/Cellar"
    export HOMEBREW_REPOSITORY="$HOME/.linuxbrew/Homebrew"
    export PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin${PATH+:$PATH}"
    [ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
    export INFOPATH="$HOME/.linuxbrew/share/info:${INFOPATH:-}"
fi
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# OpenClaw Completion
[ -f "/home/mivanchenko/.openclaw/completions/openclaw.bash" ] && source "/home/mivanchenko/.openclaw/completions/openclaw.bash"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

. "$HOME/.atuin/bin/env"
eval "$(atuin init bash)"
