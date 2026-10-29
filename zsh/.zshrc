# Harrison Whitner

# 10/28/2026 - migrate from bash to zsh, starship prompt, history, completion, aliases and tmux helpers

# preview of the prompt (drawn by starship, see ~/.config/starship.toml)
#
#   windows-pc ~/dev-projects/hello-world  mainline ↑2 !?  hello-world
#   ❯ git status                                      took 4s 14:12:07

# --- history ---

# keep 5k commands in memory and in the history file (zsh only keeps 1k by default)
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

# save when each command started and how long it ran, shown with history -i
setopt extended_history

# write each command to the history file as soon as it runs and pick up commands from other shells (tmux panes)
setopt share_history

# skip saving a command if it is the same as the one just before it
setopt hist_ignore_dups

# skip saving commands that start with a space, useful for one-offs or commands with secrets in them
setopt hist_ignore_space

# show what !! and !123 expand to before running them, instead of running right away
setopt hist_verify

# --- keys ---

# use the standard command line keys that bash also uses (ctrl+a / ctrl+e start / end, ctrl+r search, ctrl+w delete word)
# zsh calls these "emacs" keys, but they have nothing to do with the emacs editor; set explicitly because
# zsh otherwise switches to vi mode on its own when EDITOR contains "vi"
bindkey -e

# up and down arrow search history for commands starting with what is already typed
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search '^[OB' down-line-or-beginning-search

# home, end, delete and ctrl+left/right to jump words, which zsh does not bind on its own on macos
bindkey '^[[H' beginning-of-line '^[[F' end-of-line '^[[3~' delete-char
bindkey '^[[1;5D' backward-word '^[[1;5C' forward-word

# --- completion ---

# turn on tab completion (ubuntu's /etc/zsh/zshrc does this too, macos does not)
autoload -Uz compinit && compinit

# press tab a second time to pick from a menu with the arrow keys
zstyle ':completion:*' menu select

# let lowercase match uppercase, so cd desk<tab> finds Desktop
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# --- colors ---

# color ls output, using GNU dircolors on linux or the BSD ls setting on macos
if (( $+commands[dircolors] )); then
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
else
  export CLICOLOR=1
fi

# color files in the completion menu the same way ls does
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# highlight matches in grep output
alias grep='grep --color=auto'

# --- navigation and misc ---

# type a directory name without cd to go into it
setopt auto_cd

# remember visited directories, so cd -<tab> lists recent ones to jump back to
setopt auto_pushd pushd_ignore_dups pushd_silent

# allow # comments in typed or pasted commands (bash allows these, zsh does not by default)
setopt interactive_comments

# --- prompt ---

# hide the (venv) prefix that python's activate script adds, starship shows the venv instead
export VIRTUAL_ENV_DISABLE_PROMPT=1

# draw the prompt with starship if installed, otherwise fall back to a plain host, directory and ❯
# (the fallback ❯ turns red when the last command failed)
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
else
  PROMPT=$'\n%m %F{blue}%~%f\n%(?.%F{green}.%F{red})❯%f '
fi

# --- aliases ---

# list all files except . and .. in long format with readable sizes
# (-l long format, -A almost all, -h human-readable sizes, short flags work on both linux and macos)
alias ll='ls -lAh'

# ask before overwriting or deleting files (-i interactive)
alias cp='cp -i'
alias rm='rm -i'

# search every past command along with when it ran, e.g. hg ssh (-i shows timestamps, 1 starts from the first entry)
alias hg='history -i 1 | grep'

# git shortcuts for the commands used most
alias gs='git status'
alias gl='git log --oneline --graph --decorate --max-count=20'

# --- tmux ---

# color this tmux session's status bar, e.g. tcolor red, tcolor lightblue, tcolor '#ff8800'
# dark colors get white text, and tcolor with no color goes back to the default white bar from ~/.tmux.conf
tcolor() {
  [[ -z $1 ]] && { tmux set-option -u status-style; return; }
  local text=black
  [[ $1 == (dark*|red|blue|magenta|purple|black|navy*) ]] && text=white
  tmux set-option status-style "bg=$1,fg=$text"
}

# rename this tmux session, e.g. tname wedding-website (same as prefix + $)
alias tname='tmux rename-session'

# --- this host only ---

# 10/29/2026 - load settings for this host only (aliases, AWS profiles, secrets), kept out of the dotfiles repo
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# --- plugins ---

# zsh-autosuggestions shows the rest of a matching past command in grey as you type, press → to accept it
# zsh-syntax-highlighting colors commands as you type, red when the command does not exist (must load last)
# checks the apt location on linux, the homebrew location on macos, and ~/.local/share where
# setup.sh clones them on hosts with no plugin packages (amazon linux)
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  for dir in /usr/share/$plugin $HOMEBREW_PREFIX/share/$plugin ~/.local/share/$plugin; do
    [[ -r $dir/$plugin.zsh ]] && source $dir/$plugin.zsh && break
  done
done
unset plugin dir
