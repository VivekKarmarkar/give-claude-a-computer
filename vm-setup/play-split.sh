#!/usr/bin/env bash
set -euo pipefail

# Launches Claude in a split-screen layout:
#   Left half:  terminal showing Claude's output/reasoning
#   Right half: Chromium browser with the game/simulation
# Records the entire display with ffmpeg.
# Saves recording + commentary into topics/<topic-name>/ folder.
#
# Usage: play-split.sh <topic-name> "<prompt>"
# Example: play-split.sh gravity-and-orbits "Go to the PhET gravity sim and explore it"

if [[ $# -lt 2 ]]; then
  echo "Usage: play-split.sh <topic-name> \"<prompt>\"" >&2
  echo "" >&2
  echo "Example:" >&2
  echo "  play-split.sh gravity-and-orbits \"Go to the PhET gravity sim and explore it\"" >&2
  echo "" >&2
  echo "Files will be saved to: topics/<topic-name>/recording.mp4 and commentary.txt" >&2
  exit 1
fi

TOPIC="$1"
PROMPT="$2"
DISPLAY_NUM=99
PROJECT_DIR="$HOME/give-claude-a-computer"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Topic output directory
TOPIC_DIR="$PROJECT_DIR/topics/$TOPIC"
mkdir -p "$TOPIC_DIR"

export DISPLAY=":${DISPLAY_NUM}"

# Verify display is alive
if ! xdpyinfo &>/dev/null; then
  echo "Error: Display :${DISPLAY_NUM} not available. Run start-session.sh first." >&2
  exit 1
fi

# ── 0. Swap to split-screen MCP config (narrower viewport for right half) ──
MCP_ORIGINAL="$PROJECT_DIR/.mcp.json"
MCP_SPLIT="$PROJECT_DIR/.mcp-split.json"
MCP_BACKUP="$PROJECT_DIR/.mcp-fullscreen.json"

if [[ -f "$MCP_SPLIT" ]]; then
  cp "$MCP_ORIGINAL" "$MCP_BACKUP"
  cp "$MCP_SPLIT" "$MCP_ORIGINAL"
  echo "==> Switched to split-screen MCP config (940x1020 viewport)"
  RESTORE_MCP=true
else
  echo "Warning: .mcp-split.json not found, using default config"
  RESTORE_MCP=false
fi

# ── 1. Start openbox window manager (if not already running) ──
if ! pgrep -x openbox &>/dev/null; then
  echo "==> Starting openbox window manager"
  openbox --config-file "$HOME/.config/openbox/rc.xml" &
  sleep 1
fi

# ── 2. Set a dark background ──
if command -v xsetroot &>/dev/null; then
  xsetroot -solid '#1a1a2e'
fi

# ── 3. Start ffmpeg recording ──
RECORDING_FILE="$TOPIC_DIR/recording.mp4"
# If recording.mp4 already exists, use a timestamped name
if [[ -f "$RECORDING_FILE" ]]; then
  RECORDING_FILE="$TOPIC_DIR/recording-$(date +%Y%m%d-%H%M%S).mp4"
fi
echo "==> Starting recording → $RECORDING_FILE"
ffmpeg \
  -f x11grab \
  -video_size 1920x1080 \
  -framerate 30 \
  -i ":${DISPLAY_NUM}" \
  -c:v libx264 \
  -preset ultrafast \
  -crf 23 \
  -pix_fmt yuv420p \
  "$RECORDING_FILE" \
  </dev/null &>/dev/null &
FFMPEG_PID=$!
echo "$FFMPEG_PID" > /tmp/ffmpeg-record.pid
sleep 1

if ! kill -0 "$FFMPEG_PID" 2>/dev/null; then
  echo "Error: ffmpeg failed to start" >&2
  exit 1
fi
echo "  Recording started (PID $FFMPEG_PID)"

# ── 4. Launch Claude in xterm on the left half ──
echo "==> Launching Claude in split-screen terminal"
echo "  Topic: $TOPIC"

# xterm settings for a nice recording appearance
XTERM_OPTS=(
  -bg '#0d1117'        # dark background
  -fg '#e6edf3'        # light text
  -fa 'Monospace'      # font family
  -fs 11               # font size (readable in video)
  -geometry 110x55     # columns x rows
  -T "Claude AI — $TOPIC"
  +sb                  # no scrollbar (cleaner look)
  -e bash -c
)

# Commentary output file (for later TTS)
COMMENTARY_FILE="$TOPIC_DIR/commentary.txt"
if [[ -f "$COMMENTARY_FILE" ]]; then
  COMMENTARY_FILE="$TOPIC_DIR/commentary-$(date +%Y%m%d-%H%M%S).txt"
fi
FORMATTER="$PROJECT_DIR/commentary-formatter.py"

# The command Claude runs inside xterm, piped through the formatter
CLAUDE_CMD="cd $PROJECT_DIR && claude --dangerously-skip-permissions -p $(printf '%q' "$PROMPT") --output-format stream-json --verbose --include-partial-messages 2>/dev/null | python3 $FORMATTER $COMMENTARY_FILE; sleep 5"

xterm "${XTERM_OPTS[@]}" "$CLAUDE_CMD" &
XTERM_PID=$!

echo "  xterm PID: $XTERM_PID"
echo ""
echo "============================================"
echo "  Claude is playing! (split-screen mode)"
echo "  Topic: $TOPIC"
echo "============================================"
echo ""
echo "Recording: $RECORDING_FILE"
echo "Commentary: $COMMENTARY_FILE"
echo "Watch via VNC: ssh -L 6080:localhost:6080 claude@$(hostname -I | awk '{print $1}')"
echo "              → http://localhost:6080"
echo ""

# ── 5. Wait for Claude to finish ──
wait "$XTERM_PID" 2>/dev/null || true

# ── 6. Stop recording ──
echo "==> Stopping recording..."
if kill -0 "$FFMPEG_PID" 2>/dev/null; then
  kill -INT "$FFMPEG_PID"
  for i in $(seq 1 10); do
    kill -0 "$FFMPEG_PID" 2>/dev/null || break
    sleep 1
  done
  # Force kill if still running
  kill -0 "$FFMPEG_PID" 2>/dev/null && kill -9 "$FFMPEG_PID" 2>/dev/null
fi
rm -f /tmp/ffmpeg-record.pid

# ── 7. Restore original MCP config ──
if [[ "${RESTORE_MCP:-false}" == true ]] && [[ -f "$MCP_BACKUP" ]]; then
  cp "$MCP_BACKUP" "$MCP_ORIGINAL"
  echo "==> Restored original MCP config"
fi

# ── 8. Add lo-fi background music ──
MUSIC_FILE="$PROJECT_DIR/topics/music/Soft Circuit Study.mp3"
FINAL_FILE="${RECORDING_FILE%.mp4}-with-music.mp4"

if [[ -f "$MUSIC_FILE" ]] && [[ -f "$RECORDING_FILE" ]]; then
  echo "==> Adding lo-fi background music..."

  # Get video duration in seconds
  VIDEO_DUR=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$RECORDING_FILE")
  MUSIC_DUR=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$MUSIC_FILE")

  # Calculate fade-out start (3 seconds before end)
  FADE_OUT_START=$(echo "$VIDEO_DUR - 3" | bc)

  # Build the audio filter:
  #   - Loop the music if video is longer than music, otherwise just use it once
  #   - Trim to match video duration
  #   - Fade in over 2s, fade out over last 3s
  #   - Set volume to 30% (background level)
  NEEDS_LOOP=$(echo "$VIDEO_DUR > $MUSIC_DUR" | bc)

  if [[ "$NEEDS_LOOP" -eq 1 ]]; then
    # Loop the music stream to cover the full video duration
    LOOP_COUNT=$(echo "($VIDEO_DUR / $MUSIC_DUR) + 1" | bc)
    ffmpeg -y \
      -i "$RECORDING_FILE" \
      -stream_loop "$LOOP_COUNT" -i "$MUSIC_FILE" \
      -filter_complex "[1:a]atrim=0:${VIDEO_DUR},afade=t=in:st=0:d=2,afade=t=out:st=${FADE_OUT_START}:d=3,volume=0.3[music]" \
      -map 0:v -map "[music]" \
      -c:v copy -c:a aac -b:a 192k -shortest \
      "$FINAL_FILE" </dev/null 2>/dev/null
  else
    # Music is long enough — just trim it
    ffmpeg -y \
      -i "$RECORDING_FILE" \
      -i "$MUSIC_FILE" \
      -filter_complex "[1:a]afade=t=in:st=0:d=2,afade=t=out:st=${FADE_OUT_START}:d=3,volume=0.3,atrim=0:${VIDEO_DUR}[music]" \
      -map 0:v -map "[music]" \
      -c:v copy -c:a aac -b:a 192k -shortest \
      "$FINAL_FILE" </dev/null 2>/dev/null
  fi

  if [[ -f "$FINAL_FILE" ]]; then
    echo "  Music added → $FINAL_FILE"
  else
    echo "  Warning: Failed to add music, raw recording still available"
  fi
else
  if [[ ! -f "$MUSIC_FILE" ]]; then
    echo "==> Skipping music (no track found at $MUSIC_FILE)"
  fi
fi

echo ""
echo "============================================"
echo "  Session complete!"
echo "  Topic: $TOPIC"
echo "============================================"
echo ""
echo "Output directory: $TOPIC_DIR"
ls -lh "$TOPIC_DIR"/
