#!/bin/bash
if pgrep -x "waybar" >/dev/null; then
  # Si Waybar está corriendo, lo matamos
  killall waybar
else
  # Si Waybar no está corriendo, lo lanzamos
  waybar &
fi
