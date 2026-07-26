#!/usr/bin/env bash

case "$1" in
--toggle)
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
  ;;
--up)
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
  ;;
--down)
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
  ;;
*)
  VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
  if echo "$VOL" | grep -q "MUTED"; then
    echo "%{F#859289}󰖁%{F-} muted"
  else
    PERCENT=$(echo "$VOL" | awk '{print int($2 * 100)}')
    echo "%{F#7fbbb3}󰕾%{F-} ${PERCENT}%"
  fi
  ;;
esac
