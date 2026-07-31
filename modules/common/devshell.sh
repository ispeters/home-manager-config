#!/usr/bin/env bash
set -euo pipefail

DEVSHELLS_FLAKE="${DEVSHELLS_FLAKE:-$HOME/.config/devshells}"

devshell_usage() {
  cat <<'USAGE'
Usage: devshell [.[#<n>]] [-- <command>...]
       devshell <n> [-- <command>...]
       devshell -h | --help
       devshell --list

With no argument, or ".", or ".#<n>", runs `nix develop` (or
`nix develop .#<n>`) against the flake in or above the current directory,
using the same flake-resolution rules `nix develop` itself uses for ".".

With <n> not starting with ".", runs `nix develop <flake>#<n>`, where
<flake> defaults to ~/.config/devshells (override with $DEVSHELLS_FLAKE).

Options:
  -h, --help   Show this help message
  --list       List devshells in the catalog flake, and in the current
               directory's flake if one is found nearby
USAGE
}

# Cheap upward filesystem walk mirroring nix's own flake.nix resolution --
# lets us give a clean error, or skip the current-directory scan in
# --list, without paying for a flake eval just to learn there's nothing
# here.
devshell_find_flake_root() {
  local dir="$PWD"
  while true; do
    if [[ -e "$dir/flake.nix" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    [[ "$dir" == "/" ]] && return 1
    dir="$(dirname "$dir")"
  done
}

devshell_list() {
  local system
  system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"

  echo "catalog (${DEVSHELLS_FLAKE}):"
  nix flake show --json "$DEVSHELLS_FLAKE" 2>/dev/null \
    | jq -r --arg system "$system" '.devShells[$system] // {} | keys[] | "  " + .'

  local root
  if root="$(devshell_find_flake_root)"; then
    echo "current directory (${root}):"
    nix flake show --json . 2>/dev/null \
      | jq -r --arg system "$system" '.devShells[$system] // {} | keys[] | "  " + .'
  fi
}

# Sets the nesting-depth/name env vars the prompt indicator reads, then
# execs. Centralized here rather than duplicated in every flake's
# shellHook, on the assumption that `devshell` is now the only door in.
devshell_exec() {
  local name="$1"
  shift
  export DEVSHELL_DEPTH=$(( ${DEVSHELL_DEPTH:-0} + 1 ))
  export DEVSHELL_NAME="$name"
  exec "$@"
}

devshell_enter_here() {
  local target="$1"
  shift
  local root
  if ! root="$(devshell_find_flake_root)"; then
    echo "devshell: no flake.nix found in '$PWD' or any parent directory" >&2
    devshell_usage >&2
    exit 1
  fi
  local name
  if [[ "$target" == .#* ]]; then
    name="${target#.#}"
  else
    name="$(basename "$root")"
  fi
  devshell_exec "$name" nix develop "$target" "$@"
}

main() {
  if [[ $# -eq 0 ]]; then
    devshell_enter_here .
    return
  fi

  case "$1" in
    -h|--help)
      devshell_usage
      exit 0
      ;;
    --list)
      devshell_list
      exit 0
      ;;
    .|.#*)
      local target="$1"
      shift
      devshell_enter_here "$target" "$@"
      ;;
    --*)
      echo "devshell: unknown option: $1" >&2
      devshell_usage >&2
      exit 1
      ;;
    *)
      local name="$1"
      shift
      devshell_exec "$name" nix develop "${DEVSHELLS_FLAKE}#${name}" "$@"
      ;;
  esac
}

main "$@"
