# send first argument as a signal to status.py, based on its pid file
pkill -SIGRTMIN+"$1" -F /run/user/"$(id -u)"/sway-bar-status.pid
