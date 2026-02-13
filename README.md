# Claude Game Player

An autonomous AI agent that plays educational simulations in a real browser, producing screen recordings with live commentary and lo-fi background music. Built to validate the UX quality of interactive educational software.

## What This Does

Claude Code controls a headless Chromium browser via Playwright MCP on a DigitalOcean VM. It navigates educational sims the same way a student would — clicking buttons, moving sliders, reading instructions — while narrating its reasoning in a terminal. The entire session is recorded as a split-screen video (terminal + browser) with a lo-fi music overlay.

**One command produces a complete recording:**

```bash
./play-split.sh gravity-and-orbits "Go to the PhET gravity sim and explore it"
```

## Why

Educational software UX is hard to evaluate objectively. This system turns subjective feelings ("I think my UI has issues") into measurable findings ("the AI agent couldn't complete 20 of 28 tasks due to interaction barriers"). Key insight: if an AI agent can navigate your educational tool smoothly, your interaction design is solid.

## Results

| Simulation | Source | Duration | Cost | Verdict |
|---|---|---|---|---|
| Matrix Transforms | Custom | 3:18 | $0.83 | Explored all features naturally |
| Gravity & Orbits | PhET | 3:34 | ~$1 | Guided UI worked well |
| Feynman Conservation (coached) | Custom | 6:11 | $2.10 | Found 8/28 blocks, avoided drag-and-drop |
| Energy Skate Park | PhET | 9:03 | ~$3 | Hallucinated thermal energy |
| Neural Networks Ch4 | M. Nielsen | 14:52 | $5.77 | Good commentary, couldn't use widgets |

Session duration emerged as a quality proxy: short + complete = well-designed.

## Architecture

```
Local machine                    DigitalOcean VM (s-2vcpu-4gb)
+------------------+            +--------------------------------+
|                  |   SSH      |  Xvfb (display :99, 1920x1080) |
|  Launch script   +----------->|                                |
|  VNC viewer      |            |  +------------+ +------------+ |
|                  |            |  | XTerm      | | Chromium   | |
+------------------+            |  | (Claude    | | (sim/game) | |
                                |  |  output)   | |            | |
                                |  +------------+ +------------+ |
                                |                                |
                                |  Claude Code + Playwright MCP  |
                                |  ffmpeg screen recording       |
                                +--------------------------------+
```

## Repository Structure

```
vm-setup/
  setup.sh                 # One-time VM provisioning (Ubuntu 24.04)
  play-split.sh            # Main pipeline: launch, record, mix music
  play.sh                  # Simpler single-window variant
  record.sh                # Standalone recording utility
  start-session.sh         # Basic session launcher
  cleanup.sh               # Kill stale processes
  commentary-formatter.py  # Parse Claude's JSON output into readable text
  dot-mcp.json             # Playwright MCP server config
  CLAUDE.md                # Instructions for Claude on the VM

FUTURE-VISION.md           # Strategy: multi-agent classroom, NSF grant, positioning
ROADMAP.md                 # 5-phase roadmap from portfolio to research
```

## Setup

1. **Provision a droplet** (Ubuntu 24.04, 2 vCPU / 4GB RAM):
   ```bash
   scp -r vm-setup/ root@<droplet-ip>:~/give-claude-a-computer/
   ssh root@<droplet-ip> "bash ~/give-claude-a-computer/setup.sh"
   ```

2. **Set your API key** on the VM:
   ```bash
   echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.profile
   ```

3. **Copy MCP config**:
   ```bash
   cp dot-mcp.json .mcp.json
   ```

4. **Run a session**:
   ```bash
   ./play-split.sh matrix-transforms "Go to https://example.com/sim and explore it"
   ```

5. **Watch live** via VNC:
   ```bash
   ssh -L 5900:localhost:5900 -L 6080:localhost:6080 user@<droplet-ip>
   # Then open a VNC client pointed at localhost:5900
   ```

## Key Findings

Three design principles that drive engagement in educational sims:

1. **Multiple affordances** — Visual, numerical, and code paths. If one is blocked, alternatives exist.
2. **Gradient of success** — Not binary pass/fail. Correct-but-not-optimal drives re-engagement.
3. **Immediate feedback** — Click, result, learn. No ambiguity about whether your action had an effect.

See [FUTURE-VISION.md](FUTURE-VISION.md) for the full analysis, origin stories, and strategic positioning.

## Tech Stack

- **VM**: DigitalOcean droplet, Ubuntu 24.04, Xvfb, Openbox
- **Browser**: Chromium via [Playwright MCP](https://github.com/anthropics/anthropic-mcp)
- **AI**: Claude Code CLI with `--output-format stream-json`
- **Recording**: ffmpeg x11grab at 30fps, CRF 23, lo-fi music overlay
- **Music**: "Soft Circuit Study" from Suno (30% volume, fade-in/fade-out)
