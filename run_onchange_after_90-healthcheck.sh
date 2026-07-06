#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[healthcheck] %s\n' "$*"
}

check_cmd() {
  local cmd="$1"
  local required="${2:-required}"

  if command -v "$cmd" >/dev/null 2>&1; then
    log "OK: $cmd"
    return 0
  fi

  if [ "$required" = "optional" ]; then
    log "WARN: $cmd not found (optional)"
    return 0
  fi

  log "ERROR: $cmd not found"
  return 1
}

main() {
  local failed=0

  check_cmd curl || failed=1
  check_cmd git || failed=1
  check_cmd zsh || failed=1
  check_cmd python3 || failed=1
  check_cmd pip3 optional || true
  check_cmd docker optional || true
  check_cmd node optional || true
  check_cmd pnpm optional || true
  check_cmd rustc optional || true
  check_cmd cargo optional || true
  check_cmd direnv optional || true

  if [ "$failed" -ne 0 ]; then
    log "One or more required checks failed"
    exit 1
  fi

  log "All required checks passed"
}

main "$@"
