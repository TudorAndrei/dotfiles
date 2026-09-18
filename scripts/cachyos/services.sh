#!/usr/bin/env bash
set -e

echo "=== CachyOS Services Script ==="
echo ""

echo "==> Enabling user services..."
systemctl --user enable swaync.service 2>/dev/null || true
systemctl --user enable gammastep.service 2>/dev/null || true
systemctl --user enable hypridle.service 2>/dev/null || true
systemctl --user enable speech-dispatcherd.service 2>/dev/null || true

echo ""
echo "=== Services Enabled! ==="
