#!/usr/bin/env bash
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required"
  exit 1
fi

# In an active virtualenv, --user installs are blocked.
if [ -n "${VIRTUAL_ENV:-}" ]; then
  python3 -m pip install --upgrade pip
  python3 -m pip install esphome yamllint pre-commit
  echo "Bootstrap complete in virtualenv: ${VIRTUAL_ENV}"
else
  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user esphome yamllint pre-commit
  echo "Bootstrap complete (user install). Ensure ~/.local/bin is on PATH."
fi
