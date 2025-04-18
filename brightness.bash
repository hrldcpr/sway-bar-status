# to write brightness without sudo, user must be in the 'video' group
# and backlight.rules must be installed in /etc/udev/rules.d/

signal=2 # see status.py

min_brightness=0
max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
step=$((max_brightness / 20)) # 5%

brightness=$(cat /sys/class/backlight/intel_backlight/brightness)

# sway config runs this file with "down" or "up" arguments when brightness buttons are pressed
# and status.py runs this with no arguments to get current brightness:

if [ "$1" = "down" ]; then
    brightness=$((brightness - step))
    if ((brightness < min_brightness)); then brightness=$min_brightness; fi
    echo "$brightness" > /sys/class/backlight/intel_backlight/brightness
    . "$(dirname "$0")"/signal.bash $signal
elif [ "$1" = "up" ]; then
    brightness=$((brightness + step + 1))
    if ((brightness > max_brightness)); then brightness=$max_brightness; fi
    echo "$brightness" > /sys/class/backlight/intel_backlight/brightness
    . "$(dirname "$0")"/signal.bash $signal
else
    echo $((100 * brightness / max_brightness))
fi
