# ----------------------------------------------------------------------
# Powerlevel10k Instant Prompt
# ----------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------------------------------------------------
# Zsh Configuration: History & Input
# ----------------------------------------------------------------------
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_ignore_space
setopt hist_expire_dups_first
setopt hist_reduce_blanks
typeset -U PATH

bindkey -e
setopt CORRECT
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
WORDCHARS=${WORDCHARS//[\/]}

unalias run-help
autoload -Uz run-help

# ----------------------------------------------------------------------
# Zim Module Configuration
# ----------------------------------------------------------------------
zstyle ':zim:input' double-dot-expand yes

ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
source ${ZIM_HOME}/init.zsh

# ----------------------------------------------------------------------
# Terminal Title Configuration
# ----------------------------------------------------------------------
autoload -Uz add-zsh-hook

set_win_title_precmd() {
  print -Pn "\e]2;zsh  %1~  %l\a"
}

set_win_title_preexec() {
  local cmd="${1%% *}"
  cmd="${cmd##*/}"
  print -Pn "\e]2;${cmd}  %1~  %l\a"
}

add-zsh-hook precmd set_win_title_precmd
add-zsh-hook preexec set_win_title_preexec

zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# ----------------------------------------------------------------------
# Exports
# ----------------------------------------------------------------------
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git --exclude node_modules --exclude .cache --exclude venv --exclude dist'

export FZF_DEFAULT_OPTS="
  --layout=reverse
  --cycle
  --highlight-line
  --info=inline-right
  --preview-window='right:50%,nowrap'
  --preview-border=sharp
  --bind 'ctrl-j:ignore,ctrl-k:ignore,ctrl-n:down,ctrl-p:up'
  --bind 'alt-j:preview-down,alt-k:preview-up'
  --bind 'alt-d:preview-half-page-down,alt-u:preview-half-page-up'
  --bind 'alt-z:change-preview-window(85%|)+refresh-preview'
  --bind 'alt-/:toggle-preview,alt-w:toggle-preview-wrap'
  --bind 'ctrl-/:toggle-wrap-word'
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git --exclude node_modules --exclude .cache'
export FZF_ALT_C_OPTS="--preview 'eza -lahG --color=always --icons=never {}'"

eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# ----------------------------------------------------------------------
# Zsh Functions
# ----------------------------------------------------------------------
mancp() {
    man "$@" | col -bx | wl-copy
}

copy() {
    cat -- "$@" | wl-copy

}

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

fznvim() {
  if [[ -n "$1" ]]; then
    nvim "$@"
  else
    local file
    file=$(fzf --border=top --preview='bat --color=always --style=numbers --line-range=:500 {}')
    [[ -n "$file" ]] && nvim "$file"
  fi
}

x() {
  if [ -f "$1" ]; then
    local file="$(realpath "$1")"
    local fname="$(basename "$file")"
    local dname="${fname%%.*}"

    case "$fname" in
      *.tar.*) dname="${fname%%.tar.*}" ;;
      *.tbz2)  dname="${fname%%.tbz2}" ;;
      *.tgz)   dname="${fname%%.tgz}" ;;
      *.tar)   dname="${fname%%.tar}" ;;
      *.zip)   dname="${fname%%.zip}" ;;
      *.rar)   dname="${fname%%.rar}" ;;
      *.7z)    dname="${fname%%.7z}" ;;
      *.bz2)   dname="${fname%%.bz2}" ;;
      *.gz)    dname="${fname%%.gz}" ;;
      *.Z)     dname="${fname%%.Z}" ;;
    esac

    mkdir -p "$dname" && cd "$dname"

    case "$file" in
      *.tar.bz2)   tar xvjf "$file"    ;;
      *.tar.gz)    tar xvzf "$file"    ;;
      *.tar.xz)    tar xvJf "$file"    ;;
      *.tar.lzma)  tar --lzma -xvf "$file" ;;
      *.bz2)       bunzip2 "$file"     ;;
      *.rar)       unrar x "$file"     ;;
      *.gz)        gunzip -k "$file"   ;;
      *.tar)       tar xvf "$file"     ;;
      *.tbz2)      tar xvjf "$file"    ;;
      *.tgz)       tar xvzf "$file"    ;;
      *.zip)       unzip "$file"       ;;
      *.Z)         uncompress "$file"  ;;
      *.7z)        7z x "$file"        ;;
      *)           echo "'$file' cannot be extracted via x()" ; cd .. ; rmdir "$dname" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ----------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias r='exec zsh'
alias cl='clear'

alias ls='eza --color=auto --icons=never --group-directories-first'
alias ll='eza -lh --git --smart-group --time-style=relative --color=auto --icons=never --group-directories-first'
alias la='eza -lah --git --smart-group --time-style=relative --color=auto --icons=never --group-directories-first'

alias rm='rm -vI'
alias cp='cp -iv'
alias mv='mv -iv'
alias wlcp='wl-copy'
alias wlpa='wl-paste'

alias fetch='fastfetch'
alias error='journalctl -b -p err'
alias cc='clang -fsanitize=integer -fsanitize=undefined -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -lcs50 -lm'

alias rr='nvim ~/.zshrc'
alias swayconf='nvim ~/.config/sway/config'

alias appid='swaymsg -t get_tree | rg app_id'
alias img='swayimg'
alias zura='zathura'
alias btctl='bluetoothctl'

# ----------------------------------------------------------------------
# FZF-Tab Completion Configuration
# ----------------------------------------------------------------------
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' group-format ''
zstyle ':completion:*:descriptions' format ''

zstyle ':fzf-tab:*' fzf-flags \
  '--preview-border=sharp' \
  '--preview-window=right:50%,nowrap'

zstyle ':fzf-tab:*' fzf-bindings \
  'ctrl-j:ignore' 'ctrl-k:ignore' 'ctrl-n:down' 'ctrl-p:up' \
  'alt-d:preview-half-page-down' 'alt-u:preview-half-page-up' \
  'alt-z:change-preview-window(85%|)+refresh-preview' \
  'alt-j:preview-down' 'alt-k:preview-up' \
  'alt-/:toggle-preview' 'alt-w:toggle-preview-wrap-word'

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1a --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1a --color=always $realpath'

# ----------------------------------------------------------------------
# ZLE Custom Widgets & UI Enhancements
# ----------------------------------------------------------------------
zle_highlight=(
    region:'bg=#3a3a3a,bold'
    paste:'fg=green,bold'
    special:standout
    suffix:bold
)

sudo-command-line() {
    if [[ $BUFFER == sudo\ * ]]; then
        BUFFER="${BUFFER#sudo }"
        (( CURSOR -= 5 ))
    else
        BUFFER="sudo $BUFFER"
        (( CURSOR += 5 ))
    fi
}
zle -N sudo-command-line
bindkey '\es' sudo-command-line

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# ----------------------------------------------------------------------
# Powerlevel10k Prompt Setup
# ----------------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
