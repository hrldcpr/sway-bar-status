signal=1 # see status.py

# sway config runs this file with "down" or "up" arguments when volume buttons are pressed
# and status.py runs this with no arguments to get current volume:

max=153 # pavucontrol maxes out at 153% so we do the same, to avoid blowing speakers

if [ "$1" = "down" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    . "$(dirname "$0")"/signal.bash $signal
elif [ "$1" = "up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    current=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
    if [ "$current" -gt $max ]; then
        pactl set-sink-volume @DEFAULT_SINK@ $max%
    fi
    . "$(dirname "$0")"/signal.bash $signal
else
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1
fi
