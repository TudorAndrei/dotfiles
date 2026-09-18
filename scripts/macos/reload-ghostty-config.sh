#!/usr/bin/env bash
set -e

# Ghostty reloads its configuration when it receives SIGUSR2. This watcher is
# invoked by launchd whenever a file under configs/ghostty changes.
killall -USR2 ghostty 2>/dev/null || true
