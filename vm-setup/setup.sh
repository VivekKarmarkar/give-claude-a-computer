#!/usr/bin/env bash
set -euo pipefail

# One-time provisioning for a fresh Ubuntu 24.04 DigitalOcean droplet.
# Safe to re-run (idempotent). Run as root.

if [[ $EUID -ne 0 ]]; then
  echo "Error: run as root (sudo bash setup.sh)" >&2
  exit 1
fi

PROJECT_DIR="$HOME/give-claude-a-computer"
RECORDINGS_DIR="$PROJECT_DIR/recordings"
DISPLAY_NUM=99
RESOLUTION="1920x1080x24"

echo "==> Updating package lists"
apt-get update -qq

echo "==> Installing system dependencies"
apt-get install -y -qq \
  xvfb x11vnc ffmpeg tmux curl wget git unzip \
  libnss3 libatk-bridge2.0-0 libdrm2 libxcomposite1 \
  libxdamage1 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 \
  libcairo2 libasound2t64 libatspi2.0-0 libcups2 libxkbcommon0 \
  fonts-liberation xfonts-base

echo "==> Installing Node.js 22 LTS"
if ! command -v node &>/dev/null || [[ "$(node -v)" != v22* ]]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt-get install -y -qq nodejs
fi
echo "Node $(node -v), npm $(npm -v)"

echo "==> Installing Claude Code CLI"
npm install -g @anthropic-ai/claude-code

echo "==> Installing Playwright and MCP server"
npm install -g @playwright/mcp
npx playwright install chromium
npx playwright install-deps chromium

echo "==> Creating project directories"
mkdir -p "$RECORDINGS_DIR"

echo "==> Setting up Xvfb systemd service"
cat > /etc/systemd/system/xvfb.service <<EOF
[Unit]
Description=X Virtual Frame Buffer (display :${DISPLAY_NUM})
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/Xvfb :${DISPLAY_NUM} -screen 0 ${RESOLUTION} -ac +extension GLX +render -noreset
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

echo "==> Setting up x11vnc systemd service"
# Create VNC password (default: "claude" — change this!)
mkdir -p ~/.vnc
x11vnc -storepasswd "claude" ~/.vnc/passwd 2>/dev/null || true

cat > /etc/systemd/system/x11vnc.service <<EOF
[Unit]
Description=x11vnc VNC server (display :${DISPLAY_NUM}, localhost only)
After=xvfb.service
Requires=xvfb.service

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -display :${DISPLAY_NUM} -rfbauth $HOME/.vnc/passwd -localhost -forever -shared -rfbport 5900
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

echo "==> Enabling and starting services"
systemctl daemon-reload
systemctl enable --now xvfb.service
systemctl enable --now x11vnc.service

echo "==> Adding 2GB swap (if not present)"
if ! swapon --show | grep -q /swapfile; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo "/swapfile none swap sw 0 0" >> /etc/fstab
  echo "Swap enabled"
else
  echo "Swap already exists, skipping"
fi

echo "==> Configuring UFW firewall (SSH only)"
ufw allow OpenSSH
ufw --force enable

echo "==> Verifying services"
sleep 2
systemctl is-active --quiet xvfb.service && echo "  Xvfb: running" || echo "  Xvfb: FAILED"
systemctl is-active --quiet x11vnc.service && echo "  x11vnc: running" || echo "  x11vnc: FAILED"

echo ""
echo "============================================"
echo "  Setup complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Set your API key:  echo 'export ANTHROPIC_API_KEY=\"sk-ant-...\"' >> ~/.bashrc && source ~/.bashrc"
echo "  2. Change VNC password:  x11vnc -storepasswd ~/.vnc/passwd"
echo "  3. Copy MCP config:  cp $PROJECT_DIR/dot-mcp.json $PROJECT_DIR/.mcp.json"
echo "  4. Start a session:  bash $PROJECT_DIR/start-session.sh"
echo ""
echo "VNC access (from your laptop):"
echo "  ssh -L 5900:localhost:5900 root@<droplet-ip>"
echo "  Then connect VNC client to localhost:5900"
