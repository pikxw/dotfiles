#!/bin/bash

# Detectar el brillo actual con corte más preciso
CURRENT=$(ddcutil getvcp 10 2>/dev/null | awk -F 'current value = ' '{print $2}' | awk -F ',' '{print $1}' | tr -d ' ')

if [ -z "$CURRENT" ]; then
  notify-send "Error" "No se pudo obtener el brillo actual."
  exit 1
fi

if [ "$CURRENT" -ge 50 ]; then
  ddcutil setvcp 10 0
  notify-send "Brillo" "Bajado a 0%"
else
  ddcutil setvcp 10 100
  notify-send "Brillo" "Subido a 100%"
fi
