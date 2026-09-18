#!/usr/bin/env bash
set -e

exec "${TERMINAL:-alacritty}" -e nvim "/home/tudor/cave/littlebrain"
