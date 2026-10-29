#!/bin/bash

# Harrison Whitner

# 10/4/2026 - two line status line for Claude Code

# preview of the status line (cwd in blue, branch in green, unpushed commits in yellow)
#
#   /home/user/projects/my-project main ↑2
#   Opus 5.5 | effort: high | ctx: 84k/200k | 5h: 37% (resets in 2h14m)

# read the session info that Claude Code passes in as JSON on stdin
input=$(cat)

# pull out the needed fields, one per line, using python3 so jq is not required
# (read loop instead of mapfile so this works on the bash 3.2 that ships with macOS)
f=(); while IFS= read -r l; do f+=("$l"); done < <(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
def g(*path):
    v = d
    for k in path:
        v = v.get(k) if isinstance(v, dict) else None
    return v
def out(v, default=""):
    print(default if v is None else v)
out(g("workspace", "current_dir") or g("cwd"))
out(g("model", "display_name"), "?")
out(g("effort", "level"), "n/a")
out(g("context_window", "total_input_tokens"), 0)
out(g("context_window", "context_window_size"), 0)
out(g("rate_limits", "five_hour", "used_percentage"))
out(g("rate_limits", "five_hour", "resets_at"))
')

# name each field, falling back to a default if it is missing
cwd=${f[0]:-$PWD}
model=${f[1]:-?}
effort=${f[2]:-n/a}
used=${f[3]:-0}
size=${f[4]:-0}
pct=${f[5]}
reset=${f[6]}

# shorten token counts, e.g. 84000 -> 84k and 1200000 -> 1.2M
fmt() { awk -v n="$1" 'BEGIN{ if (n>=1000000) printf "%.1fM", n/1000000; else if (n>=1000) printf "%.0fk", n/1000; else printf "%d", n }'; }

# line 1 - current directory
line1=$(printf '\033[34m%s\033[0m' "$cwd")

# add the git branch, or the short commit hash if HEAD is detached
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  line1="$line1 $(printf '\033[32m%s\033[0m' "$branch")"

  # add the number of unpushed commits, skipped if the branch has no upstream
  ahead=$(git -C "$cwd" --no-optional-locks rev-list --count '@{u}..HEAD' 2>/dev/null)
  [ -n "$ahead" ] && line1="$line1 $(printf '\033[33m↑%s\033[0m' "$ahead")"
fi

# line 2 - model, effort level and context window usage
line2="$model | effort: $effort | ctx: $(fmt "$used")/$(fmt "$size")"

# add the 5 hour usage limit and time until it resets, only present on subscription plans
if [ -n "$pct" ]; then
  line2="$line2 | 5h: $(printf '%.0f' "$pct")%"
  if [ -n "$reset" ]; then
    left=$(( reset - $(date +%s) ))
    [ "$left" -lt 0 ] && left=0
    line2="$line2 (resets in $((left/3600))h$(( (left%3600)/60 ))m)"
  fi
fi

printf '%s\n%s\n' "$line1" "$line2"
