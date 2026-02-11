# Claude Game Player -- Project Roadmap

> **An autonomous game-playing system**: Claude Code drives a browser on a DigitalOcean VM, solves puzzles on Brilliant.org and beyond, while you spectate live via VNC and capture recordings.

**Last updated:** 2026-02-10

---

## Status Legend

| Symbol | Meaning        |
|--------|----------------|
| [x]    | Complete       |
| [~]    | In Progress    |
| [ ]    | Planned        |
| [.]    | Future / Idea  |

---

## Phase 1: Core Infrastructure

**Status:** COMPLETE | **Effort:** ~3 days | **Dependencies:** None

The foundational VM environment is fully provisioned and operational. Claude Code can launch a browser, navigate pages, and interact with web content autonomously.

- [x] DigitalOcean VM provisioning (Ubuntu, adequate CPU/RAM)
- [x] Xvfb virtual framebuffer for headless display
- [x] x11vnc for remote desktop access
- [x] noVNC for browser-based live spectating (no VNC client needed)
- [x] Chromium browser installation
- [x] Node.js runtime for Playwright
- [x] Claude Code CLI installation and configuration
- [x] Playwright MCP config for browser automation
- [x] Non-root user setup (required by Claude Code)
- [x] ffmpeg screen recording with auto-start/stop
- [x] Deployment scripts:
  - `setup.sh` -- full VM provisioning from scratch
  - `start-session.sh` -- launch Xvfb, VNC, noVNC
  - `record.sh` -- start/stop ffmpeg screen capture
  - `play.sh` -- kick off a Claude Code game session
  - `cleanup.sh` -- tear down processes, free resources

---

## Phase 2: Authentication & Login

**Status:** IN PROGRESS | **Effort:** ~1 day | **Dependencies:** Phase 1
**Blocker:** Google OAuth does not work on the VM (headless/automated environment). Must set up email+password login on the Brilliant.org account.

- [~] Set email/password credentials on Brilliant.org account (currently Google-only)
- [ ] Store credentials securely on the VM (env vars or secrets file, not in repo)
- [ ] Implement Playwright persistent browser profile for session reuse
- [ ] Test that login persists across multiple `play.sh` launches
- [ ] Handle session expiry detection and automatic re-login
- [ ] Validate that all game content is accessible after programmatic login

---

## Phase 3: Gameplay Optimization

**Status:** PLANNED | **Effort:** ~3-5 days | **Dependencies:** Phase 2

Once login is reliable, shift focus to making Claude a better player.

- [ ] Audit current CLAUDE.md prompt for gameplay effectiveness
- [ ] Create game-type-specific prompt strategies:
  - [ ] Logic puzzles (deduction, elimination)
  - [ ] Math challenges (algebra, geometry, number theory)
  - [ ] Science problems (physics simulations, chemistry)
- [ ] Add fallback behaviors when a puzzle cannot be solved (skip, retry, hint)
- [ ] Improve error recovery (stale elements, page navigation failures, timeouts)
- [ ] Build a progress tracker:
  - [ ] Log which puzzles were attempted and solved
  - [ ] Track scores and streaks
  - [ ] Generate session summary reports

---

## Phase 4: Recording & Sharing

**Status:** PLANNED | **Effort:** ~2-3 days | **Dependencies:** Phase 1 (recording infra), Phase 3 (interesting gameplay to record)

Turn raw screen recordings into shareable content.

- [ ] Auto-download recordings from VM to local machine (scp/rsync script)
- [ ] Add text overlay / watermark to recordings (ffmpeg filters)
- [ ] Generate thumbnail images from key moments
- [ ] Create highlight clips: trim long sessions to interesting segments
- [ ] Upload pipeline:
  - [ ] YouTube upload via API or CLI
  - [ ] Social media snippets (short-form clips for Twitter/X, etc.)
- [ ] Session metadata file (game type, duration, result) bundled with each recording

---

## Phase 5: Multi-Game Support

**Status:** FUTURE | **Effort:** ~5-7 days | **Dependencies:** Phase 3 (gameplay framework must be flexible)

Expand beyond Brilliant.org to other puzzle and game platforms.

- [.] Chess.com integration
  - Daily puzzles, bot matches
  - Game-specific MCP config for board state reading
- [.] NYT Games (Wordle, Connections, Strands, Spelling Bee)
  - Word-game-specific prompt strategies
- [.] Other puzzle sites (Lichess, Project Euler in-browser, etc.)
- [.] Per-site MCP configuration profiles
- [.] Unified game launcher: `play.sh --site chess.com --game daily-puzzle`
- [.] Site-specific login and session management

---

## Phase 6: Scaling & Reliability

**Status:** FUTURE | **Effort:** ~4-6 days | **Dependencies:** Phases 1-3 stable

Production-grade reliability and multi-instance support.

- [.] Process supervisor (systemd units or PM2) for auto-restart on crash
- [.] Health check endpoint / script (is Xvfb running? is Claude responsive?)
- [.] Alerting: send notification (email, Slack, webhook) on failure
- [.] Multiple concurrent VMs running different games in parallel
- [.] Cost optimization:
  - Spot / preemptible instances
  - Scheduled start/stop (only run during desired hours)
  - Right-size VM specs based on observed resource usage
- [.] Centralized log collection and session history dashboard

---

## Dependency Graph

```
Phase 1 (Infrastructure)
  |
  v
Phase 2 (Authentication)
  |
  v
Phase 3 (Gameplay) --------+
  |                         |
  v                         v
Phase 5 (Multi-Game)    Phase 4 (Recording)
  |
  v
Phase 6 (Scaling)
```

---

## Effort Summary

| Phase | Description              | Status      | Est. Effort  |
|-------|--------------------------|-------------|--------------|
| 1     | Core Infrastructure      | Complete    | ~3 days      |
| 2     | Authentication & Login   | In Progress | ~1 day       |
| 3     | Gameplay Optimization    | Planned     | ~3-5 days    |
| 4     | Recording & Sharing      | Planned     | ~2-3 days    |
| 5     | Multi-Game Support       | Future      | ~5-7 days    |
| 6     | Scaling & Reliability    | Future      | ~4-6 days    |
|       | **Total**                |             | **~18-25 days** |

---

## Next Steps

1. **Immediate:** Set email/password on Brilliant.org account to unblock Phase 2.
2. **This week:** Verify persistent login works end-to-end through `play.sh`.
3. **Then:** Begin Phase 3 prompt tuning with a focus on logic puzzles.
