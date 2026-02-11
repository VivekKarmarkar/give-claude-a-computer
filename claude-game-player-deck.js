const pptxgen = require("pptxgenjs");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "Vivek Karmarkar";
pres.title = "Claude Game Player — Cloud VM Architecture";

// Color palette: Ocean Gradient (deep blue + teal)
const C = {
  navy: "0B1D3A",
  deepBlue: "065A82",
  teal: "1C7293",
  mint: "48B8A0",
  light: "E8F4F8",
  white: "FFFFFF",
  offWhite: "F5F9FB",
  darkText: "1A1A2E",
  mutedText: "5A6B7B",
  coral: "E8605C",
  gold: "F0A830",
};

const makeShadow = () => ({ type: "outer", blur: 6, offset: 2, angle: 135, color: "000000", opacity: 0.12 });

// ===== SLIDE 1: Title =====
{
  const s = pres.addSlide();
  s.background = { color: C.navy };
  // Accent shape
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.12, h: 5.625, fill: { color: C.mint } });
  // Title
  s.addText("Claude Game Player", {
    x: 0.8, y: 1.0, w: 8.5, h: 1.2,
    fontSize: 44, fontFace: "Georgia", bold: true, color: C.white, margin: 0,
  });
  // Subtitle
  s.addText("Autonomous Game Playing on a Cloud VM", {
    x: 0.8, y: 2.2, w: 8.5, h: 0.7,
    fontSize: 22, fontFace: "Calibri", color: C.mint, margin: 0,
  });
  // Description
  s.addText("Claude Code + Playwright MCP + DigitalOcean + ffmpeg Recording", {
    x: 0.8, y: 3.3, w: 8.5, h: 0.5,
    fontSize: 14, fontFace: "Calibri", color: C.light, margin: 0,
  });
  // Bottom bar
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 5.125, w: 10, h: 0.5, fill: { color: C.deepBlue } });
  s.addText("February 2026", {
    x: 0.8, y: 5.125, w: 8.5, h: 0.5,
    fontSize: 11, fontFace: "Calibri", color: C.teal, align: "right", margin: 0,
  });
}

// ===== SLIDE 2: The Problem =====
{
  const s = pres.addSlide();
  s.background = { color: C.offWhite };
  s.addText("Why a Cloud VM?", {
    x: 0.7, y: 0.4, w: 8.5, h: 0.7,
    fontSize: 32, fontFace: "Georgia", bold: true, color: C.navy, margin: 0,
  });
  // (removed accent line under title)

  // Left column - problem
  s.addShape(pres.shapes.RECTANGLE, { x: 0.7, y: 1.5, w: 4.1, h: 3.5, fill: { color: C.white }, shadow: makeShadow() });
  s.addShape(pres.shapes.RECTANGLE, { x: 0.7, y: 1.5, w: 4.1, h: 0.5, fill: { color: C.coral } });
  s.addText("The Problem", { x: 0.7, y: 1.5, w: 4.1, h: 0.5, fontSize: 14, fontFace: "Calibri", bold: true, color: C.white, align: "center" });
  s.addText([
    { text: "claude --remote has no display", options: { bullet: true, breakLine: true, fontSize: 13 } },
    { text: "Can't run headed browsers", options: { bullet: true, breakLine: true, fontSize: 13 } },
    { text: "No screen recording capability", options: { bullet: true, breakLine: true, fontSize: 13 } },
    { text: "Ties up your local machine", options: { bullet: true, fontSize: 13 } },
  ], { x: 1.0, y: 2.2, w: 3.5, h: 2.5, fontFace: "Calibri", color: C.darkText, paraSpaceAfter: 8 });

  // Right column - solution
  s.addShape(pres.shapes.RECTANGLE, { x: 5.2, y: 1.5, w: 4.1, h: 3.5, fill: { color: C.white }, shadow: makeShadow() });
  s.addShape(pres.shapes.RECTANGLE, { x: 5.2, y: 1.5, w: 4.1, h: 0.5, fill: { color: C.mint } });
  s.addText("The Solution", { x: 5.2, y: 1.5, w: 4.1, h: 0.5, fontSize: 14, fontFace: "Calibri", bold: true, color: C.white, align: "center" });
  s.addText([
    { text: "Disposable $24/mo DigitalOcean VM", options: { bullet: true, breakLine: true, fontSize: 13 } },
    { text: "Virtual display (Xvfb) + headed browser", options: { bullet: true, breakLine: true, fontSize: 13 } },
    { text: "ffmpeg records everything", options: { bullet: true, breakLine: true, fontSize: 13 } },
    { text: "VNC for live spectating", options: { bullet: true, fontSize: 13 } },
  ], { x: 5.5, y: 2.2, w: 3.5, h: 2.5, fontFace: "Calibri", color: C.darkText, paraSpaceAfter: 8 });
}

