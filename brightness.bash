# to write brightness without sudo, user must be in the 'video' group
# and backlight.rules must be installed in /etc/udev/rules.d/

signal=2 # see status.py

min_brightness=1
max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)
step=$((max_brightness / 5)) # 20%

brightness=$(cat /sys/class/backlight/intel_backlight/brightness)

if [ "$1" = "down" ]; then
    brightness=$((brightness - step))
    if ((brightness < min_brightness)); then brightness=$min_brightness; fi
    echo "$brightness" > /sys/class/backlight/intel_backlight/brightness
    . "$(dirname "$0")"/signal.bash $signal
elif [ "$1" = "up" ]; then
    brightness=$((brightness + step))
    if ((brightness > max_brightness)); then brightness=$max_brightness; fi
    echo "$brightness" > /sys/class/backlight/intel_backlight/brightness
    . "$(dirname "$0")"/signal.bash $signal
fi

echo $((100 * brightness / max_brightness))
