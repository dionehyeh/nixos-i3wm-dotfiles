#!/usr/bin/env bash

SSID=$(iwgetid -r 2>/dev/null)

if [ -n "$SSID" ]; then
  echo "%{F#7fbbb3}󰤨%{F-} ${SSID}"
else
  echo "%{F#859289}󰤭%{F-} offline"
fi
