# Editors

A collection of lightweight and open-source text editors for development and writing.

## VSCodium

VSCodium is a community-driven, MIT-licensed build of VS Code with all the telemetry ripped out and Microsoft branding removed. You get all the power of VS Code with none of the corporate tracking.

| | |
|---|---|
| **License** | MIT |
| **Built on** | Electron |
| **Use case** | Full-featured code editor, extensions ecosystem |

**Installation:**

```bash
# Binary (recommended - installs in minutes)
yay -S vscodium-bin

# From source (slower, but self-compiled)
yay -S vscodium
```

Start with `vscodium-bin` unless you specifically want to build from source. The binary is significantly faster to install and works great out of the box. Open VSX marketplace is pre-configured for extension support.

---

## Obsidian

Your notes, owned by you. Obsidian stores everything as plain Markdown files in a folder you control—perfect for building a personal knowledge base or wiki. No cloud lock-in, no subscriptions.

| | |
|---|---|
| **License** | Proprietary (free for personal use) |
| **Core idea** | Local-first, your vault, your rules |
| **Use case** | Note-taking, knowledge management, PKM |

**Installation:**

```bash
yay -S obsidian-bin
```

Simple and direct. The binary package includes Electron, so you get everything in one go. All your notes stay in `~/Obsidian` or wherever you choose—no syncing to external servers unless you want to.

---

## MarkText

A clean and lightweight editor specifically built for Markdown. No frills, no bloat—just you and your text. Great for blog posts, documentation, or focused writing sessions.

| | |
|---|---|
| **License** | MIT |
| **Approach** | Simplicity first |
| **Use case** | Markdown writing, quick editing, blog posts |

**Installation:**

```bash
yay -S marktext
```

**Note:** The package builds from source and can be a bit finicky. If the build stalls or fails, try these workarounds:
- Check the [AUR page](https://aur.archlinux.org/packages/marktext) comments for recent issues
- Build in a clean `makechrootpkg` environment if your system's npm is too new
- Pre-built binaries are available in some user repositories as a fallback
