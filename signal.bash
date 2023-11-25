# send first argument as a signal to status.py, based on its pid file
pkill -SIGRTMIN+"$1" -F "$XDG_RUNTIME_DIR"/sway-bar-status.pid
