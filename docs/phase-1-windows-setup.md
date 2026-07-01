# Phase 1 — Windows Dev Environment Setup

> **Where:** Your Windows PC  
> **Time:** ~30 minutes  
> **Prerequisite:** None (Windows-First Bootstrapping initialized)  
> **Goal:** Set up VS Code, Git, iTunes, AltServer, and initialize local repository

---

## Checklist

- [x] Bootstrapped local Xcode project and SwiftUI folder structure on Windows
- [ ] Install Git for Windows
- [ ] Install VS Code + extensions
- [ ] Install iTunes from Apple website (NOT Microsoft Store)
- [ ] Install iCloud from Apple website
- [ ] Download AltServer
- [ ] Connect local repository to GitHub
- [x] Verify project structure

---

## Step 1: Install Git for Windows

If you don't already have Git:

1. Download from [git-scm.com/download/win](https://git-scm.com/download/win)
2. Run the installer — **default settings are fine for everything**
3. Verify in PowerShell:
   ```powershell
   git --version
   ```
   Should show something like `git version 2.45.0.windows.1`

---

## Step 2: Install VS Code + Extensions

1. Download from [code.visualstudio.com](https://code.visualstudio.com)
2. Install with default settings
3. Open VS Code
4. Install these extensions (click the Extensions icon in the sidebar, or `Ctrl+Shift+X`):

| Extension | Author | Purpose |
|---|---|---|
| **Swift** | Swift Server Work Group | Syntax highlighting for .swift files |
| **GitHub Actions** | GitHub | Monitor CI builds from VS Code |

Optional nice-to-haves:
| Extension | Purpose |
|---|---|
| **sweetpad** | iOS project awareness, build config preview |
| **GitLens** | Enhanced git blame, history |

---

## Step 3: Install iTunes (Apple Website Version)

> ⚠️ **CRITICAL: Do NOT install iTunes from the Microsoft Store.** The Store version doesn't include the USB drivers that AltServer needs.

1. Go to [apple.com/itunes/download/win64](https://www.apple.com/itunes/download/win64)
2. Click **Download iTunes for Windows (64-bit)**
3. Run the installer
4. You don't need to open iTunes after installing — we just need the drivers

**How to verify you have the right version:**
- Open Windows Settings → Apps → Installed apps
- Look for "iTunes" — it should say "Apple Inc." as the publisher
- If it says "iTunes" with a Microsoft Store icon, **uninstall it** and install from Apple's website instead

---

## Step 4: Install iCloud for Windows

AltServer also requires iCloud's Windows frameworks.

1. Go to [support.apple.com/en-us/102232](https://support.apple.com/en-us/102232) or search "iCloud for Windows download Apple"
2. Download the **Windows installer** (again, NOT the Microsoft Store version)
3. Install it
4. You don't need to sign in — just having it installed is enough

---

## Step 5: Download AltServer

1. Go to [altstore.io](https://altstore.io)
2. Scroll down and click **Download AltServer for Windows**
3. Extract the downloaded `.zip` file
4. Run `AltInstaller.exe` (or `Setup.exe`)
5. After installation, find **AltServer** in your Start Menu and launch it
6. You'll see a **diamond icon** appear in your system tray (bottom-right, near the clock)
   - You may need to click the **^** arrow to see hidden tray icons

> Don't do anything with AltServer yet — we'll use it in Phase 4. Just make sure it launches without errors.

---

## Step 6: Connect to GitHub Remote

Since we initialized Git locally on your Windows PC and bootstrapped the Xcode project here, you need to link your local repository to your remote GitHub repository:

1. Go to [github.com/new](https://github.com/new) and create a new **public** repository named `lyrics-widget-app`.
2. Do **not** initialize it with a README, `.gitignore`, or license (we already created these!).
3. Open **PowerShell** (or VS Code's integrated terminal) and run these commands to link and push your initial commit:
   ```powershell
   cd c:\Users\phucl\OneDrive\Desktop\phuc\Projects\autoscroll-lyrics-widget
   git remote add origin https://github.com/YOUR_GITHUB_USERNAME/lyrics-widget-app.git
   git branch -M main
   git add .
   git commit -m "initial commit — Windows-first project bootstrap"
   git push -u origin main
   ```

---

## Step 7: Verify Project Structure

Your local bootstrapped workspace contains the following files:

```
autoscroll-lyrics-widget/
├── .git/
├── .gitignore
├── credentials.local.txt      ← local credentials (ignored by Git)
├── docs/                      ← planning & setup guides
├── LyricsWidget/
│   ├── Assets.xcassets/       ← app asset catalog (AccentColor, AppIcon)
│   ├── ContentView.swift      ← beautiful SwiftUI homepage
│   ├── LyricsWidgetApp.swift  ← app entry point
│   ├── Models/                ← models directory (ready for Phase 2)
│   ├── Services/              ← services directory (ready for Phase 2)
│   ├── Storage/               ← storage directory (ready for Phase 2)
│   └── Views/                 ← views directory (ready for Phase 2)
└── LyricsWidget.xcodeproj/    ← bootstrapped Xcode project database
    ├── project.pbxproj
    ├── project.xcworkspace/
    └── xcshareddata/
```

---

## Step 8: Open in VS Code

```powershell
code c:\Users\phucl\OneDrive\Desktop\phuc\Projects\autoscroll-lyrics-widget
```

Or in VS Code: File → Open Folder → navigate to the workspace.

Try opening `LyricsWidget/ContentView.swift` — you should see Swift syntax highlighting (blue keywords, green strings, etc.).

---

## Step 9: Configure Git Identity (if not already done)

```powershell
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

---

## Store Your Credentials Securely

Create a file you **do NOT commit** to keep your signing credentials handy:

Create `credentials.local.txt` in the project root (it's already in `.gitignore` patterns):

```
# DO NOT COMMIT THIS FILE

Apple ID Email:      your@email.com
Team ID:             A1B2C3D4E5
Bundle Identifier:   com.lyrico.LyricsWidget
Cert .p12 Password:  your-password-here
GitHub PAT:          ghp_xxxxxxxxxxxxx
```

Add to `.gitignore`:
```
credentials.local.txt
*.p12
*.mobileprovision
```

---

## What's Next

Your development environment is ready. Proceed to:

→ **[Phase 2: Core App Code](./phase-2-core-app-code.md)**
