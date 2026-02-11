# Claude Game Player - Session Summary

## What Was Accomplished

- Created 7 deployment scripts in `vm-setup/`:
  - `setup.sh` - Full VM provisioning (Xvfb, x11vnc, ffmpeg, Node.js 22, Claude Code CLI, Playwright MCP)
  - `start-session.sh` - Launches Xvfb, VNC, noVNC, and starts Claude Code
  - `record.sh` - Screen recording via ffmpeg with auto-stop on Claude exit
  - `play.sh` - Orchestrates the full autonomous gaming session
  - `cleanup.sh` - Tears down display server, VNC, and recording processes
  - `dot-mcp.json` - MCP configuration for Playwright with `--display :99`
  - `CLAUDE.md` - System prompt with game-playing instructions for Claude Code
- Set up DigitalOcean account from scratch (no prior account existed)
- Generated SSH keys (`~/.ssh/id_ed25519`) and installed `doctl` CLI
- Created droplet `claude-player` (`198.199.88.205`, `s-2vcpu-4gb`, Ubuntu 24.04, `nyc1`)
- Deployed and ran `setup.sh` -- fully provisioned VM with all dependencies
- Created non-root `claude` user (Claude Code blocks `--dangerously-skip-permissions` as root)
- Successfully launched Claude Code playing games autonomously with screen recording
- Set up noVNC for browser-based VNC spectating (port 6080)
- Created 8-slide PPTX presentation summarizing the project

## Key Decisions

- **Auto-stop recording** when Claude exits (recommended over manual stop)
- **`@playwright/mcp`** used as the correct MCP package (not the non-existent `@anthropic-ai/mcp-server-playwright`)
- **SSH tunnel for VNC** with localhost-only binding for security
- **Non-root user** approach to work around Claude Code root restriction
- **Playwright persistent context** (`--user-data-dir`) to maintain login sessions across runs

## Issues Encountered and Solutions

| Issue | Solution |
|-------|----------|
| Wrong MCP package name | Fixed to `@playwright/mcp` |
| Root + `--dangerously-skip-permissions` blocked | Created non-root `claude` user |
| `.bashrc` not sourced in non-interactive SSH | Used `.profile` + `tmux -e` env passing |
| Credit balance too low for droplet | User added $10 to DigitalOcean account |
| Chromium cookie encryption via system keyring | Use Playwright's own persistent context directory |
| Google blocks OAuth from automated browser | Need to set password on Brilliant account settings |

## Current Blocker

Brilliant.org login cannot proceed because the user's account is Google-only, and Google blocks OAuth flows from automated/headless browsers on the VM.

**Solution path:** Set a password on the Brilliant.org account via `brilliant.org/settings/account/`, then use email/password login on the VM.

## Infrastructure Details

| Resource | Detail |
|----------|--------|
| Droplet IP | `198.199.88.205` |
| Droplet name | `claude-player` |
| Droplet size | `s-2vcpu-4gb` ($24/mo) |
| Region | `nyc1` |
| OS | Ubuntu 24.04 |

**SSH access:**

```bash
ssh -i ~/.ssh/id_ed25519 claude@198.199.88.205
```

**VNC spectating (tunnel both ports first):**

```bash
ssh -i ~/.ssh/id_ed25519 -L 5900:localhost:5900 -L 6080:localhost:6080 claude@198.199.88.205
```

Then open `http://localhost:6080` in a browser. VNC password: `claude`.

**File locations:**

- Local: `vm-setup/` directory
- Remote: `/home/claude/give-claude-a-computer/`

## Next Steps

1. Set a password on Brilliant.org account (via settings page in a normal browser)
2. Log in through Playwright's browser on VNC using email/password
3. Run `play.sh` for a full autonomous gaming session
4. Download and review recordings from the VM
