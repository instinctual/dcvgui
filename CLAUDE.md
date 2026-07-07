# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

DCVgui is a small YAD-based GUI for creating, saving, and launching connection shortcuts for the NICE DCV Viewer on Linux (tested on Ubuntu 22.04; expected to work on RHEL-based distros). There is no build system, package manager, or test suite — the entire application is a single bash script.

## Files

- `dcvgui.sh` — the whole application. A loop of YAD dialogs: `run_gui` (pick a connection and launch `dcvviewer`), `run_manage` (delete connections or go to create), `run_create` (form that writes a new `.dcv` file). Connections are stored as `*.dcv` INI-style files in `$CONFIGDIR` (default `~/.config/dcvgui`), named after the connection.
- `install_dcvgui.sh` — root-only installer; copies the script to `/opt/instinctual/bin/`, the `.desktop` entry to `/usr/share/applications/`, and the icon to `/opt/instinctual`.
- `dcvgui.desktop` — desktop launcher entry pointing at the installed paths.

## Running and checking changes

- Run directly: `./dcvgui.sh`. Requires `yad` and `dcvviewer` on PATH (prereqs are checked at startup). `CONFIGDIR` and `DCVVIEWER` can be overridden via environment variables, which is useful for testing without touching real config or having DCV installed (e.g. `CONFIGDIR=/tmp/dcvtest DCVVIEWER=echo ./dcvgui.sh`).
- Lint: `shellcheck dcvgui.sh` (no CI or configured tooling; this is the sensible check for changes).
- The GUI requires a Linux desktop session with YAD — it cannot be exercised on macOS or headless environments.

## Behavior notes

- DCV Viewer launch flags live in the `DCVVIEWER_OPTIONS` array at the top of `dcvgui.sh` (currently fullscreen, all monitors, accept untrusted certificates). The viewer is launched in the background and the chooser GUI intentionally stays open so multiple sessions can be started.
- YAD dialog buttons map to exit codes (`--button "Label":N`), and the `case $status in` blocks dispatch on those codes — keep button numbers and case arms in sync when editing dialogs.
- The dialog functions call each other recursively (e.g. `run_create` falls back into `run_gui` on error/cancel) rather than returning, so control flow does not unwind back through callers.