// ===== SLIDE 3: Architecture =====
{
  const s = pres.addSlide();
  s.background = { color: C.offWhite };
  s.addText("Architecture", {
    x: 0.7, y: 0.4, w: 8.5, h: 0.7,
    fontSize: 32, fontFace: "Georgia", bold: true, color: C.navy, margin: 0,
  });
  // (removed accent line under title)

  // Droplet box
  s.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: 1.5, w: 9.0, h: 3.8, fill: { color: C.white }, shadow: makeShadow() });
  s.addText("DigitalOcean Droplet (Ubuntu 24.04, s-2vcpu-4gb)", {
    x: 0.8, y: 1.6, w: 8.5, h: 0.4,
    fontSize: 13, fontFace: "Consolas", bold: true, color: C.deepBlue, margin: 0,
  });

  // Component boxes inside
  const components = [
    { name: "Xvfb", desc: "Virtual Display :99", x: 0.8, color: C.deepBlue },
    { name: "x11vnc", desc: "VNC Server", x: 2.45, color: C.teal },
    { name: "Chromium", desc: "Headed Browser", x: 4.1, color: C.mint },
    { name: "ffmpeg", desc: "Screen Recorder", x: 5.75, color: C.gold },
    { name: "Claude CLI", desc: "AI Agent", x: 7.4, color: C.coral },
  ];

  components.forEach((c) => {
    s.addShape(pres.shapes.RECTANGLE, { x: c.x, y: 2.2, w: 1.5, h: 1.0, fill: { color: c.color } });
    s.addText(c.name, { x: c.x, y: 2.2, w: 1.5, h: 0.55, fontSize: 12, fontFace: "Calibri", bold: true, color: C.white, align: "center", valign: "bottom", margin: 0 });
    s.addText(c.desc, { x: c.x, y: 2.7, w: 1.5, h: 0.5, fontSize: 9, fontFace: "Calibri", color: C.white, align: "center", valign: "top", margin: 0 });
  });

  // Connection flow
  s.addText("Playwright MCP controls Chromium on display :99  |  ffmpeg captures display :99  |  x11vnc shares display :99", {
    x: 0.8, y: 3.5, w: 8.5, h: 0.4,
    fontSize: 10, fontFace: "Calibri", italic: true, color: C.mutedText, align: "center", margin: 0,
  });

  // Your laptop box
  s.addShape(pres.shapes.RECTANGLE, { x: 0.8, y: 4.1, w: 3.5, h: 0.9, fill: { color: C.light } });
  s.addText("Your Laptop: SSH tunnel + VNC + tmux attach", {
    x: 0.8, y: 4.1, w: 3.5, h: 0.9,
    fontSize: 11, fontFace: "Calibri", color: C.deepBlue, align: "center", valign: "middle", margin: 0,
  });
  s.addShape(pres.shapes.RECTANGLE, { x: 5.3, y: 4.1, w: 3.5, h: 0.9, fill: { color: C.light } });
  s.addText("tmux: Persistent sessions survive SSH disconnect", {
    x: 5.3, y: 4.1, w: 3.5, h: 0.9,
    fontSize: 11, fontFace: "Calibri", color: C.deepBlue, align: "center", valign: "middle", margin: 0,
  });
}

