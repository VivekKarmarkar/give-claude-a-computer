# Future Vision: AI Agent Classroom for Educational Software Evaluation

## The Core Idea

Use autonomous AI agents with different personalities to simulate a classroom of students interacting with educational software. This serves a dual purpose:

1. **Evaluate educational software UX** — If an AI agent can navigate your tool, your interaction design is solid
2. **Simulate diverse learning experiences** — Different agent personalities reveal different UX strengths and weaknesses

## What We've Learned So Far

### PhET and Brilliant Win on Design
- Claude navigated PhET simulations and Brilliant.org games effectively
- Clear buttons, labeled sliders, step-by-step progression, immediate visual feedback
- Brilliant's engagement loop was so effective Claude burned through 25K XP in 2 days (and got banned)

### Custom Sims Struggle
- Custom physics sims (Feynman conservation, Earnshaw's theorem) were hard for Claude
- Drag-and-drop interactions are particularly problematic
- Unlabeled or non-standard UI elements confuse the agent
- The Polarity Shift game (from PhET lead dev, Universe and More) also struggled — showing it's specifically PhET/Brilliant's design patterns that work

### Claude as a "B-Minus Student"
- Gets the concepts roughly right but makes entertaining mistakes
- Hallucinated thermal energy when friction wasn't even toggled on
- Confidently narrated physics that wasn't happening on screen
- Got correct but suboptimal answers on math (sequence convergence)
- Strong conceptual knowledge, weak at verifying actual screen state vs expectations

## Multi-Agent Classroom Vision

### Agent Personalities
Spin up multiple VMs, each running a Claude agent with a distinct student personality:

- **The Confident Student** — Moves fast, makes bold guesses, rarely re-reads instructions
- **The Cautious Student** — Reads everything twice, hesitates before interacting, asks "am I sure?"
- **The Curious Explorer** — Tries every widget, goes off-path, explores edge cases
- **The Struggling Student** — Gets confused easily, needs clear affordances, gives up after 2-3 attempts
- **The Speed Runner** — Tries to complete tasks as fast as possible, skips explanations

### Infrastructure
- 5 DigitalOcean droplets ($24/mo each = $120/mo for the fleet)
- Each with Xvfb + Playwright + Claude Code + ffmpeg recording
- Same `play-split.sh` pipeline per VM
- Central orchestrator to launch sessions simultaneously
- Post-session analysis: compare commentary, navigation paths, errors, time spent

### Data Collection
Each agent produces:
- **Recording** (mp4 with lo-fi music) — visual evidence of the experience
- **Commentary** (text) — narrated understanding and reasoning
- **Navigation path** — sequence of pages/widgets visited
- **Error log** — where the agent got stuck or confused
- **Time-on-task** — how long each section took

### Analysis Outputs
- **UX Friction Map** — overlay agent struggles onto the software's UI to identify problem areas
- **Accessibility Score** — if N out of 5 agents can complete a task, that's the accessibility rating
- **Engagement Index** — how much time agents voluntarily spend exploring vs trying to escape
- **Comprehension Check** — compare agent narration to actual correct answers

## Key Insight: Browser Extension vs Screenshots

Previous attempts used screenshots described to sub-agents — a lossy translation layer. Direct browser control via Playwright MCP gives agents the authentic user experience: clicking, scrolling, reading DOM elements. This is fundamentally different and more valid as a testing methodology.

## Who This Is For

- **EdTech companies** — automated UX testing of educational software
- **Learning designers** — understand how different "student types" interact with content
- **Accessibility researchers** — novel approach to testing interaction design quality
- **AI researchers** — studying how LLMs interact with visual/interactive environments

## Strategic Positioning

### Novel Framing: Educational Sims as AI Benchmarks

**The insight**: If PhET simulations were gamified with "correct and optimal answers," the Claude Game Player system naturally becomes a novel AI benchmark category.

#### Why This Is Groundbreaking

Existing AI benchmarks focus on text and code:
- **Code**: HumanEval, MBPP (write functions from docstrings)
- **Math**: MATH, GSM8K (solve word problems)
- **Reasoning**: ARC, BIG-Bench (logical puzzles)
- **Knowledge**: MMLU, TriviaQA (question answering)

**What's missing**: Interactive spatial reasoning, UI interaction, learning from visual feedback, physical intuition, embodied problem-solving.

Educational simulations fill this gap. They test capabilities that text-based benchmarks cannot:
- **Spatial reasoning** — understanding 2D/3D transformations, trajectories, forces
- **UI interaction** — navigating complex interfaces, finding relevant controls
- **Learning from feedback** — adjusting strategy based on visual/interactive results
- **Physical intuition** — predicting system behavior (gravity, energy, motion)
- **Multi-step problem solving** — planning and executing sequences of actions
- **Error recovery** — recognizing failures and trying alternative approaches

#### Benchmark Dimensions

Unlike pass/fail text benchmarks, educational sim benchmarks are multi-dimensional:

| Dimension | Measurement | What It Tests |
|-----------|-------------|---------------|
| **Completion Rate** | Did the agent solve the puzzle? | Basic capability |
| **Time to Solution** | How long did it take? | Efficiency and intuition |
| **Exploration Quality** | Did it try all features? | Thoroughness and curiosity |
| **Error Recovery** | How did it handle failed attempts? | Adaptability and learning |
| **Conceptual Understanding** | Commentary analysis vs. correct answers | True comprehension vs. trial-and-error |
| **Interaction Efficiency** | Number of clicks/actions per solve | Strategic thinking |

This produces a **profile** of AI capability, not a single score. Different models might excel at different dimensions.

#### Cross-Model Comparison

The same educational sim can be played by:
- Claude (all versions: Haiku, Sonnet, Opus)
- GPT-4, GPT-4o, o1, o3
- Gemini (all versions)
- Open-source models (Llama, Qwen, DeepSeek)

**Research questions**:
- Which models have better spatial reasoning?
- Which learn faster from interactive feedback?
- Which models are more efficient (fewer actions to solution)?
- How do reasoning models (o1, o3) compare to standard models on physics sims?

#### Scalability Across Difficulty

PhET has **160+ simulations** across:
- Elementary school (counting, colors, shapes)
- Middle school (basic physics, fractions)
- High school (mechanics, circuits, chemistry)
- Undergraduate (quantum mechanics, calculus)
- Graduate level (advanced physics concepts)

This provides a **curriculum of increasing difficulty** — like how MMLU spans topics from elementary to professional level. AI models can be benchmarked across the full spectrum.

#### Standardization and Reproducibility

For a benchmark to be valuable, it must be:
1. **Reproducible** — same sim, same starting conditions, comparable results
2. **Versioned** — PhET sims have stable versions
3. **Publicly accessible** — PhET is open-source and free
4. **Measurable** — clear success criteria (correct answers, completion, scores)
5. **Representative** — correlates with real-world capabilities (using interactive software)

The Claude Game Player pipeline already satisfies most of these. Adding gamification (scoring, optimal solutions) completes the picture.

#### Target Audiences Expanded

This framing opens up entirely new audiences beyond education companies:

**AI Labs** (Anthropic, OpenAI, Google DeepMind):
- Novel benchmark to add to their model cards
- Tests capabilities not covered by text benchmarks
- Competitive differentiation: "Our model is best at interactive reasoning"

**AI Research Community** (NeurIPS, ICLR, ICML):
- New benchmark category for papers
- Research on embodied reasoning, spatial intelligence
- Comparison studies across model families

**NSF Grants** (CS + Education):
- "Developing standardized benchmarks for AI spatial reasoning using educational simulations"
- "Evaluating AI model capabilities on interactive STEM learning tasks"
- More fundable than "building games" or even "validating games"

**AI Benchmarking Platforms** (Papers with Code, HuggingFace):
- Add "Interactive Educational Sims" as a new benchmark category
- Leaderboards comparing models on PhET tasks

#### Strategic Implications

This reframing changes **everything**:

**Before**: "I built a system to validate my educational games"
- Audience: Education companies
- Pitch: "Hire me to improve UX"
- Competition: Other educators, UX researchers

**After**: "I built a novel AI benchmark category using interactive educational simulations"
- Audience: AI labs, research community, NSF
- Pitch: "Here's a new way to evaluate AI capabilities that existing benchmarks miss"
- Competition: None — genuinely first in this space

**The key**: PhET already exists. The sims already have "correct" physics. The pipeline already works. The only addition needed is **gamification scoring** (which many PhET sims already partially have — "is the circuit complete?", "did the ball reach the target?").

#### Positioning Statement

*"Educational simulations represent an untapped category of AI benchmarks, testing spatial reasoning, UI interaction, and learning from feedback — capabilities poorly covered by text and code benchmarks. By gamifying PhET's 160+ open-source simulations and applying autonomous AI agents, we've created a scalable, reproducible benchmark suite that evaluates how AI models learn and solve interactive STEM problems."*

This isn't just UX validation. **This is AI capability evaluation.**

### Part of a Larger Ecosystem
This project isn't a standalone side project — it's the validation layer for an existing portfolio of 80+ interactive educational simulations. The arc:

1. **Exploration phase**: Built ~80 sims across physics, math, and ML using rapid prototyping tools (Cove, Lovable, Claude Artifacts, GPT Canvas)
2. **Curation phase**: Selected the best sims for a polished portfolio website
3. **Production phase**: Refined top sims with Claude Code for real polish
4. **Validation phase**: Built this AI agent system to evaluate UX quality — both on own sims and on industry leaders (PhET, Brilliant)

### Website Integration
On the interactive sims page, add a section: "Novel Validation with AI Agents" — a button that opens the architectural diagram, description, YouTube embeds of lo-fi recordings, and methodology overview. This positions the validation work as part of the sims ecosystem, not a separate project.

### Resume Positioning
- "Built 80+ interactive educational simulations across physics, math, and ML using rapid prototyping tools. Curated the best into a polished portfolio."
- "Developed a novel AI-agent-based validation methodology to evaluate educational UX quality, comparing PhET, Brilliant.org, and custom-built simulations."
- The tool progression (Cove → Lovable → Claude Code) answers "how do you approach building?" — low-fidelity for exploration, high-fidelity for production.

### The Origin Story (for pitches and Medium article)
1. Built interactive physics/math sims. Knew the Feynman game had UI issues but couldn't quantify them.
2. Asked Claude Code to play the Feynman game → Claude **cheated** by reading the source code.
3. Sent Claude to Brilliant.org where it can't see source code → Claude got **addicted**, 25K XP in 2 days.
4. Brilliant **banned the account** for bot activity.
5. Pivoted to a full VM-based system with Playwright MCP for authentic browser interaction.
6. The AI agent data now **confirms** what was a feeling: Brilliant/PhET have superior UX affordances and scaffolding. Custom sims have specific, measurable friction points.

### The Critical Framing Shift: Feeling → Finding
- **Before**: "I feel my UI might have issues" — apologetic, uncertain, inviting criticism
- **After**: "My AI agent validation system identified specific UX friction points in scaffolding and interactive element design" — confident, data-driven, action-oriented
- The shift from **feeling inferior** to **having data** changes the entire outreach dynamic
- Not just identifying problems but having the **tool to iteratively fix them**: improve sim → re-run agent → measure improvement
- This is a **continuous improvement loop**, which is what product teams care about

### Brilliant.org Pitch
"I built interactive educational sims. I also built an AI-based validation system. My system confirmed your games have superior UX — specifically in affordances and scaffolding. I have the data and the methodology to close the gap. Here's my portfolio, here's the validation system, and here's how I'd apply this thinking at Brilliant."

### Differentiation
- Very few people build interactive educational sims
- Among those who do, virtually nobody has built an AI agent validation system for them
- The combination of builder + validator + data-driven improvement loop is unique

## Key Validation Findings (Feb 2026)

### Feynman Conservation: Coached Approach Results
- Coached prompt (think more, click less, reason backwards) significantly improved performance
- Claude got much further (found 8/28 blocks, understood game structure) vs first attempt (stuck at door)
- Still struggled with drag-and-drop and scale interactions
- **Key observation**: Claude was "scared" of drag-and-drop — avoided it, stayed on the defensive

### Confounded Variable: Is it Drag-and-Drop or Game Difficulty?
Current data is confounded — we don't know if Claude fails because:
- The drag-and-drop UI is the bottleneck (interaction problem), OR
- The game is conceptually hard with insufficient scaffolding (design problem)

### Experimental Decision Tree
```
Step 1: Add TEXT MODE to Feynman sim
        (type "place box on scale" instead of dragging)
        ├── Claude SUCCEEDS → Drag-and-drop was the bottleneck
        │   └── Step 2a: Study Brilliant/PhET UI patterns
        │       - What libraries/components make their drag-and-drop work?
        │       - Brilliant uses Elm — investigate
        │       - Can we replicate their interaction patterns?
        │
        └── Claude FAILS → Scaffolding is the real problem
            └── Step 2b: Design intermediate guided mode
                - Between Playground (zero scaffolding) and Game (constrained, still zero scaffolding)
                - Follow Brilliant/PhET patterns for guided exploration

Step 3: Layer on multimodal inputs (voice, video)
        - Makes sims accessible to disabled users, text-preferring users
        - AI agents work cleanly with text interface for automated testing
```

### Sequence Convergence: The Success Case
Claude's best sim performance was on the sequence convergence game (user's custom math sim):
- **Had scaffolding**: easy → medium → hard levels
- **Claude self-selected**: started at easy, progressed to medium, attempted game mode
- **Got hooked**: "Let me try again" behavior, correct-but-not-optimal answer drove retry
- **Low activation energy**: one small input, immediate feedback
- **Human-like behavior**: avoided hardest level, felt satisfied-but-wanting-more

