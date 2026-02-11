#!/usr/bin/env bash
set -euo pipefail

# Starts the graphical environment and drops you into a tmux session
# with DISPLAY=:99 so Claude/Chromium can render to the virtual display.

DISPLAY_NUM=99
TMUX_SESSION="claude"

echo "==> Checking Xvfb service"
if ! systemctl is-active --quiet xvfb.service; then
  echo "Starting Xvfb..."
  sudo systemctl start xvfb.service
  sleep 1
fi

echo "==> Checking x11vnc service"
if ! systemctl is-active --quiet x11vnc.service; then
  echo "Starting x11vnc..."
  sudo systemctl start x11vnc.service
  sleep 1
fi

# Verify display is alive
if DISPLAY=:${DISPLAY_NUM} xdpyinfo &>/dev/null; then
  echo "  Display :${DISPLAY_NUM} is active"
else
  echo "Error: Display :${DISPLAY_NUM} is not responding" >&2
  echo "Check: systemctl status xvfb.service" >&2
  exit 1
fi

echo ""
echo "VNC connection (from your laptop):"
echo "  1. SSH tunnel:  ssh -L 5900:localhost:5900 $(whoami)@$(hostname -I | awk '{print $1}')"
echo "  2. VNC client:  connect to localhost:5900"
echo ""

# Create or attach to tmux session with DISPLAY set
if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
  echo "Attaching to existing tmux session '$TMUX_SESSION'"
  tmux attach-session -t "$TMUX_SESSION"
else
  echo "Creating new tmux session '$TMUX_SESSION' with DISPLAY=:${DISPLAY_NUM}"
  tmux new-session -d -s "$TMUX_SESSION" -e "DISPLAY=:${DISPLAY_NUM}"
  tmux attach-session -t "$TMUX_SESSION"
fi
