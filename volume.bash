signal=1 # see status.py

# sway config runs this file with "down" or "up" arguments when volume buttons are pressed
# and status.py runs this with no arguments to get current volume:

if [ "$1" = "down" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    . "$(dirname "$0")"/signal.bash $signal
elif [ "$1" = "up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    current=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
    if [ "$current" -gt 153 ]; then
        pactl set-sink-volume @DEFAULT_SINK@ 153%
    fi
    . "$(dirname "$0")"/signal.bash $signal
else
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1
fi