### The Comparison
| Factor | Sequence Convergence | Feynman Conservation |
|--------|---------------------|---------------------|
| Scaffolding | Yes (3 levels) | No (playground vs game, both unscaffolded) |
| Drag-and-drop | Minimal | Heavy |
| Claude engagement | High (hooked) | Low (defensive/scared) |
| Immediate feedback | Yes | Unclear |
| Activation energy | Low | High |

**Conclusion**: Game quality and physics content are strong in both. The difference is purely interaction design and scaffolding. This is actionable — the game doesn't need content changes, it needs UX improvements.

### Design Principles from Sequence Convergence (the Success Case)
Three principles that created engagement:
1. **Multiple affordances**: Visual observation, numerical calculation, code — if one path is blocked, alternatives exist. Claude found its own path around the clicker via hand calculations. Design resilience.
2. **Gradient of success**: Not binary pass/fail. Correct-but-not-optimal creates a sweet spot — feel accomplished but still curious. Drives re-engagement.
3. **Immediate feedback loop**: Click → result → learn. No waiting, no ambiguity about whether your action had an effect.

The Feynman game is missing all three: single interaction path (drag-and-drop), binary success, delayed/unclear feedback.

### New Metric: Session Duration as Sim Quality Proxy
- **Short + complete = well-designed**: Matrix transforms (3min, full coverage, $0.83)
- **Medium + partial = friction**: Feynman conservation (6min, 8/28 blocks, $2.10)
- **Long + narration-heavy = UI mismatch**: Neural networks ch4 (15min, couldn't use widgets, $5.77)
- The shortness IS the validation — if Claude covers everything quickly, the sim is clear and well-designed
- Good marketing content and good pedagogical validation are the same thing
- Matrix transforms video: best marketing asset — 3.5min, natural exploration arc, makes viewer want to try the tool

### The Irony: Claude Designed What Claude Loves
- The sequence convergence game's scaffolding was designed BY Claude (Artifacts/Sonnet 4.5 in browser)
- User had the core concept (hardest level) as hacky Python code
- Claude in browser suggested the scaffolding, progressive levels, and immediate feedback
- Then a DIFFERENT Claude (on the VM) played the game and got hooked
- **Insight**: Claude is its own best UX designer AND user tester — it created the engagement loop that hooked itself
- AI doesn't have the "curse of knowledge" — approaches material fresh, naturally designs for accessibility

### Expert Blind Spot in Feynman Game
- Feynman game was designed entirely by user (a physics enthusiast who loves Feynman lectures)
- It's a love letter to Feynman — fun for people who already share the context and passion
- But it doesn't TEACH the love of Feynman to newcomers — assumes too much
- Classic expert blind spot: deep domain knowledge makes you forget how much scaffolding newcomers need
- The AI-human collaborative design process (sequence convergence) naturally avoids this blind spot

## Origin Stories

### Matrix Transforms Sim
- Started as SVD presentation for PhD program, inspired by 3Blue1Brown and Steve Brunton
- Half-red, half-blue sphere showing rotation/scaling transforms → would build to SVD
- Cove couldn't handle full SVD, but matrix transforms alone was good enough
- Most popular sim on Cove: 238 views, 19 remixes (from non-math audience!)
- Dad (Narendra Karmarkar) approved the SVD slides: "you did a great job" (rare for math)
- AI validation: Claude explored all 4 transform types, $0.83, called it "fantastic"
- Visual appeal of morphing sphere is universal — engagement transcends math knowledge

### Sequence Convergence Sim

The lead sim for any pitch — here's the story:

1. **First semester, IISER Kolkata**: Vivek is taking computational physics and real analysis simultaneously. Can't understand the epsilon-N definition of sequence convergence from the professor.
2. **Dad's picture**: Narendra Karmarkar (yes, THAT Karmarkar — inventor of Karmarkar's algorithm) gives a visual explanation that clicks.
3. **Code as understanding**: Vivek codes the definition in Python for his computational physics course. "The mathematical definition was the spec, the simulation was the implementation." Understanding came from building.
4. **Lost but memorized**: Laptop died, code was lost, but Vivek knew it cold.
5. **Cove → Claude Artifacts → Claude Code**: Years later, gave the code to Cove (fancy UI), then Claude Artifacts (which added the scaffolding, levels, and feedback loops — Claude's idea, not Vivek's), then polished in Claude Code.
6. **AI validates AI's design**: Claude on the VM plays the game and gets hooked. The scaffolding Claude designed in Artifacts is what makes it engaging.

