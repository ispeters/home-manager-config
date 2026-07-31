# Subtle indicator for how many `nix develop` shells are nested, and which
# one is active. Recomputed every prompt (not baked in once) so it survives
# nix develop's own PS1 rewrite and self-heals on `exit` back to an outer
# shell -- iTerm2 badges are session-scoped and don't revert on their own.
__devshell_prompt_indicator() {
  local depth="${DEVSHELL_DEPTH:-0}"

  if [ "$depth" -gt 0 ]; then
    # muted blue -> teal -> purple -> tan; avoids red/yellow on purpose
    local palette=(33 37 96 137)
    local idx=$(( (depth - 1) % ${#palette[@]} ))
    local color="${palette[$idx]}"
    local dots="" i
    for (( i = 0; i < depth && i < 4; i++ )); do
      dots+="●"
    done
    PS1="\[\e[38;5;${color}m\]${dots}\[\e[0m\] \h:\W \u\$ "
  else
    PS1='\h:\W \u\$ '
  fi

  if [ "$LC_TERMINAL" = "iTerm2" ]; then
    local badge=""
    if [ "$depth" -gt 0 ]; then
      badge="${DEVSHELL_NAME:-devshell}"
      [ "$depth" -gt 1 ] && badge="${badge} ×${depth}"
    fi
    printf '\033]1337;SetBadgeFormat=%s\a' "$(printf '%s' "$badge" | base64 | tr -d '\n')"
  fi
}

PROMPT_COMMAND="__devshell_prompt_indicator${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
