import asyncio
from dataclasses import dataclass
from datetime import datetime
from functools import partial
from itertools import chain
import os
import signal
import subprocess

HERE = os.path.dirname(__file__)

COMMANDS = (
    (rf"bash {HERE}/volume.bash", " volume - "),
    (rf"bash {HERE}/brightness.bash", "% brightness - "),
    (r"cat /sys/class/power_supply/BAT0/capacity", "% "),
    (r"cat /sys/class/power_supply/BAT0/status | tr A-Z a-z", " - "),
    (r"cat /sys/firmware/acpi/platform_profile", " mode - "),
    (r"date +'%m/%d %-I:%M%P'", " "),
)

POWER_PERIOD = 10  # seconds


def run_command(x):
    y = subprocess.run(x, shell=True, capture_output=True)
    return y.stdout.decode("utf-8").strip()


def print_status(statuses):
    parts = chain.from_iterable(
        (status, suffix) for status, (_, suffix) in zip(statuses, COMMANDS)
    )
    print("".join(parts), flush=True)


def update(statuses, i, silent=False):
    statuses[i] = run_command(COMMANDS[i][0])
    if not silent:
        print_status(statuses)


async def date_updater(statuses):
    # run date command at the beginning of every minute
    (i,) = (i for i, (command, _) in enumerate(COMMANDS) if command.startswith("date"))
    while True:
        now = datetime.now()
        seconds = now.second + now.microsecond / 1_000_000
        await asyncio.sleep(60 - seconds)
        update(statuses, i)


async def power_updater(statuses):
    # update power periodically
    # TODO get a signal when charger is (un)plugged?
    # TODO get a signal when Fn+L/M/H are pressed?
    ixs = tuple(
        i
        for i, (command, _) in enumerate(COMMANDS)
        if "/power_supply/" in command or "/acpi/" in command
    )
    while True:
        await asyncio.sleep(POWER_PERIOD)
        for i in ixs:
            update(statuses, i, silent=True)
        print_status(statuses)


async def main():
    # write pid file:
    with open(f"/run/user/{os.getuid()}/sway-bar-status.pid", "w") as f:
        f.write(str(os.getpid()))

    # initial values:
    statuses = ["" for _ in COMMANDS]
    for i in range(len(COMMANDS)):
        update(statuses, i, silent=True)
    print_status(statuses)

    # one signal for each command:
    loop = asyncio.get_running_loop()
    for i in range(len(COMMANDS)):
        # we use partial because lambdas would all capture the final value of i, not the current value
        loop.add_signal_handler(signal.SIGRTMIN + i + 1, partial(update, statuses, i))

    await asyncio.gather(date_updater(statuses), power_updater(statuses))


asyncio.run(main())
