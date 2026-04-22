# ----------------------------------------------------------------------
# ⚡️ Zsh Profiling (Optional)
# ----------------------------------------------------------------------
# zmodload zsh/zprof


# ----------------------------------------------------------------------
# 🚀 Powerlevel10k Instant Prompt
# ----------------------------------------------------------------------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# ----------------------------------------------------------------------
# ⚙️ Zsh Configuration: History & Input
# ----------------------------------------------------------------------
#
# History
#
HISTSIZE=5000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_find_no_dups

#
# Input/output
#
bindkey -e        # Set editor default keymap to emacs
setopt CORRECT    # Prompt for spelling correction of commands.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? ' # Customize spelling correction prompt.
WORDCHARS=${WORDCHARS//[\/]} # Remove path separator from WORDCHARS.


# ----------------------------------------------------------------------
# 📦 Zim Module Configuration
# ----------------------------------------------------------------------

# Start configuration added by Zim install {{{

# Use degit instead of git as the default tool to install and update modules.
#zstyle ':zim:zmodule' use 'degit'

#
# git
#
#zstyle ':zim:git' aliases-prefix 'g'

#
# input
#
zstyle ':zim:input' double-dot-expand yes

#
# termtitle
#
#zstyle ':zim:termtitle' format '%1~'


#
# zsh-autosuggestions
#
ZSH_AUTOSUGGEST_MANUAL_REBIND=1 # Disable automatic widget re-binding on each precmd.
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

#
# zsh-syntax-highlighting
#
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
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
# 📁 Path & Exports
# ----------------------------------------------------------------------

export EDITOR="nvim"
export VISUAL="nvim"

# Local binaries and FZF
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.fzf/bin:$PATH"

# FZF Configuration
export FZF_DEFAULT_COMMAND='fd --type f --exclude .git --exclude node_modules --exclude .cache --exclude venv --exclude dist'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

# XDG
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/r3d/.local/share/flatpak/exports/share

# Tool Initializations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Amdsmi
export PATH="${PATH}:/opt/rocm/bin"


# ----------------------------------------------------------------------
# ⌨️ Zsh Functions
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

# Open file with nvim using fzf preview
fznvim() {
  nvim "$(fzf --preview='bat --color=always {}')"
}

# Change directory using fzf for files (directory of the selected file)
cdf() {
  local file
  file=$(fzf) || return
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
  fi
}

# Change directory using fzf with bat preview (directory of the selected file)
cdfv() {
  local file
  file=$(fzf --preview='bat --color=always {}') || return
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
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

# Crun func
cc() {
    clang -Wall -Wextra -Werror -std=c11 "$1" -o "${1%.c}" -lcs50
}

# ----------------------------------------------------------------------
# 🚀 Aliases
# ----------------------------------------------------------------------

### Navigation Shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

### Core Tools
alias r="exec zsh"            # Reload shell
alias cl='clear'              # Clear
# alias ls='lsd --group-directories-first'      # list files (lsd)
# alias lsa='lsd -Ah --group-directories-first' # list all files (lsd)
# alias ls='ls --color=auto --group-directories-first'
# alias lsa='ls -Ah --group-directories-first --color=auto'
alias ls='eza --group-directories-first'
alias lse='eza --group-directories-first --oneline'
alias lsa='eza -Ah --group-directories-first'
alias bat='bat'               # Cat replacement
alias rm='rm -v'              # Remove with verbose
alias cp='cpg -g'             # Copy with progress
alias mv='mvg -g'             # Move with progress
alias wlcp='wl-copy'
alias wlpa='wl-paste'
# alias cp='cp -v'
# alias alias mv='mv -v'

### System & Maintenance
alias fetch='fastfetch'
alias py='python3'
alias c='clang'
alias update='sudo pacman -Syu && yay -Syua'
alias updates='(checkupdates 2>/dev/null; yay -Qua 2>/dev/null) | sort -u'
alias bye='sudo shutdown -r now'
alias hmmm='yay -Sy &> /dev/null && yay -Qu'
alias error='journalctl -b -p err'
alias rmor='
if [ -n "$(pacman -Qdtq)" ]; then sudo pacman -Rns $(pacman -Qdtq); fi
if [ -n "$(yay -Qtdq)" ]; then yay -Rns $(yay -Qtdq); fi
'
alias sshstart='sudo systemctl start sshd'
alias sshstop='sudo systemctl stop sshd'
alias make50='make CC=clang CFLAGS="-fsanitize=signed-integer-overflow -fsanitize=undefined -ggdb3 -O0 -std=c11 -Wall -Werror -Wextra -Wno-sign-compare -Wno-unused-parameter -Wno-unused-variable -Wshadow" LDLIBS="-lcrypt -lcs50 -lm"'

### Code Running
alias pyrun='python3 %'
alias jsrun='node %'
alias luarun='lua %'
alias cpprun='clang++ % -o %:r && ./%:r'
alias shellrun='bash %'

### Configuration Editing (nvim)
alias rr='nvim ~/.zshrc'
alias kittyconf='nvim ~/.config/kitty/kitty.conf'
alias tmuxconf='nvim ~/.config/tmux/tmux.conf'
alias swayconf='nvim ~/.config/sway/config'
alias wayconf='nvim ~/.config/waybar/config.jsonc'
alias waystyl='nvim ~/.config/waybar/style.css'
alias alacconf='nvim ~/.config/alacritty/alacritty.toml'
alias fuzzconf='nvim ~/.config/fuzzel/fuzzel.ini'
alias yconf='yazi ~/.config/yazi/'
alias nemo='nemo > /dev/null 2>&1 &'
alias footconf='nvim ~/.config/foot/foot.ini'
alias img='swayimg'
alias zura='zathura'
alias makoconf='nvim ~/.config/mako/config'

### Other
alias discordf='flatpak run com.discordapp.Discord'
alias bm='bashmount'
alias appid='swaymsg -t get_tree | rg app_id'

# ----------------------------------------------------------------------
# 🔍 FZF-Tab Completion Configuration
# ----------------------------------------------------------------------
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' group-format ''
# zstyle ':fzf-tab:complete:*' show-command-type false
zstyle ':completion:*:descriptions' format ''
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/r3d/.config/.dart-cli-completion/zsh-config.zsh ]] && . /home/r3d/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]


# ----------------------------------------------------------------------
# 🎨 Powerlevel10k Prompt Setup
# ----------------------------------------------------------------------
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/dots/zsh/.p10k.zsh.
[[ ! -f ~/dots/zsh/.p10k.zsh ]] || source ~/dots/zsh/.p10k.zsh
