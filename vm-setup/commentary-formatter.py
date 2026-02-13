#!/usr/bin/env python3
"""
Commentary Formatter for Claude Game Player

Reads Claude's stream-json output from stdin and:
1. Displays narration and tool actions live in the terminal (with colors)
2. Saves clean commentary to a text file for later TTS

Usage:
  claude -p "..." --output-format stream-json --verbose --include-partial-messages \
    --dangerously-skip-permissions 2>/dev/null | python3 commentary-formatter.py [output.txt]
"""

import json
import sys
import os
import textwrap
from datetime import datetime

# ── ANSI colors ──
RESET = "\033[0m"
BOLD = "\033[1m"
DIM = "\033[2m"
GREEN = "\033[38;5;114m"     # narration text
CYAN = "\033[38;5;81m"      # tool calls
YELLOW = "\033[38;5;221m"   # headers
GRAY = "\033[38;5;243m"     # dim info
WHITE = "\033[38;5;255m"    # bright text
BG_DARK = "\033[48;5;235m"  # subtle background

# Terminal width for wrapping
TERM_WIDTH = int(os.environ.get("COLUMNS", "100"))
WRAP_WIDTH = min(TERM_WIDTH - 4, 96)

# Tool name → friendly label mapping
TOOL_LABELS = {
    "mcp__playwright__browser_navigate": "Navigating",
    "mcp__playwright__browser_snapshot": "Reading page",
    "mcp__playwright__browser_click": "Clicking",
    "mcp__playwright__browser_type": "Typing",
    "mcp__playwright__browser_take_screenshot": "Taking screenshot",
    "mcp__playwright__browser_evaluate": "Running JavaScript",
    "mcp__playwright__browser_hover": "Hovering",
    "mcp__playwright__browser_press_key": "Pressing key",
    "mcp__playwright__browser_select_option": "Selecting option",
    "mcp__playwright__browser_fill_form": "Filling form",
    "mcp__playwright__browser_drag": "Dragging",
    "mcp__playwright__browser_wait_for": "Waiting",
    "mcp__playwright__browser_tabs": "Managing tabs",
    "mcp__playwright__browser_navigate_back": "Going back",
    "mcp__playwright__browser_console_messages": "Reading console",
    "mcp__playwright__browser_network_requests": "Checking network",
    "mcp__playwright__browser_close": "Closing browser",
    "mcp__playwright__browser_resize": "Resizing browser",
    "mcp__playwright__browser_install": "Installing browser",
    "mcp__playwright__browser_run_code": "Running code",
    "Bash": "Running command",
    "Read": "Reading file",
    "Write": "Writing file",
    "Edit": "Editing file",
    "Glob": "Finding files",
    "Grep": "Searching code",
    "WebFetch": "Fetching web page",
    "WebSearch": "Searching web",
}


def friendly_tool_name(tool_name):
    """Get a friendly label for a tool name."""
    return TOOL_LABELS.get(tool_name, tool_name.split("__")[-1].replace("_", " ").title())


def print_header():
    """Print the session header."""
    line = "━" * WRAP_WIDTH
    print(f"\n{YELLOW}{BOLD}{line}{RESET}")
    print(f"{YELLOW}{BOLD}  Claude Game Player{RESET}")
    print(f"{GRAY}  {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{RESET}")
    print(f"{YELLOW}{BOLD}{line}{RESET}\n")
    sys.stdout.flush()


def print_text(text):
    """Print narration text with wrapping and colors."""
    wrapped = textwrap.fill(text, width=WRAP_WIDTH)
    print(f"{GREEN}{wrapped}{RESET}", end="", flush=True)


def print_tool_action(tool_name, tool_input=None):
    """Print a tool action indicator."""
    label = friendly_tool_name(tool_name)

    # Extract useful detail from tool input
    detail = ""
    if tool_input:
        if "url" in tool_input:
            url = tool_input["url"]
            # Shorten long URLs
            if len(url) > 60:
                url = url[:57] + "..."
            detail = f" → {url}"
        elif "ref" in tool_input and "element" in tool_input:
            detail = f" → {tool_input['element'][:50]}"
        elif "ref" in tool_input:
            detail = f" → {tool_input['ref']}"
        elif "text" in tool_input:
            detail = f" → \"{tool_input['text'][:40]}\""
        elif "key" in tool_input:
            detail = f" → {tool_input['key']}"

    print(f"\n{CYAN}{DIM}  ▸ {label}{detail}{RESET}")
    sys.stdout.flush()


