#!/usr/bin/env bash
set -euo pipefail

if [ -x "./bin/esphome" ]; then
  ESPHOME="./bin/esphome"
elif command -v esphome >/dev/null 2>&1; then
  ESPHOME="$(command -v esphome)"
else
  echo "esphome not found. Run: make bootstrap"
  exit 1
fi

if [ ! -f esphome/secrets.yaml ]; then
  echo "esphome/secrets.yaml not found. Copy esphome/secrets.example.yaml first."
  exit 1
fi

status=0
for cfg in esphome/dashboard_*.yaml; do
  case "$cfg" in
    *_experimental.yaml)
      echo "Skipping experimental config $cfg"
      continue
      ;;
  esac
  echo "Validating $cfg"
  if ! "$ESPHOME" config "$cfg" >/dev/null; then
    status=1
  fi
done

exit $status
