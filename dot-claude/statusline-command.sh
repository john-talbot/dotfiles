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

five_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

now=$(date +%s)

# ---------------------------------------------------------------------------
# Helper: derive a compact label from a resets_at epoch
#   $1 = resets_at epoch (integer, may be empty)
#   $2 = fallback label (e.g. "5h" or "7d")
#   $3 = window type: "hours" (5-hour window) or "days" (7-day window)
#        "hours" format: Nm | XhYm | Xh
#        "days"  format: Nd | <1d
#   Sets $rate_label
# ---------------------------------------------------------------------------
make_rate_label() {
  local resets_at="$1"
  local fallback="$2"
  local window_type="${3:-hours}"
  if [ -z "$resets_at" ]; then
    rate_label="$fallback"
    return
  fi
  local delta=$(( resets_at - now ))
  if [ "$delta" -le 0 ]; then
    rate_label="$fallback"
  elif [ "$window_type" = "days" ]; then
    # 7-day window: display in whole days only
    if [ "$delta" -lt 86400 ]; then
      rate_label="<1d"
    else
      local d=$(( delta / 86400 ))
      rate_label="${d}d"
    fi
  elif [ "$delta" -lt 3600 ]; then
    local m=$(( delta / 60 ))
    rate_label="${m}m"
  elif [ "$delta" -lt 86400 ]; then
    local h=$(( delta / 3600 ))
    local m=$(( (delta % 3600) / 60 ))
    if [ "$m" -eq 0 ]; then
      rate_label="${h}h"
    else
      rate_label="${h}h${m}m"
    fi
  else
    local h=$(( delta / 3600 ))
    rate_label="${h}h"
  fi
}

# ---------------------------------------------------------------------------
# Separator
# ---------------------------------------------------------------------------
SEP="  \033[38;5;240m│\033[0m  "

# ---------------------------------------------------------------------------
# 1. Model  🤖
# ---------------------------------------------------------------------------
printf '\033[38;5;81m🤖 %s\033[0m' "$model"

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
# 3. Rate-limit bars  ⚡  (filled = used; green=low, yellow=moderate, red=high)
# ---------------------------------------------------------------------------
rate_printed=0

if [ -n "$five_used" ]; then
  make_bar "$five_used"
  five_bar="$bar_out"
  five_used_int="$bar_pct_out"

  make_rate_label "$five_resets_at" "5h" "hours"
  five_label="$rate_label"

  # Color: green < 60%, yellow 60-80%, red >= 80%
  if   [ "$five_used_int" -lt 60 ]; then five_color='\033[38;5;214m'
  elif [ "$five_used_int" -lt 80 ]; then five_color='\033[38;5;221m'
  else                                    five_color='\033[38;5;203m'
  fi

  printf "$SEP"
  printf "${five_color}⚡ %s %s %d%%\033[0m" "$five_label" "$five_bar" "$five_used_int"
  rate_printed=1
fi

if [ -n "$week_used" ]; then
  make_bar "$week_used"
  week_bar="$bar_out"
  week_used_int="$bar_pct_out"

  make_rate_label "$week_resets_at" "7d" "days"
  week_label="$rate_label"

  # Color: green < 60%, yellow 60-80%, red >= 80%
  if   [ "$week_used_int" -lt 60 ]; then week_color='\033[38;5;214m'
  elif [ "$week_used_int" -lt 80 ]; then week_color='\033[38;5;221m'
  else                                    week_color='\033[38;5;203m'
  fi

  if [ "$rate_printed" -eq 0 ]; then
    printf "$SEP"
  else
    printf "  "
  fi
  printf "${week_color}%s %s %d%%\033[0m" "$week_label" "$week_bar" "$week_used_int"
fi

# ---------------------------------------------------------------------------
# 4. CWD  📁
# ---------------------------------------------------------------------------
printf "$SEP"
printf '\033[38;5;179m📁 %s\033[0m' "$cwd"

# ---------------------------------------------------------------------------
# 5. Git branch  🌿  (only when in a git repo)
# ---------------------------------------------------------------------------
if [ -n "$branch" ]; then
  printf "$SEP"
  printf '\033[38;5;114m🌿 %s\033[0m' "$branch"
fi

# ---------------------------------------------------------------------------
# 6. Caveman badge  🪨  (only when flag file exists)
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