def print_separator():
    """Print a subtle separator."""
    print(f"\n{GRAY}{'─' * (WRAP_WIDTH // 2)}{RESET}\n")
    sys.stdout.flush()


def print_complete():
    """Print session complete message."""
    line = "━" * WRAP_WIDTH
    print(f"\n\n{YELLOW}{BOLD}{line}{RESET}")
    print(f"{YELLOW}{BOLD}  Session Complete{RESET}")
    print(f"{YELLOW}{BOLD}{line}{RESET}\n")
    sys.stdout.flush()


def main():
    # Output file for TTS-ready commentary
    output_file = sys.argv[1] if len(sys.argv) > 1 else None
    commentary_lines = []

    # State tracking
    current_tool_name = None
    current_tool_input_json = ""
    in_text_block = False
    text_buffer = ""
    turn_count = 0

    print_header()

    if output_file:
        commentary_lines.append(f"# Claude Game Player Commentary")
        commentary_lines.append(f"# {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        commentary_lines.append("")

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        event_type = event.get("type", "")

        # ── Stream events (partial messages) ──
        if event_type == "stream_event":
            inner = event.get("event", {})
            inner_type = inner.get("type", "")

            # Text block starting
            if inner_type == "content_block_start":
                block = inner.get("content_block", {})
                if block.get("type") == "text":
                    in_text_block = True
                    text_buffer = ""
                elif block.get("type") == "tool_use":
                    in_text_block = False
                    current_tool_name = block.get("name", "unknown")
                    current_tool_input_json = ""

            # Text delta — streaming narration
            elif inner_type == "content_block_delta":
                delta = inner.get("delta", {})
                if delta.get("type") == "text_delta":
                    text = delta.get("text", "")
                    print_text(text)
                    text_buffer += text
                elif delta.get("type") == "input_json_delta":
                    current_tool_input_json += delta.get("partial_json", "")

            # Block complete
            elif inner_type == "content_block_stop":
                if in_text_block and text_buffer.strip():
                    # Save narration for TTS
                    commentary_lines.append(text_buffer.strip())
                    commentary_lines.append("")
                    print("", flush=True)  # newline after text
                    text_buffer = ""
                    in_text_block = False
                elif current_tool_name:
                    # Parse tool input and show action
                    tool_input = None
                    try:
                        if current_tool_input_json:
                            tool_input = json.loads(current_tool_input_json)
                    except json.JSONDecodeError:
                        pass
                    print_tool_action(current_tool_name, tool_input)
                    # Save tool action for commentary
                    label = friendly_tool_name(current_tool_name)
                    commentary_lines.append(f"[Action: {label}]")
                    current_tool_name = None
                    current_tool_input_json = ""

            # New message starting (new turn)
            elif inner_type == "message_start":
                turn_count += 1
                if turn_count > 1:
                    print_separator()

        # ── Complete assistant message (without --include-partial-messages) ──
        elif event_type == "assistant":
            msg = event.get("message", {})
            content = msg.get("content", [])
            for block in content:
                if block.get("type") == "text":
                    text = block.get("text", "")
                    if text.strip():
                        # Only print if we haven't already streamed it
                        if not in_text_block:
                            print_text(text)
                            print("", flush=True)
                            commentary_lines.append(text.strip())
                            commentary_lines.append("")
                elif block.get("type") == "tool_use":
                    name = block.get("name", "unknown")
                    inp = block.get("input", {})
                    print_tool_action(name, inp)
                    label = friendly_tool_name(name)
                    commentary_lines.append(f"[Action: {label}]")

        # ── Final result ──
        elif event_type == "result":
            print_complete()
            duration = event.get("duration_ms", 0)
            cost = event.get("total_cost_usd", 0)
            turns = event.get("num_turns", 0)
            commentary_lines.append("")
            commentary_lines.append(f"[Session: {turns} turns, {duration/1000:.1f}s, ${cost:.4f}]")

    # Write commentary file
    if output_file:
        with open(output_file, "w") as f:
            f.write("\n".join(commentary_lines))
        print(f"\n{GRAY}Commentary saved to: {output_file}{RESET}\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
