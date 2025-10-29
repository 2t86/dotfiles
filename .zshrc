if (( $+commands[tmux] && ! $+TMUX && $+SSH_CONNECTION )); then
    tmux has 2>/dev/null && exec tmux attach
    exec tmux new
fi

typeset -U path
path+=(~/bin(N-/) ~/.local/share/bin(N-/))

typeset -U cdpath
cdpath+=(~ ~/src(N-/))

setopt EXTENDED_GLOB
setopt NULL_GLOB

export HISTFILE=~/.zsh_history
export SAVEHIST=100000
export HISTSIZE=$((SAVEHIST + 1))

setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

alias history='fc -dl -t "%Y-%m-%d %H:%M:%S"'

bindkey  history-incremental-pattern-search-backward
bindkey  history-incremental-pattern-search-forward
bindkey  history-beginning-search-backward
bindkey  history-beginning-search-forward

autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
        compinit
else
        compinit -C
fi

autoload -Uz url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

autoload -Uz select-word-style
select-word-style shell

zstyle ':zle:my-backward-word' word-style unspecified
zstyle ':zle:my-backward-word' word-chars ' /=;@:{}[]()<>,|.'
function my-backward-word() { zle backward-word }
zle -N my-backward-word
bindkey b my-backward-word

zstyle ':zle:my-forward-word' word-style unspecified
zstyle ':zle:my-forward-word' word-chars ' /=;@:{}[]()<>,|.'
function my-forward-word() { zle forward-word }
zle -N my-forward-word
bindkey f my-forward-word

zstyle ':zle:my-backward-kill-word' word-style unspecified
zstyle ':zle:my-backward-kill-word' word-chars ' /=;@:{}[]()<>,|.'
function my-backward-kill-word() { zle backward-kill-word }
zle -N my-backward-kill-word
bindkey w my-backward-kill-word

clear_screen_and_scrollback() { printf '\x1Bc'; zle clear-screen }
zle -N clear_screen_and_scrollback
bindkey  clear_screen_and_scrollback

reset_broken_terminal() { printf '%b' '\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8' }
precmd_functions+=(reset_broken_terminal)

function zc() {
    local f
    for f; do zcompile -R -- $f.zwc $f; done
}

func5ion s() {
    local f
    for f; do source $f; done
}

function pl() {
    local repo=https://github.com/$1
    local plug=~/.zsh-plugins/$1
    shift
    if [[ ! -e $plug ]]; then
        git clone --depth=1 $repo $plug
        zc $plug/*.zsh $plug/**/*.zsh
    fi
    if (( $# )); then
        s ${@/#/$plug/}(N-)
    else
        s $plug/*.plugin.zsh(N-)
    fi
}

pl zsh-users/zsh-completions
pl zsh-users/zsh-autosuggestions
pl zsh-users/zsh-syntax-highlighting
pl zsh-users/zaw
pl sorin-ionescu/prezto modules/{command-not-found,completion,history}/init.zsh

PURE_PROMPT_SYMBOL='›'
PURE_PROMPT_VICMD_SYMBOL='‹'

zstyle ':prompt:pure:git:stash' show yes
zstyle ':prompt:pure:prompt:success' color green
zstyle ':prompt:pure:prompt:error' color red

pl sindresorhus/pure {async,pure}.zsh

unfunction zc pl

alias relogin='exec zsh -l'
alias ls='ls -Xv --color=auto --group-directories-first'
alias grep='grep --color=auto'
alias mv='mv -vb'
alias cp='cp -vb'

function mkcd() { install -Dd "$1" && cd "$1" }

DOTFILES_GIT_DIR=~/.dotfiles
DOTFILES_WORK_TREE=~

alias dotfiles='git --git-dir $DOTFILES_GIT_DIR --work-tree $DOTFILES_WORK_TREE'

compdef dotfiles=git

if [[ ! -d $DOTFILES_GIT_DIR ]]; then
    dotfiles init
    dotfiles config init.defaultBranch main
    dotfiles config user.name "$USER"
    dotfiles config user.email "$USER@$HOST"
fi

if (( $+commands[emacs] )); then
    alias emacs='emacsclient -a emacs -t'
fi

if (( $+commands[nnn] )); then
    export NNN_OPTS=ABdHJoS
    export NNN_FCOLORS=c1e2272e006033f7c6d6abc4

    typeset -TUx NNN_BMS nnn_bms \;
    typeset -TUx NNN_PLUG nnn_plug \;
fi

if (( $+commands[pass] )); then
    export PASSWORD_STORE_ENABLE_EXTENSIONS=true
fi

if (( $+commands[vim] )); then
    export EDITOR=vim
fi

() {
    local src=$1 zwc=$1.zwc
    [[ -n $src ]] || return 0
    if [[ ! -f $zwc || $src -nt $zwc ]]; then
        zcompile $src
    fi
    source $src
} ~/.zshrc.*~.zwc~*\~
