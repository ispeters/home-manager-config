#!/usr/bin/env bash
set -euo pipefail

DEVSHELLS_FLAKE="${DEVSHELLS_FLAKE:-$HOME/.config/devshells}"

devshell_usage() {
  cat <<'USAGE'
Usage: devshell <name> [-- <command>...]
       devshell -h | --help
       devshell --list

Runs `nix develop <flake>#<name>`, where <flake> defaults to
~/.config/devshells (override with $DEVSHELLS_FLAKE).

Options:
  -h, --help   Show this help message
  --list       List devshells available in the flake
USAGE
}

devshell_list() {
  local system
  system="$(nix eval --impure --raw --expr 'builtins.currentSystem')"
  nix flake show --json "$DEVSHELLS_FLAKE" 2>/dev/null \
    | jq -r --arg system "$system" '.devShells[$system] // {} | keys[]'
}

main() {
  if [[ $# -eq 0 ]]; then
    devshell_usage >&2
    exit 1
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
    --*)
      echo "devshell: unknown option: $1" >&2
      devshell_usage >&2
      exit 1
      ;;
    *)
      local name="$1"
      shift
      exec nix develop "${DEVSHELLS_FLAKE}#${name}" "$@"
      ;;
  esac
}

main "$@"
