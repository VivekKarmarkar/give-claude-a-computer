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

## The Origin Story

1. Built interactive physics/math sims. Had a feeling the Feynman game had UI issues but couldn't quantify them.
2. Asked Claude Code to play the Feynman game. Claude **cheated** by reading the source code.
3. Sent Claude to Brilliant.org where it can't see source code. Claude got **addicted** — 25,000 XP in 2 days.
4. Brilliant **banned the account** for bot activity.
5. Pivoted to a full VM-based system with Playwright MCP for authentic browser interaction.
6. The AI agent data now **confirms** what was previously just a feeling: Brilliant and PhET have superior UX affordances. Custom sims have specific, measurable friction points.

## Results

Nine simulation sessions across PhET, custom-built, and third-party educational content:

| Simulation | Source | Duration | Cost | Verdict |
|---|---|---|---|---|
| Matrix Transforms | Custom | 3:18 | $0.83 | Explored all 4 transform types naturally |
| Gravity & Orbits | PhET | 3:34 | ~$1 | Guided UI worked well |
| Earnshaw's Theorem | Custom | 3:47 | ~$1 | Got distracted by display buttons |
| Feynman Conservation v2 | Custom (coached) | 6:11 | $2.10 | Found 8/28 blocks, avoided drag-and-drop |
| Polarity Shift | Universe and More | 7:27 | ~$2.50 | Couldn't handle drag-and-drop at all |
| Sequence Convergence | Custom | 8:13 | ~$2.80 | Got hooked, correct but not optimal answer |
| Energy Skate Park | PhET | 9:03 | ~$3 | Hallucinated thermal energy when friction was off |
| Feynman Conservation v1 | Custom | 11:13 | ~$4 | Couldn't get past the first hurdle |
| Neural Networks Ch4 | M. Nielsen | 14:52 | $5.77 | Great commentary, couldn't use sliders |

**Session duration is a quality proxy:** short + complete = well-designed. The 3-minute Matrix Transforms session where Claude covered everything is a stronger validation signal than a 15-minute session where Claude struggled with widgets.

### Claude Behaves Like a B-Minus Student

- Strong conceptual knowledge, weak at verifying what's actually on screen vs. what it expects
- Hallucinated thermal energy in Energy Skate Park when friction wasn't even toggled on, then declared everything "working perfectly"
- Was visibly "scared" of drag-and-drop in Feynman Conservation — backed off, stayed defensive, avoided interactions
- Got the correct answer on Sequence Convergence math but knew it wasn't optimal, which drove retry behavior
- Confidently narrated physics that wasn't happening on screen

### The Success Case vs. The Failure Case

| Factor | Sequence Convergence (success) | Feynman Conservation (failure) |
|---|---|---|
| Scaffolding | Yes (3 progressive levels) | No (playground vs game, both unscaffolded) |
| Drag-and-drop | Minimal | Heavy |
| Engagement | High ("let me try again") | Low (defensive, scared) |
| Feedback | Immediate | Unclear |
| Activation energy | Low | High |

Game quality and physics content are strong in both. The difference is purely interaction design and scaffolding. This is actionable — these sims don't need content changes, they need UX improvements.

### The Confounded Variable

We can't yet tell if Claude fails because drag-and-drop is broken for Playwright (interaction problem) or because the sim lacks scaffolding (design problem). The experiment: add a text command mode to the Feynman sim ("place box on scale" instead of dragging). If Claude succeeds with text → drag-and-drop was the bottleneck. If Claude still fails → scaffolding is the real issue.

### The Irony

The Sequence Convergence game's scaffolding — progressive levels, immediate feedback, multiple interaction paths — was designed by Claude (Artifacts/Sonnet in the browser). The user had the core concept as hacky Python code; Claude suggested the engagement loop. Then a *different* Claude on the VM played the game and got hooked. Claude is its own best UX designer AND user tester.

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