// ===== SLIDE 4: Scripts Created =====
{
  const s = pres.addSlide();
  s.background = { color: C.offWhite };
  s.addText("Deployment Scripts", {
    x: 0.7, y: 0.4, w: 8.5, h: 0.7,
    fontSize: 32, fontFace: "Georgia", bold: true, color: C.navy, margin: 0,
  });
  // (removed accent line under title)

  const scripts = [
    ["setup.sh", "One-time VM provisioning (Node, Chromium, systemd, swap, firewall)"],
    ["start-session.sh", "Starts Xvfb + VNC, creates tmux session with DISPLAY=:99"],
    ["record.sh", "ffmpeg controller: start / stop (SIGINT) / status with PID tracking"],
    ["play.sh", "Launches Claude in tmux, auto-starts/stops recording per session"],
    ["cleanup.sh", "Deletes recordings older than N days (default 7)"],
    ["dot-mcp.json", "Playwright MCP config (@playwright/mcp + persistent profile)"],
    ["CLAUDE.md", "System prompt for game playing with Playwright tools"],
  ];

  scripts.forEach((item, i) => {
    const y = 1.4 + i * 0.55;
    s.addShape(pres.shapes.RECTANGLE, { x: 0.7, y, w: 8.6, h: 0.48, fill: { color: i % 2 === 0 ? C.white : C.light } });
    s.addText(item[0], { x: 0.9, y, w: 2.0, h: 0.48, fontSize: 12, fontFace: "Consolas", bold: true, color: C.deepBlue, valign: "middle", margin: 0 });
    s.addText(item[1], { x: 3.0, y, w: 6.1, h: 0.48, fontSize: 11, fontFace: "Calibri", color: C.darkText, valign: "middle", margin: 0 });
  });
}

// ===== SLIDE 5: Deployment Workflow =====
{
  const s = pres.addSlide();
  s.background = { color: C.offWhite };
  s.addText("Deployment Workflow", {
    x: 0.7, y: 0.4, w: 8.5, h: 0.7,
    fontSize: 32, fontFace: "Georgia", bold: true, color: C.navy, margin: 0,
  });
  // (removed accent line under title)

  const steps = [
    { num: "1", title: "Create Droplet", desc: "doctl + Ubuntu 24.04 + SSH key" },
    { num: "2", title: "Upload & Setup", desc: "scp files, run setup.sh (~5 min)" },
    { num: "3", title: "Configure", desc: "API key + MCP config + VNC login" },
    { num: "4", title: "Play!", desc: "play.sh launches Claude + recording" },
  ];

  steps.forEach((step, i) => {
    const x = 0.5 + i * 2.35;
    // Number circle
    s.addShape(pres.shapes.OVAL, { x: x + 0.55, y: 1.5, w: 0.7, h: 0.7, fill: { color: C.deepBlue } });
    s.addText(step.num, { x: x + 0.55, y: 1.5, w: 0.7, h: 0.7, fontSize: 22, fontFace: "Georgia", bold: true, color: C.white, align: "center", valign: "middle", margin: 0 });
    // Card
    s.addShape(pres.shapes.RECTANGLE, { x, y: 2.5, w: 2.1, h: 1.5, fill: { color: C.white }, shadow: makeShadow() });
    s.addText(step.title, { x, y: 2.6, w: 2.1, h: 0.5, fontSize: 14, fontFace: "Calibri", bold: true, color: C.navy, align: "center", margin: 0 });
    s.addText(step.desc, { x, y: 3.1, w: 2.1, h: 0.7, fontSize: 11, fontFace: "Calibri", color: C.mutedText, align: "center", margin: 0 });
  });

  // Bottom command example
  s.addShape(pres.shapes.RECTANGLE, { x: 0.7, y: 4.3, w: 8.6, h: 0.9, fill: { color: C.navy } });
  s.addText('$ play.sh "Go to brilliant.org and play the logic course"', {
    x: 1.0, y: 4.3, w: 8.0, h: 0.9,
    fontSize: 13, fontFace: "Consolas", color: C.mint, valign: "middle", margin: 0,
  });
}

// ===== SLIDE 6: Issues Encountered =====
{
  const s = pres.addSlide();
  s.background = { color: C.offWhite };
  s.addText("Issues & Solutions", {
    x: 0.7, y: 0.4, w: 8.5, h: 0.7,
    fontSize: 32, fontFace: "Georgia", bold: true, color: C.navy, margin: 0,
  });
  // (removed accent line under title)

  const issues = [
    { issue: "Root + skip-permissions blocked", solution: "Created non-root 'claude' user with limited sudoers", color: C.coral },
    { issue: "Cookies encrypted by system keyring", solution: "Use Playwright's own persistent profile (--user-data-dir)", color: C.gold },
    { issue: "Google blocks OAuth on VM browser", solution: "Set email/password on Brilliant account settings", color: C.deepBlue },
  ];

  issues.forEach((item, i) => {
    const y = 1.5 + i * 1.3;
    // Issue card
    s.addShape(pres.shapes.RECTANGLE, { x: 0.7, y, w: 8.6, h: 1.1, fill: { color: C.white }, shadow: makeShadow() });
    s.addShape(pres.shapes.RECTANGLE, { x: 0.7, y, w: 0.1, h: 1.1, fill: { color: item.color } });
    s.addText(item.issue, { x: 1.1, y, w: 3.5, h: 1.1, fontSize: 13, fontFace: "Calibri", bold: true, color: C.darkText, valign: "middle", margin: 0 });
    s.addText(item.solution, { x: 5.0, y, w: 4.0, h: 1.1, fontSize: 12, fontFace: "Calibri", color: C.darkText, valign: "middle", margin: 0 });
  });
}

