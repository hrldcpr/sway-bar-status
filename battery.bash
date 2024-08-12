status=$(tr '[:upper:]' '[:lower:]' < /sys/class/power_supply/BAT0/status)
capacity=$(cat /sys/class/power_supply/BAT0/capacity)

if ((capacity<30)); then
    color="#880000"
elif ((capacity<40)); then
    color="#883300"
elif ((capacity<50)); then
    color="#886600"
else
    color="#00000001" # alpha=0 doesn't work for some reason
fi
echo "<span background=\"$color\">- $status $capacity% -</span>"
