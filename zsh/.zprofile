# Harrison Whitner

# 10/28/2026 - migrate from bash to zsh, homebrew and PATH settings

# zsh reads this once for each login shell (a new terminal tab, tmux pane or ssh session),
# before ~/.zshrc, so it is the place for settings that only need to happen once like PATH

# set up homebrew (adds it to PATH, MANPATH, etc), checking the linux, apple silicon and intel mac locations
for brew in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x $brew ]] && eval "$($brew shellenv)" && break
done
unset brew

# remove duplicate PATH entries, which tmux panes would otherwise pile up by re-running this file
typeset -U path

# add personal scripts and user installed tools (claude, uv, pip --user) to the top of PATH
# zsh keeps PATH in sync with the $path array, so entries can be listed one per word
path=(~/scripts ~/.local/bin $path)
