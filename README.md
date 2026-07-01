# Lyrico — iOS Lyrics Widget App

> Build an iOS lyrics widget from a Windows PC using borrowed Mac sessions, GitHub Actions CI, and AltStore sideloading. Total cost: **$0**.

---

## Project Summary

| Item | Value |
|---|---|
| App Name | **Lyrico** |
| Bundle ID | `com.lyrico.LyricsWidget` |
| Lyrics API | [LRCLIB](https://lrclib.net) (free, no auth) |
| Min iOS | 17.0 (interactive widgets) |
| Widget Sizes | Small, Medium, Large |
| GitHub Repo | Public (unlimited CI minutes) |
| Signing | Unsigned build → AltStore re-signs |
| Mac Sessions Needed | **2** (~1.5 hrs each) |

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│  YOUR WINDOWS PC                                         │
│  ┌─────────────┐  ┌──────────┐  ┌────────────────────┐  │
│  │  VS Code    │→ │  Git CLI │→ │  GitHub (public)   │  │
│  │  Swift edit  │  │  commit  │  │  Actions: build    │  │
│  └─────────────┘  └──────────┘  └────────┬───────────┘  │
│                                          ↓               │
│  ┌─────────────┐                ┌────────────────────┐  │
│  │  AltServer  │ ←───────────── │  Download .ipa     │  │
│  │  (tray app) │                │  from Artifacts    │  │
│  └──────┬──────┘                └────────────────────┘  │
│         ↓                                                │
│  ┌─────────────┐                                         │
│  │  iPhone     │  ← sideloads via WiFi/USB               │
│  │  AltStore   │                                         │
│  └─────────────┘                                         │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│  ON THE iPHONE                                           │
│                                                          │
│  ┌──────────────────┐    ┌───────────────────────────┐  │
│  │  Lyrico App      │    │  Widget Extension         │  │
│  │  - Search lyrics │    │  - Shows lyric lines      │  │
│  │  - Pick a song   │    │  - Tap to advance         │  │
│  │  - Customize     │    │  - Reads shared storage   │  │
│  └────────┬─────────┘    └─────────────┬─────────────┘  │
│           │                            │                 │
│           └──────┐    ┌────────────────┘                 │
│                  ↓    ↓                                  │
│          ┌──────────────────┐                            │
│          │  App Groups      │                            │
│          │  (shared prefs)  │                            │
│          └──────────────────┘                            │
│                  ↑                                       │
│          ┌──────────────────┐                            │
│          │  LRCLIB API      │  (internet, free)          │
│          └──────────────────┘                            │
└──────────────────────────────────────────────────────────┘
```

---

## Phase Guides

Follow these docs **in order**. Each phase has a checklist at the top — tick items off as you go.

| Phase | Doc | Where | Time |
|---|---|---|---|
| 0 | [Mac Session #1 — Bootstrap](./phase-0-mac-session-1.md) | Borrowed Mac | ~1.5 hrs |
| 1 | [Windows Dev Environment](./phase-1-windows-setup.md) | Windows PC | ~30 min |
| 2 | [Core App Code](./phase-2-core-app-code.md) | Windows PC | ~1 hr |
| 3 | [GitHub Actions CI](./phase-3-github-actions.md) | Windows PC | ~20 min |
| 4 | [Sideloading via AltStore](./phase-4-sideloading.md) | Windows PC + iPhone | ~30 min |
| 5 | [Mac Session #2 — Widget Extension](./phase-5-mac-session-2.md) | Borrowed Mac | ~1 hr |
| 6 | [Widget Code & Shared Storage](./phase-6-widget-code.md) | Windows PC | ~1 hr |
| 7 | [Customization Settings](./phase-7-customization.md) | Windows PC | ~30 min |
| 8 | [Ongoing Workflow](./phase-8-ongoing.md) | Windows PC | ongoing |

---

## Key Constraints You Should Know

### Free Apple ID Limits
- **3 active sideloaded apps** on your device at once
- **7-day certificate expiry** (AltStore auto-refreshes if running on same WiFi)
- **10 App IDs** total registered to your account
- **No App Store / TestFlight distribution** — personal use only

### WidgetKit Limits
- **No real-time animation** — widgets render static snapshots
- **40-70 timeline refreshes per day** (system-controlled)
- **Interactive buttons** available on iOS 17+ via AppIntent
- Our "scrolling" = tap-to-advance through lyric lines

### GitHub Actions (Public Repo)
- **Unlimited minutes** for public repositories
- macOS runners have Xcode pre-installed
- Typical build: ~5-10 minutes
- Artifacts downloadable for 30 days

---

## Credentials Checklist

Fill these in during Phase 0 and keep them safe:

```
Apple ID Email:      ___________________________
Team ID:             ___________________________
Bundle Identifier:   com.lyrico.LyricsWidget
Cert .p12 Password:  ___________________________
GitHub Username:     ___________________________
GitHub Repo URL:     ___________________________
```