// ===== SLIDE 7: Current Status =====
{
  const s = pres.addSlide();
  s.background = { color: C.offWhite };
  s.addText("Current Status", {
    x: 0.7, y: 0.4, w: 8.5, h: 0.7,
    fontSize: 32, fontFace: "Georgia", bold: true, color: C.navy, margin: 0,
  });
  // (removed accent line under title)

  // Status items
  const statuses = [
    { label: "VM Provisioned", status: "DONE", color: C.mint },
    { label: "Xvfb + x11vnc", status: "RUNNING", color: C.mint },
    { label: "ffmpeg Recording", status: "WORKING", color: C.mint },
    { label: "Claude Plays Games", status: "WORKING", color: C.mint },
    { label: "Brilliant Login", status: "IN PROGRESS", color: C.gold },
  ];

  statuses.forEach((item, i) => {
    const y = 1.5 + i * 0.6;
    s.addShape(pres.shapes.RECTANGLE, { x: 0.7, y, w: 5.5, h: 0.5, fill: { color: C.white }, shadow: makeShadow() });
    s.addText(item.label, { x: 1.0, y, w: 3.5, h: 0.5, fontSize: 13, fontFace: "Calibri", color: C.darkText, valign: "middle", margin: 0 });
    s.addShape(pres.shapes.RECTANGLE, { x: 4.8, y: y + 0.12, w: 1.2, h: 0.26, fill: { color: item.color } });
    s.addText(item.status, { x: 4.8, y: y + 0.12, w: 1.2, h: 0.26, fontSize: 9, fontFace: "Calibri", bold: true, color: C.white, align: "center", valign: "middle", margin: 0 });
  });

  // Next steps
  s.addText("Next Steps", {
    x: 6.8, y: 1.5, w: 2.7, h: 0.5,
    fontSize: 16, fontFace: "Calibri", bold: true, color: C.navy, margin: 0,
  });
  s.addText([
    { text: "Set password on Brilliant account", options: { bullet: true, breakLine: true, fontSize: 12 } },
    { text: "Login via Playwright's browser on VNC", options: { bullet: true, breakLine: true, fontSize: 12 } },
    { text: "Run play.sh for full autonomous session", options: { bullet: true, breakLine: true, fontSize: 12 } },
    { text: "Download and review recordings", options: { bullet: true, fontSize: 12 } },
  ], { x: 6.8, y: 2.0, w: 2.8, h: 2.5, fontFace: "Calibri", color: C.mutedText, paraSpaceAfter: 6 });
}

// ===== SLIDE 8: Closing =====
{
  const s = pres.addSlide();
  s.background = { color: C.navy };
  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 0.12, h: 5.625, fill: { color: C.mint } });

  s.addText("Ready to Play", {
    x: 0.8, y: 1.5, w: 8.5, h: 1.0,
    fontSize: 40, fontFace: "Georgia", bold: true, color: C.white, margin: 0,
  });

  s.addText("198.199.88.205", {
    x: 0.8, y: 2.6, w: 8.5, h: 0.7,
    fontSize: 28, fontFace: "Consolas", color: C.mint, margin: 0,
  });

  s.addText([
    { text: 'SSH:  ssh -i ~/.ssh/id_ed25519 claude@198.199.88.205', options: { breakLine: true, fontSize: 12 } },
    { text: "VNC:  localhost:6080 via SSH tunnel", options: { breakLine: true, fontSize: 12 } },
    { text: 'Play: bash play.sh "Go play logic puzzles"', options: { fontSize: 12 } },
  ], { x: 0.8, y: 3.5, w: 8.5, h: 1.5, fontFace: "Consolas", color: C.light, paraSpaceAfter: 8 });

  s.addShape(pres.shapes.RECTANGLE, { x: 0, y: 5.125, w: 10, h: 0.5, fill: { color: C.deepBlue } });
}

const outputPath = "/home/vivekkarmarkar/Python Files/give-claude-a-computer/claude-game-player-deck.pptx";
pres.writeFile({ fileName: outputPath }).then(() => {
  console.log("Presentation saved to: " + outputPath);
});
