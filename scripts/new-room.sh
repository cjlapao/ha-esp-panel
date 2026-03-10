#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <room-slug>"
  exit 1
fi

room_slug="$1"
room_title="$(echo "$room_slug" | tr '-' ' ' | awk '{ for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) substr($i,2); print }')"
room_file="esphome/rooms/${room_slug}.yaml"
dashboard_file="esphome/dashboard_${room_slug}.yaml"

if [ -f "$room_file" ] || [ -f "$dashboard_file" ]; then
  echo "Room already exists: $room_slug"
  exit 1
fi

cp esphome/rooms/_template.yaml "$room_file"

# Use POSIX-safe in-place edit via temp file.
sed "s/\"Room\"/\"${room_title}\"/g; s/ha_area_id: room/ha_area_id: ${room_slug}/g; s/room_/$(echo "${room_slug}_" | sed 's/\//\\\//g')/g" "$room_file" > "${room_file}.tmp"
mv "${room_file}.tmp" "$room_file"

cat > "$dashboard_file" <<EOF2
packages:
  base: !include packages/base.yaml
  room: !include rooms/${room_slug}.yaml
  ui_common: !include packages/ui_common.yaml
EOF2

echo "Created $room_file"
echo "Created $dashboard_file"
