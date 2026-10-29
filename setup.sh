#!/usr/bin/env bash

# Harrison Whitner

# 10/29/2026 - set up shell and tools on a new machine

# links each config file in this repo to where its program looks for it (backing up any file
# already there), installs the tools they need, then makes zsh the default shell
#
# safe to run again, anything already linked or installed is skipped
#
# to use, clone this repo to ~/dotfiles and run
#
#   ~/dotfiles/setup.sh

# stop on the first error, on unset variables, and on failures inside pipes
set -euo pipefail

# folder this script is in, so the links point at the repo wherever it was cloned
repo=$(cd "$(dirname "$0")" && pwd)

# each file in the repo and where its program looks for it
links=(
  "zsh/.zshrc:$HOME/.zshrc"
  "zsh/.zprofile:$HOME/.zprofile"
  "starship/starship.toml:$HOME/.config/starship.toml"
  "tmux/.tmux.conf:$HOME/.tmux.conf"
  "vim/.vimrc:$HOME/.vimrc"
)

# commands the configs and this script use, installed when missing
tools="zsh tmux vim git python3 curl tree"

plugins="zsh-autosuggestions zsh-syntax-highlighting"

# --- link config files ---

stamp=$(date +%Y%m%d-%H%M%S)
for pair in "${links[@]}"; do
  src="$repo/${pair%%:*}"
  dst="${pair#*:}"

  # skip files that already link to this repo
  if [ "$(readlink "$dst" 2>/dev/null)" = "$src" ]; then
    echo "already linked  $dst"
    continue
  fi

  # keep whatever is already there as a dated backup instead of overwriting it
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak-$stamp"
    echo "backed up       $dst -> $dst.bak-$stamp"
  fi

  ln -s "$src" "$dst"
  echo "linked          $dst -> $src"
done

# folder for personal scripts, which .zprofile adds to PATH
mkdir -p "$HOME/scripts"

# --- install packages ---

# list only the tools that are missing, so a host that is already set up needs no sudo,
# and preinstalled ones are left alone (asking dnf for curl conflicts with amazon linux's curl-minimal)
missing=""
for t in $tools; do
  command -v "$t" >/dev/null || missing="$missing $t"
done

# the plugins count as missing unless found somewhere .zshrc looks
plugins_missing=no
for p in $plugins; do
  found=no
  for dir in /usr/share/$p "${HOMEBREW_PREFIX:-/nonexistent}/share/$p" "$HOME/.local/share/$p"; do
    [ -r "$dir/$p.zsh" ] && found=yes
  done
  [ $found = yes ] || plugins_missing=yes
done

if [ -z "$missing" ] && [ $plugins_missing = no ]; then
  echo "already installed $tools and zsh plugins"
elif [ "$(uname)" = Darwin ] && command -v brew >/dev/null; then
  brew install $missing $plugins
elif command -v apt-get >/dev/null; then
  # refresh the package lists first, which are empty on a brand new host
  sudo apt-get update
  sudo apt-get install -y $missing $plugins
elif command -v dnf >/dev/null; then
  # amazon linux's vim package is called vim-enhanced (the preinstalled vim-minimal only has vi)
  [ -n "$missing" ] && sudo dnf install -y ${missing/vim/vim-enhanced}
  # and there are no packages for the plugins, so clone them to where .zshrc looks
  for p in $plugins; do
    [ -d "$HOME/.local/share/$p" ] || git clone --depth 1 "https://github.com/zsh-users/$p" "$HOME/.local/share/$p"
  done
else
  echo "unknown package manager, install$missing and $plugins by hand"
fi

# --- install starship ---

if command -v starship >/dev/null; then
  echo "already installed starship"
elif command -v brew >/dev/null; then
  brew install starship
else
  # no homebrew (e.g. an ec2 host), use starship's official installer into ~/.local/bin, which needs no sudo
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "$HOME/.local/bin"
fi

# --- make zsh the default shell ---

# sudo so this also works for accounts with no password, like ec2-user
if [ "$(basename "${SHELL:-}")" = zsh ]; then
  echo "already using zsh as the default shell"
else
  sudo chsh -s "$(command -v zsh)" "$USER"
  echo "default shell set to zsh, open a new terminal (and run tmux kill-server) to start using it"
fi

# --- manual steps ---

cat <<'EOF'

done! step left to do by hand, see README.md for details
  - on machines you type at (not ssh hosts): install JetBrainsMono Nerd Font and pick it in the terminal
EOF
