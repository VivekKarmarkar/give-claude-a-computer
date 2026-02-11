#!/usr/bin/env bash
set -euo pipefail

# Controls ffmpeg screen recording of display :99.
# Usage: record.sh start [filename]
#        record.sh stop
#        record.sh status

DISPLAY_NUM=99
RECORDINGS_DIR="$HOME/give-claude-a-computer/recordings"
PID_FILE="/tmp/ffmpeg-record.pid"

mkdir -p "$RECORDINGS_DIR"

cmd_start() {
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Already recording (PID $(cat "$PID_FILE"))"
    echo "Use 'record.sh stop' first"
    exit 1
  fi

  local filename="${1:-recording-$(date +%Y%m%d-%H%M%S).mp4}"
  # Ensure .mp4 extension
  [[ "$filename" == *.mp4 ]] || filename="${filename}.mp4"
  local output="$RECORDINGS_DIR/$filename"

  echo "Starting recording → $output"
  ffmpeg \
    -f x11grab \
    -video_size 1920x1080 \
    -framerate 30 \
    -i ":${DISPLAY_NUM}" \
    -c:v libx264 \
    -preset ultrafast \
    -crf 23 \
    -pix_fmt yuv420p \
    "$output" \
    </dev/null &>/dev/null &

  echo $! > "$PID_FILE"
  sleep 1

  if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Recording started (PID $(cat "$PID_FILE"))"
  else
    echo "Error: ffmpeg failed to start" >&2
    rm -f "$PID_FILE"
    exit 1
  fi
}

cmd_stop() {
  if [[ ! -f "$PID_FILE" ]]; then
    echo "Not recording (no PID file)"
    exit 0
  fi

  local pid
  pid=$(cat "$PID_FILE")

  if ! kill -0 "$pid" 2>/dev/null; then
    echo "Recording process ($pid) already exited"
    rm -f "$PID_FILE"
    exit 0
  fi

  echo "Stopping recording (PID $pid)..."
  # SIGINT for graceful shutdown — ffmpeg finalizes the mp4 container
  kill -INT "$pid"

  # Wait up to 10 seconds for ffmpeg to finish writing
  for i in $(seq 1 10); do
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi
    sleep 1
  done

  # Force kill if still running
  if kill -0 "$pid" 2>/dev/null; then
    echo "Force killing ffmpeg..."
    kill -9 "$pid" 2>/dev/null || true
  fi

  rm -f "$PID_FILE"
  echo "Recording stopped"
  echo "Recordings in: $RECORDINGS_DIR"
  ls -lhtr "$RECORDINGS_DIR" | tail -3
}

cmd_status() {
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Recording in progress (PID $(cat "$PID_FILE"))"
    echo ""
    echo "Recordings:"
    ls -lhtr "$RECORDINGS_DIR" | tail -5
  else
    rm -f "$PID_FILE" 2>/dev/null || true
    echo "Not recording"
    local count
    count=$(find "$RECORDINGS_DIR" -name '*.mp4' 2>/dev/null | wc -l)
    echo "$count recording(s) in $RECORDINGS_DIR"
  fi
}

case "${1:-}" in
  start)  cmd_start "${2:-}" ;;
  stop)   cmd_stop ;;
  status) cmd_status ;;
  *)
    echo "Usage: record.sh {start [filename]|stop|status}" >&2
    exit 1
    ;;
esac