**Why this sim for the Brilliant pitch**:
- Math-aligned (Brilliant's core)
- Gamified with addictive feedback loop
- Personal origin story with mathematical royalty
- AI-validated engagement
- Fills a gap: visual real analysis (Brilliant doesn't have this)
- Inspired by Tristan Needham's Visual Complex Analysis philosophy

## PhET Collaboration & NSF Grant Angle

### Existing Relationship
- User is collaborating (slowly) with Eugenia and her student — the lead software dev at PhET who also designed the Universe and More games
- User previously sent a PhET sim recreation that was so accurate it caused internal concern at PhET ("shouldn't respond to this guy, we'll lose our job")
- Kathy Perkins (co-founder/director of PhET at CU Boulder) was involved in that internal discussion
- Carl Wieman (Nobel Prize-winning physicist, PhET founder) personally responded to user's email
- PhET dev said: "If you can find a way to use AI knowledge to partner with PhET, we could pitch an NSF grant to Kathy Perkins"

### NSF Grant Pitch: AI Agents as Educational UX Evaluators
**Research question**: "Can autonomous AI agents serve as proxy users for evaluating the accessibility and engagement of interactive educational simulations?"

Three possible angles:
1. **Games only** — less novel, lots of people make educational games
2. **Games + validation** — interesting combination
3. **Validation methodology alone** — **most novel and most fundable**

The validation angle is strongest because:
- NSF loves novel evaluation methodologies (HCI and Education programs)
- It's measurable and reproducible
- It builds on an established, funded platform (PhET)
- It has clear implications for improving educational software design at scale
- Multi-agent classroom simulation produces rich, analyzable data
- No one else is doing this — genuinely novel contribution

## Next Steps

### Completed
- [x] Neural Networks Chapter 4 session (15min, $5.77)
- [x] Feynman Conservation v2 with coached approach (6min, $2.10)
- [x] Matrix Transforms session (3min, $0.83)
- [x] FUTURE-VISION.md with full findings and strategy

### Immediate (This Week)
1. **Validation web page** — scope and build the "Novel Validation with AI Agents" section for portfolio website
   - Architecture diagram (already have interactive HTML version)
   - Methodology description
   - YouTube embeds of recordings (upload matrix transforms first — best marketing asset)
   - Session duration metric visualization
   - Key findings summary
2. **Update interactive sims page** — link to validation section, make it feel part of ecosystem
3. **Upload recordings to YouTube** — start with matrix transforms (3.5min, most engaging)

### Short-term (Next 1-2 Weeks)
4. **Medium article** — hook: "I gave Claude a computer and it got banned from Brilliant"
5. **Email Brilliant support** — account reactivation with context about research
6. **Apply to Brilliant jobs** — with portfolio link including validation section
7. **Pitch order for Brilliant**: matrix transforms (hook) → sequence convergence (depth) → validation system (methodology)

### Medium-term (Experimental)
8. Add text command mode to Feynman sim to isolate drag-and-drop vs scaffolding variable
9. Build multi-agent orchestrator script
10. Define 3-5 personality prompts for different student types
11. Run parallel sessions on the same educational content

### Long-term (Research/Grant)
12. NSF grant pitch with PhET collaboration (validation methodology)
13. Build analysis dashboard comparing agent experiences
14. Formal write-up of "AI agents as proxy users" methodology
