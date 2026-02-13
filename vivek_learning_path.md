# How Claude Plays Games on a Cloud VM — Learning Path

A personalized crash course covering every concept behind the Claude Game Player project, in the order they stack.

**Estimated time: 2-3 hours total**

---

## 1. What is a Virtual Machine / Cloud Computing?

**The foundation** — understand what it means to rent a computer in the cloud.

- **Watch**: Search YouTube for **"NetworkChuck - you need to learn Virtual Machines RIGHT NOW"** — entertaining and explains VMs from zero
- **Watch**: Search YouTube for **"Fireship - Serverless Computing in 100 Seconds"** — quick context on how cloud services evolved
- **Read**: [Google Cloud: What is a Virtual Machine?](https://cloud.google.com/learn/what-is-a-virtual-machine) — clean, beginner-friendly explainer
- **Read**: [DigitalOcean: Benefits of Virtualization](https://www.digitalocean.com/resources/articles/benefits-of-virtualization) — from the very service we're using

**Key concept**: A virtual machine is a software-based computer running inside a real computer at a data center. You rent it by the hour. Our "droplet" is DigitalOcean's name for a VM — 2 CPUs, 4GB RAM, running Ubuntu in New York City, costing ~$0.036/hour.

**Time**: ~30 minutes

---

## 2. How Linux Displays Work (X Window System)

**The "how does a screen work in software?" question** — this is the magic behind our virtual display.

- **Read**: [X Window System Basics (Magcius/Xplain)](https://magcius.github.io/xplain/article/x-basics.html) — beautifully illustrated, interactive explainer of X11. **This is the single best resource for understanding what we did.**
- **Read**: [Xvfb - Wikipedia](https://en.wikipedia.org/wiki/Xvfb) — short explanation of the virtual framebuffer
- **Read**: [X Window System - Wikipedia](https://en.wikipedia.org/wiki/X_Window_System) — broader context on the protocol

**Key concept**: X11 is a client-server protocol from 1984 (MIT). Programs ("clients") ask the X server to draw things. The server can be a real screen OR virtual memory (Xvfb). That's how our headless VM pretends to have a 1920x1080 monitor — Xvfb allocates a pixel buffer in RAM and programs draw to it as if it were real hardware.

**Time**: ~30 minutes

---

## 3. Terminal Multiplexing (tmux)

**How we run persistent sessions** — tmux keeps things running even when you disconnect SSH.

- **Watch**: Search YouTube for **"NetworkChuck - tmux has forever changed the way I use Linux"**
- **Read**: [A Quick and Easy Guide to tmux](https://hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) — the best beginner tutorial
- **Read**: [Red Hat: A beginner's guide to tmux](https://www.redhat.com/en/blog/introduction-tmux-linux)

**Key concept**: tmux creates sessions that persist on the server. If your SSH connection drops, the programs inside tmux keep running. You can reconnect and reattach. We use it so Claude can keep playing games even if the SSH tunnel disconnects.

**Time**: ~20 minutes

---

## 4. How Video Encoding Works (ffmpeg)

**How pixels become MP4 files** — understanding what ffmpeg does when it records our virtual display.

- **Read**: [Understanding Encoding and FFmpeg: A Beginner's Guide](https://medium.com/media-cloud-tech/understanding-encoding-and-ffmpeg-a-beginners-guide-9750ae6cdf24) — starts from scratch
- **Read**: [Fireship: Programmatic Video Editing with FFmpeg](https://fireship.io/lessons/ffmpeg-useful-techniques/) — practical hands-on techniques
- **Deep dive**: [Digital Video Introduction (GitHub)](https://github.com/leandromoreira/digital_video_introduction) — a beautifully made hands-on guide to how video actually works (codecs, compression, frames). Highly recommended if you want to truly understand video.

**Key concept**: ffmpeg grabs raw pixels from display :99 at 30 frames per second, compresses them with H.264 (libx264), and writes an MP4 container. That's why we send SIGINT (not SIGTERM) to stop recording — H.264 needs to finalize the "moov atom" (a file index) at the end, and SIGINT triggers a graceful shutdown that writes it.

**Time**: ~30-45 minutes

---

## 5. How VNC Works (Live Spectating)

**The live spectating piece** — how you can watch the virtual display from your laptop in real-time.

- **Read**: [x11vnc on GitHub](https://github.com/LibVNC/x11vnc) — the tool that shares display :99 over the network

**Key concept**: VNC (Virtual Network Computing) reads a display's pixel buffer, compresses it, and streams it to a viewer over the network. It's like a low-latency video call to a computer screen. x11vnc connects to our Xvfb display and shares it on port 5900. noVNC adds a web layer so you can view it in a regular browser at localhost:6080 instead of needing a dedicated VNC client.

**Time**: ~15 minutes

---

## How It All Connects

Here's the full stack of our project, bottom to top:

```
Your Laptop (physical screen + eyes)
    ↑ plays MP4 file
Downloaded Video (phet-split-commentary-test.mp4)
    ↑ scp download
DigitalOcean VM (198.199.88.205)
    ├── ffmpeg ──────── reads pixels from display :99, writes MP4
    ├── x11vnc ─────── shares display :99 over network (live view)
    ├── openbox ────── window manager positions windows on display :99
    ├── xterm ─────── terminal showing Claude's commentary on left half
    ├── Chromium ──── browser showing PhET sim on right half
    ├── Playwright ── controls Chromium via CDP protocol
    ├── Claude CLI ── AI reasoning + tool calls
    └── Xvfb ──────── virtual display :99 (1920x1080 pixels in RAM)
        (no physical monitor — it's all memory)
```

After completing this learning path, you'll understand every layer from the data center hardware to the video file on your laptop.

---

## Sources

- [Xplain: X Window System Basics](https://magcius.github.io/xplain/article/x-basics.html)
- [Google Cloud: What is a VM?](https://cloud.google.com/learn/what-is-a-virtual-machine)
- [DigitalOcean: Virtualization Benefits](https://www.digitalocean.com/resources/articles/benefits-of-virtualization)
- [Xvfb - Wikipedia](https://en.wikipedia.org/wiki/Xvfb)
- [X Window System - Wikipedia](https://en.wikipedia.org/wiki/X_Window_System)
- [Quick Guide to tmux](https://hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)
- [Red Hat: tmux guide](https://www.redhat.com/en/blog/introduction-tmux-linux)
- [FFmpeg Beginner's Guide](https://medium.com/media-cloud-tech/understanding-encoding-and-ffmpeg-a-beginners-guide-9750ae6cdf24)
- [Fireship: FFmpeg Techniques](https://fireship.io/lessons/ffmpeg-useful-techniques/)
- [Digital Video Introduction](https://github.com/leandromoreira/digital_video_introduction)
- [x11vnc](https://github.com/LibVNC/x11vnc)
