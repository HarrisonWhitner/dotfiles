# dotfiles

My shell, prompt & tool configs, kept in one repo so every host I work on can be in sync.

## Tools I use

| Tool | Why I use it |
|---|---|
| `zsh` | `bash`, but with better tab completion, shared history and plugins |
| `tmux` | Terminal splitting and session resumption, general hackerman stuff |
| `brew` | A lovely, lovely package manager |
| `vim` | Best terminal text editor |
| `starship` | Rich terminal prompt features with good performance |
| `claude` | Needs no introduction |

## Configuration files

Each file is linked from where its program expects it to this repo, so editing `~/.zshrc` edits `~/dotfiles/zsh/.zshrc`.

| File | Linked from | What it does |
|---|---|---|
| `zsh/.zprofile` | `~/.zprofile` | Login settings: Homebrew and PATH (`~/scripts`, `~/.local/bin`) |
| `zsh/.zshrc` | `~/.zshrc` | History, completion, keys, aliases, tmux helpers, plugins and the prompt |
| `starship/starship.toml` | `~/.config/starship.toml` | Two-line prompt: host, directory, git branch/status, worktree, venv, AWS, exit code, duration, time |
| `tmux/.tmux.conf` | `~/.tmux.conf` | Mouse support, colors, scrollback, clipboard, `C-a` prefix |
| `vim/.vimrc` | `~/.vimrc` | Editing preferences |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` | Claude Code status line: cwd, branch, model, effort, context, 5h usage |
| `claude/settings.json` | `~/.claude/settings.json` | Claude Code settings: model, theme, status line, and which plugins (and their marketplaces) to install || `setup.sh` | | Sets all of this up on a new machine |

## Setting up a new machine

```sh
git clone https://github.com/HarrisonWhitner/dotfiles.git ~/dotfiles
~/dotfiles/setup.sh
```

`setup.sh` works on Ubuntu/WSL (apt), Amazon Linux (dnf) and macOS (Homebrew), and is safe to run again. It links every file in the table above into place (moving any existing file to `<name>.bak-<date>` first), installs the tools they need, and makes zsh the default shell. The comments in `setup.sh` describe each step.

Then open a new terminal, and run `tmux kill-server` if tmux was already running so it starts zsh.

### Steps to do by hand

**Font** (only on machines you type at; ssh hosts don't need it, since icons are drawn by the local terminal). Without it, the prompt's 4 icons show as boxes.

- macOS: `brew install --cask font-jetbrains-mono-nerd-font`, then pick *JetBrainsMono Nerd Font* in the terminal's settings
- Windows: download `JetBrainsMono.zip` from the [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) and install the `JetBrainsMonoNerdFont-*.ttf` files (Homebrew inside WSL installs Linux fonts, which Windows Terminal can't see)

**Windows Terminal** (`settings.json`, under Settings > Open JSON file): copy selected text automatically, and use the font in the Ubuntu profile.

```json
"copyOnSelect": true,
```

```json
{
    "name": "Ubuntu",
    "font": { "face": "JetBrainsMono Nerd Font" }
}
```

## Claude Code settings

Claude Code writes to `settings.json` itself, e.g. when changing `/config` or turning a plugin on with `/plugin`, and those changes land in this repo. It also rewrites the file on its own, reordering keys and sometimes changing values (like `"model": "opus"` to `"opus[1m]"`), so check `git diff` before committing rather than committing everything it changed.

A plugin turned on with `/plugin` on one host is added to `enabledPlugins`, so after pushing, running `setup.sh` on another host installs it there.

## Making changes

1. Edit the file where it normally lives (e.g. `vim ~/.zshrc`), which edits the repo copy
2. Add a dated comment above the change saying what it does and why, like the rest of the file
3. Commit with the reason, then push

```sh
cd ~/dotfiles && git diff
git commit -am "zsh: add tcolor to color a tmux session's status bar"
git push
```

## Settings for one host only

Anything that should only apply on one machine, like an alias for a single EC2 box, a work AWS profile or a secret, goes in `~/.zshrc.local` on that machine. `.zshrc` loads it if it exists, and it is not part of this repo, so it is never pushed.

## Updating another host

```sh
cd ~/dotfiles && git pull
exec zsh                       # reload zsh in this terminal
tmux source-file ~/.tmux.conf  # reload tmux, if running
```

If the pull added a new file, run `~/dotfiles/setup.sh` again to link it.
