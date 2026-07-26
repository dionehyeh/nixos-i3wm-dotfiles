#!/usr/bin/env bash

# Kill every polybar instance cleanly
polybar-msg cmd quit 2>/dev/null
killall -q polybar 2>/dev/null

# Wait until all are dead
while pgrep -x polybar >/dev/null; do sleep 0.1; done

# Launch single bar
polybar main 2>&1 | tee -a /tmp/polybar.log &
disown
