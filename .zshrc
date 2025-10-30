if (( $+commands[tmux] && ! $+TMUX && $+SSH_CONNECTION )); then
    tmux has -t ssh 2>/dev/null && exec tmux attach -t ssh
    exec tmux new -s ssh
fi

typeset -U path
path+=(~/bin(N-/) ~/.local/bin(N-/) ~/.local/share/bin(N-/))

typeset -U fpath
fpath+=(~/.local/share/zsh/site-functions(N-/))

typeset -U cdpath
cdpath+=(~ ~/src(N-/))

bindkey -e

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

function zcomp() {
    local f
    for f; do zcompile -R -- $f.zwc $f; done
}

function src-all() {
    local f
    for f; do source $f; done
}

function plugload() {
    local repo=https://github.com/$1
    local plug=~/.zsh-plugins/$1
    shift
    if [[ ! -e $plug ]]; then
        git clone --depth=1 $repo $plug
        zcomp $plug/*.zsh $plug/**/*.zsh
    fi
    if (( $# )); then
        src-all ${@/#/$plug/}(N-)
    else
        src-all $plug/*.plugin.zsh(N-)
    fi
}

function eval-cache() {
    local cmd=$1 cache=~/.cache/zsh/eval/${1%% *}.zsh
    if [[ ! -s $cache ]]; then
        install -Dm0644 /dev/null $cache
        eval $cmd > $cache
    fi
    if [[ ! -e $cache.zwc || $cache -nt $cache.zwc ]]; then
        zcompile $cache
    fi
    source $cache
}

function func-cache() {
    local cmd=$1 compfile=~/.local/share/zsh/site-functions/_${1%% *}
    if [[ ! -s $compfile ]]; then
        install -Dm0644 /dev/null $compfile
        eval $cmd > $compfile
    fi
    if [[ ! -e $compfile.zwc || $compfile -nt $compfile.zwc ]]; then
        zcompile $compfile
    fi
}

plugload zsh-users/zsh-completions
plugload zsh-users/zsh-autosuggestions
plugload zsh-users/zsh-syntax-highlighting
plugload zsh-users/zaw
plugload sorin-ionescu/prezto modules/{command-not-found,completion,history}/init.zsh

PURE_PROMPT_SYMBOL='›'
PURE_PROMPT_VICMD_SYMBOL='‹'

zstyle ':prompt:pure:git:stash' show yes
zstyle ':prompt:pure:prompt:success' color green
zstyle ':prompt:pure:prompt:error' color red

plugload sindresorhus/pure {async,pure}.zsh

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
    export NNN_OPTS=aAdJo

    export NNN_OPENER=~/.config/nnn/plugins/open-with-viewed

    typeset -TUx NNN_BMS nnn_bms \;

    if [[ ! -f ~/.config/nnn/plugins/.nnn-plugin-helper ]]; then
        curl -fsSL https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
    fi

    typeset -TUx NNN_PLUG nnn_plug \;
    nnn_plug+=(m:toggle-viewed v:filter-viewed)
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

unfunction zcomp src-all plugload eval-cache func-cache
