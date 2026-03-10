#!/usr/bin/env bash
set -euo pipefail

if ! command -v yamllint >/dev/null 2>&1; then
  echo "yamllint not found. Run: make bootstrap"
  exit 1
fi

yamllint .
