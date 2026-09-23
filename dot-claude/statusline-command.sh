#!/bin/bash
# Claude Code statusline: model | context bar | rate limit bars (countdown label) | cwd | git branch | caveman badge

input=$(cat)

# ---------------------------------------------------------------------------
# Helper: build an 8-cell progress bar where filled cells = used
#   $1 = used_percentage (0-100, float ok)
#   returns bar string in $bar_out and integer used in $bar_pct_out
# ---------------------------------------------------------------------------
make_bar() {
  local used_pct="$1"
  local used_int
  used_int=$(printf '%.0f' "$used_pct")
  local filled=$(( used_int * 8 / 100 ))
  local empty=$(( 8 - filled ))
  bar_out=""
  local i
  for i in $(seq 1 $filled); do bar_out="${bar_out}█"; done
  for i in $(seq 1 $empty);  do bar_out="${bar_out}░"; done
  bar_pct_out="$used_int"
}

# ---------------------------------------------------------------------------
# Parse JSON fields
# ---------------------------------------------------------------------------
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')

cwd=$(echo "$input" | jq -r '.workspace.current_dir // ""')
cwd="${cwd/#$HOME/\~}"

branch=$(git --no-optional-locks -C "${cwd/#\~/$HOME}" rev-parse --abbrev-ref HEAD 2>/dev/null)

ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
session_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

# ---------------------------------------------------------------------------
# Separator
# ---------------------------------------------------------------------------
SEP="  \033[38;5;240m│\033[0m  "

# ---------------------------------------------------------------------------
# 1. Model  🤖
# ---------------------------------------------------------------------------
printf '\033[38;5;81m🤖 %s\033[0m' "$model"

# ---------------------------------------------------------------------------
# 1b. Enterprise badge + session cost  🏢 💵
# ---------------------------------------------------------------------------
printf "$SEP"
printf '\033[38;5;141m🏢 ENTERPRISE\033[0m'

if [ -n "$session_cost" ]; then
  cost_label=$(printf '%.2f' "$session_cost")
  if [ -n "$session_duration_ms" ] && [ "$session_duration_ms" -gt 0 ]; then
    dur_s=$(( session_duration_ms / 1000 ))
    if   [ "$dur_s" -lt 60 ];    then dur_label="${dur_s}s"
    elif [ "$dur_s" -lt 3600 ];  then dur_label="$(( dur_s / 60 ))m"
    else                              dur_label="$(( dur_s / 3600 ))h$(( (dur_s % 3600) / 60 ))m"
    fi
    printf '  \033[38;5;108m💵 $%s · %s\033[0m' "$cost_label" "$dur_label"
  else
    printf '  \033[38;5;108m💵 $%s\033[0m' "$cost_label"
  fi
fi

# ---------------------------------------------------------------------------
# 2. Context bar  📖  (filled = used; green=low, yellow=moderate, red=high)
# ---------------------------------------------------------------------------
if [ -n "$ctx_used" ]; then
  make_bar "$ctx_used"
  ctx_used_int="$bar_pct_out"
  ctx_bar="$bar_out"

  # Color: green < 60%, yellow 60-80%, red > 80%
  if   [ "$ctx_used_int" -lt 60 ]; then ctx_color='\033[38;5;78m'
  elif [ "$ctx_used_int" -lt 80 ]; then ctx_color='\033[38;5;221m'
  else                                   ctx_color='\033[38;5;203m'
  fi

  printf "$SEP"
  printf "${ctx_color}📖 %s %d%%\033[0m" "$ctx_bar" "$ctx_used_int"
fi

# ---------------------------------------------------------------------------
# 3. CWD  📁
# ---------------------------------------------------------------------------
printf "$SEP"
printf '\033[38;5;179m📁 %s\033[0m' "$cwd"

# ---------------------------------------------------------------------------
# 4. Git branch  🌿  (only when in a git repo)
# ---------------------------------------------------------------------------
if [ -n "$branch" ]; then
  printf "$SEP"
  printf '\033[38;5;114m🌿 %s\033[0m' "$branch"
fi

# ---------------------------------------------------------------------------
# 5. Caveman badge  🪨  (only when flag file exists)
# ---------------------------------------------------------------------------
CAVEMAN_FLAG="$HOME/.claude/.caveman-active"
if [ -f "$CAVEMAN_FLAG" ]; then
  MODE=$(cat "$CAVEMAN_FLAG" 2>/dev/null)
  printf "$SEP"
  if [ "$MODE" = "full" ] || [ -z "$MODE" ]; then
    printf '\033[38;5;172m🪨 CAVEMAN\033[0m'
  else
    SUFFIX=$(echo "$MODE" | tr '[:lower:]' '[:upper:]')
    printf '\033[38;5;172m🪨 CAVEMAN:%s\033[0m' "$SUFFIX"
  fi
fi

printf '\n'
