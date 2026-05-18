# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------------------------------------------------
# Zsh Configuration: History & Input
# ----------------------------------------------------------------------

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_find_no_dups
typeset -U PATH

# Input/output
bindkey -e
setopt CORRECT
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
WORDCHARS=${WORDCHARS//[\/]}

# ----------------------------------------------------------------------
# Zim Module Configuration
# ----------------------------------------------------------------------

# Start configuration added by Zim install {{{

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

# git
#zstyle ':zim:git' aliases-prefix 'g'

# input
zstyle ':zim:input' double-dot-expand yes

# termtitle
zstyle ':zim:termtitle' format '%1~'

# zsh-autosuggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=242'

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
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
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

# ----------------------------------------------------------------------
# Exports
# ----------------------------------------------------------------------

# FZF Configuration (Maximized for fd)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git --exclude node_modules --exclude .cache --exclude venv --exclude dist'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:50% --bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'"
export FZF_ALT_C_OPTS="--preview 'eza -lahG --color=always --icons=never {}' --preview-window=down:50% --bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'"

# Tool Initializations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# ----------------------------------------------------------------------
# Zsh Functions
# ----------------------------------------------------------------------

# Mancp
mancp() {
    man "$@" | col -bx | wl-copy && notify-send -t 2000 "Man page copied to clipboard"
}

# yazi Function
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# Open file with nvim using fzf preview (Maximized with Bottom Layout)
fznvim() {
  if [[ -n "$1" ]]; then
    nvim "$@"
  else
    local file
    file=$(fzf --preview='bat --color=always --style=numbers --line-range=:500 {}' \
               --preview-window=down:50% \
               --bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down')
    [[ -n "$file" ]] && nvim "$file"
  fi
}

# Extraction function (x)
x() {
  if [ -f "$1" ]; then
    # Get the base name without extension(s)
    fname="$(basename "$1")"
    dname="${fname%%.*}"

    # Handle double extensions (e.g., .tar.gz, .tar.bz2, .tar.xz, etc.)
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

    case "$1" in
      *.tar.bz2)     tar xvjf "../$1"   ;;
      *.tar.gz)      tar xvzf "../$1"   ;;
      *.tar.xz)      tar xvJf "../$1"   ;;
      *.tar.lzma)    tar --lzma -xvf "../$1" ;;
      *.bz2)         bunzip2 "../$1"    ;;
      *.rar)         unrar x "../$1"    ;;
      *.gz)          gunzip -k "../$1"   ;; # -k to keep original
      *.tar)         tar xvf "../$1"    ;;
      *.tbz2)        tar xvjf "../$1"   ;;
      *.tgz)         tar xvzf "../$1"   ;;
      *.zip)         unzip "../$1"      ;;
      *.Z)           uncompress "../$1" ;;
      *.7z)          7z x "../$1"       ;;
      *)             echo "'$1' cannot be extracted via x()" ; cd .. ; rmdir "$dname" ;;
    esac
    cd ..
  else
    echo "'$1' is not a valid file"
  fi
}

# ----------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------

### Navigation Shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

### Core Tools
alias r='exec zsh'
alias cl='clear'

alias ls='eza --color=auto --icons=never --group-directories-first'
alias ll='eza -lbGhF --git --color=auto --icons=never --group-directories-first'
alias la='eza -lahF --git --color=auto --icons=never --group-directories-first'

alias rm='rm -v'
alias cp='cpg -g'
alias mv='mvg -g'
alias wlcp='wl-copy'
alias wlpa='wl-paste'

### System & Maintenance
alias fetch='fastfetch'
alias error='journalctl -b -p err'
export CC=clang
export CFLAGS="-fsanitize=integer -fsanitize=undefined -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra"
export LDLIBS="-lcrypt -lcs50 -lm"

### Configuration Editing
alias rr='nvim ~/.zshrc'
alias swayconf='nvim ~/.config/sway/config'
# alias nvim='nvim -u ~/.vimrc'

### Other
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

# Pass custom layout and scrolling bindings to fzf-tab
zstyle ':fzf-tab:*' fzf-flags '--preview-window=right:50%'
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-u:preview-half-page-up' 'ctrl-d:preview-half-page-down'

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1a --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1a --color=always $realpath'

# ----------------------------------------------------------------------
# Powerlevel10k Prompt Setup
# ----------------------------------------------------------------------
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
