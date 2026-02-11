#!/usr/bin/env bash
set -euo pipefail

# Launches Claude Code with a game prompt inside tmux.
# Auto-starts recording and auto-stops when Claude exits.
#
# Usage: play.sh "Go to brilliant.org and play the logic puzzles"
#        play.sh "Navigate to brilliant.org/courses/logic and solve 5 puzzles"

if [[ $# -lt 1 ]]; then
  echo "Usage: play.sh \"<prompt>\"" >&2
  echo "Example: play.sh \"Go to brilliant.org and play the daily challenge\"" >&2
  exit 1
fi

PROMPT="$1"
DISPLAY_NUM=99
TMUX_SESSION="claude"
PROJECT_DIR="$HOME/give-claude-a-computer"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export DISPLAY=":${DISPLAY_NUM}"

# Verify display is alive
if ! xdpyinfo &>/dev/null; then
  echo "Error: Display :${DISPLAY_NUM} not available. Run start-session.sh first." >&2
  exit 1
fi

# Auto-start recording if not already running.
# Track whether WE started it so we know to auto-stop on exit.
AUTO_STARTED_RECORDING=false
if [[ ! -f /tmp/ffmpeg-record.pid ]] || ! kill -0 "$(cat /tmp/ffmpeg-record.pid 2>/dev/null)" 2>/dev/null; then
  echo "==> Auto-starting screen recording"
  bash "$SCRIPT_DIR/record.sh" start
  AUTO_STARTED_RECORDING=true
fi

# Build the window name from the first 30 chars of the prompt
WINDOW_NAME="play-$(date +%H%M%S)"

# Ensure tmux session exists
if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
  echo "==> Creating tmux session '$TMUX_SESSION'"
  tmux new-session -d -s "$TMUX_SESSION" -e "DISPLAY=:${DISPLAY_NUM}"
fi

# Launch Claude in a new tmux window
echo "==> Launching Claude Code in tmux window '$WINDOW_NAME'"
# Build the tmux command — auto-stop recording if we started it
STOP_CMD=""
if [[ "$AUTO_STARTED_RECORDING" == true ]]; then
  STOP_CMD="bash $SCRIPT_DIR/record.sh stop;"
fi

tmux new-window -t "$TMUX_SESSION" -n "$WINDOW_NAME" \
  "cd $PROJECT_DIR && DISPLAY=:${DISPLAY_NUM} claude --dangerously-skip-permissions -p $(printf '%q' "$PROMPT"); ${STOP_CMD} echo '--- Claude exited. Recording stopped. Press Enter to close ---'; read"

echo ""
echo "============================================"
echo "  Claude is playing!"
echo "============================================"
echo ""
echo "Watch live:"
echo "  tmux attach -t $TMUX_SESSION"
echo ""
echo "Watch via VNC:"
echo "  ssh -L 5900:localhost:5900 root@$(hostname -I 2>/dev/null | awk '{print $1}' || echo '<droplet-ip>')"
echo "  VNC client → localhost:5900"
echo ""
echo "Recording auto-stops when Claude exits."
echo "Manual control:  bash $SCRIPT_DIR/record.sh {start|stop|status}"
