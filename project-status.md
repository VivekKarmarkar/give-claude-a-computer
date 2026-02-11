# Claude Game Player -- Project Status Report

**Date:** 2026-02-10
**Project:** Claude Game Player
**Lead:** Vivek Karmarkar
**Status:** AMBER (blocked on authentication)

---

## Project Overview

Claude Game Player is a DigitalOcean VM setup that enables Claude Code to autonomously play Brilliant.org games with full screen recording and live VNC spectating. The system runs a headed Chromium browser on a virtual display, controlled by Claude Code via the Playwright MCP server, with ffmpeg capturing gameplay footage.

---

## Overall Status

| Indicator | Status |
|-----------|--------|
| Infrastructure | GREEN -- all services running |
| Tooling | GREEN -- scripts and MCP operational |
| Authentication | RED -- blocked on Brilliant.org login |
| **Overall** | **AMBER** |

---

## Infrastructure Status

| Component | Status | Details |
|-----------|--------|---------|
| DigitalOcean Droplet | Running | `198.199.88.205`, `s-2vcpu-4gb`, Ubuntu 24.04, `nyc1` |
| Xvfb (display :99) | Running | systemd service, 1920x1080 virtual framebuffer |
| x11vnc | Running | systemd service, localhost:5900, secured via SSH tunnel |
| noVNC | Running | Port 6080, browser-based VNC viewer |
| ffmpeg recording | Working | Auto-start/stop with `play.sh`, SIGINT graceful stop |
| Claude Code CLI | Working | Non-root `claude` user, Anthropic API key configured |
| Playwright MCP | Working | `@playwright/mcp` with persistent browser profile |
| Chromium | Working | Headed browser rendering on display :99 |

---

## Blockers

| # | Blocker | Impact | Resolution Path |
|---|---------|--------|-----------------|
| 1 | Brilliant.org login -- user account is Google-only; Google blocks OAuth from automated browsers on the VM | Cannot start gameplay sessions | Set an email/password on Brilliant.org via account settings (`brilliant.org/settings/account/`), then use direct login on the VM |

---

## Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|------------|--------|------------|
| 1 | Anthropic API credit depletion | Medium | Sessions halt | Monitor usage; current balance is $10 |
| 2 | VM cost accumulation | Low | $24/mo ongoing even when idle | Destroy droplet when not in use |
| 3 | Brilliant.org bot detection | Medium | Account blocked or interactions fail | Use persistent browser profile; human-like timing in Claude prompts |

---

## Files Created

### vm-setup/ (7 files)

| File | Purpose |
|------|---------|
| `setup.sh` | Full VM provisioning (Xvfb, x11vnc, ffmpeg, Node.js 22, Claude Code CLI, Playwright MCP) |
| `start-session.sh` | Launches Xvfb, VNC, noVNC, and starts Claude Code |
| `play.sh` | Orchestrates a full autonomous gaming session |
| `record.sh` | Screen recording via ffmpeg with auto-stop on Claude exit |
| `cleanup.sh` | Tears down display server, VNC, and recording processes |
| `dot-mcp.json` | MCP configuration for Playwright with `--display :99` |
| `CLAUDE.md` | System prompt with game-playing instructions for Claude Code |

### Supporting Files

| File | Purpose |
|------|---------|
| `claude-game-player-deck.pptx` | 8-slide presentation summarizing the project |
| `session-summary.md` | Detailed session notes, decisions, and issues log |

---

## Issues Resolved

| # | Issue | Resolution |
|---|-------|------------|
| 1 | Wrong MCP package name referenced | Corrected to `@playwright/mcp` |
| 2 | Root user + `--dangerously-skip-permissions` blocked by Claude Code | Created non-root `claude` user |
| 3 | `.bashrc` not sourced in non-interactive SSH sessions | Used `.profile` + `tmux -e` environment passing |
| 4 | DigitalOcean credit balance too low for droplet creation | Added $10 to account |
| 5 | Chromium cookie encryption via system keyring | Use Playwright's own persistent context directory |
| 6 | Google blocks OAuth from automated browser | Identified workaround: set password on Brilliant account settings |

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Setup time (zero to working VM) | ~2 hours |
| VM monthly cost | $24 |
| Scripts created | 7 |
| Issues resolved | 6 |
| Remaining blockers | 1 |

---

## Next Steps

1. Set an email/password on the Brilliant.org account (via settings page in a normal browser)
2. Log in through Playwright's browser on VNC using email/password credentials
3. Run `play.sh` for a full autonomous gaming session
4. Download and review screen recordings from the VM

---

## Access Quick Reference

**SSH:**
```bash
ssh -i ~/.ssh/id_ed25519 claude@198.199.88.205
```

**VNC spectating (tunnel both ports):**
```bash
ssh -i ~/.ssh/id_ed25519 -L 5900:localhost:5900 -L 6080:localhost:6080 claude@198.199.88.205
```
Then open `http://localhost:6080` in a browser. VNC password: `claude`.
