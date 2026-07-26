#!/usr/bin/env bash

if bluetoothctl show | grep -q "Powered: yes"; then
  echo "%{F#7fbbb3}󰂯%{F-} on"
else
  echo "%{F#859289}󰂯%{F-} off"
fi
