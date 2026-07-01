# Phase 0 — Mac Session #1: Bootstrap & Device Registration (Archived / Bypassed)

> [!NOTE]
> **STATUS: BYPASSED & ARCHIVED**  
> This project has successfully transitioned to a **100% Windows-only development flow**. We manually bootstrapped the Xcode project and successfully compiled/sideloaded the initial app without a physical Mac. This document is kept for reference purposes only.

> **Where:** Borrowed Mac (Bypassed)  
> **Time:** ~1.5 hours  
> **Goal:** Create the Xcode project, register your iPhone, export signing credentials, push to GitHub

---

## Before You Leave for the Mac

Complete these steps on your **Windows PC** before you sit down at the Mac. Every minute on the borrowed Mac is precious — don't waste it on things you can do at home.

### Checklist: Pre-Mac Prep

- [ ] **1. Apple ID** — Create a free Apple ID at [appleid.apple.com](https://appleid.apple.com) if you don't have one
  - Use a real email you have access to (you'll need 2FA codes)
  - Remember the password — you'll enter it in Xcode

- [ ] **2. GitHub Repository** — Go to [github.com/new](https://github.com/new) and create a **public** repo:
  - Name: `lyrics-widget-app`
  - Visibility: **Public** (for unlimited CI minutes)
  - Initialize with README: **No** (we'll push from the Mac)
  - No .gitignore template, no license (we'll add these from Xcode)

- [ ] **3. iPhone Developer Mode** — On your iPhone:
  1. Go to **Settings** → **Privacy & Security**
  2. Scroll to the very bottom
  3. Tap **Developer Mode** → toggle **ON**
  4. Your phone will restart
  5. After restart, confirm the prompt to enable Developer Mode
  
  > ⚠️ If you don't see "Developer Mode", connect your iPhone to a Mac with Xcode once — it appears after that. You can also try connecting to a Mac with Xcode installed first.

- [ ] **4. Bring the Right Cable** — You need a USB cable that supports **data transfer** (not charge-only). Test it: plug into a PC, does it show in File Explorer/iTunes? If yes, it works.

- [ ] **5. Bring Storage** — USB drive OR have cloud storage ready (Google Drive, iCloud, Dropbox). You'll need to take 2 small files home (~10KB total):
  - A `.p12` certificate file
  - A `.mobileprovision` profile file

- [ ] **6. Know Your GitHub Credentials** — You'll need to `git push` from the Mac terminal. Make sure you know:
  - Your GitHub username
  - A Personal Access Token (PAT) — create one at [github.com/settings/tokens](https://github.com/settings/tokens) → "Generate new token (classic)" → select `repo` scope → copy the token. You'll use this as your password when pushing.

---

## On the Mac — Step by Step

### Step 1: Install Xcode (~30-45 min download)

> **START THIS FIRST.** Xcode is ~10-15 GB. Start the download immediately, then do other steps while it downloads.

1. Open the **Mac App Store** (click the Apple menu → App Store, or Spotlight → "App Store")
2. Search for **Xcode**
3. Click **Get** → **Install**
4. Wait... (seriously, this takes a while on most connections)

**While Xcode downloads, do these:**
- Open **Terminal** (Spotlight → "Terminal")
- Check if Git is installed: `git --version` (it should be — macOS includes it)
- Clone your empty GitHub repo:
  ```bash
  cd ~/Desktop
  git clone https://github.com/YOUR_GITHUB_USERNAME/lyrics-widget-app.git
  cd lyrics-widget-app
  ```
  If prompted for credentials, enter your GitHub username and your **Personal Access Token** as the password.

### Step 2: Xcode First Launch & Account Setup

Once Xcode finishes installing:

1. **Open Xcode** (Launchpad or Spotlight → "Xcode")
2. It may ask to install additional components — click **Install** and wait
3. Go to **Xcode** menu (top-left) → **Settings** (or **Preferences** on older Xcode)
4. Click the **Accounts** tab
5. Click the **+** button in the bottom-left
6. Select **Apple ID**
7. Sign in with your Apple ID email and password
8. You should see your name appear with "Personal Team" underneath

> ✅ If you see "Personal Team (Free)" — you're good.

### Step 3: Create the Xcode Project

1. Go to **File** → **New** → **Project...**
2. Select the **iOS** tab at the top
3. Choose **App** → click **Next**
4. Fill in these settings **exactly**:

| Field | Value |
|---|---|
| Product Name | `LyricsWidget` |
| Team | Your name (Personal Team) |
| Organization Identifier | `com.lyrico` |
| Bundle Identifier | Should auto-fill: `com.lyrico.LyricsWidget` |
| Interface | **SwiftUI** |
| Language | **Swift** |
| Storage | **None** |
| Include Tests | **Uncheck both** (Unit Tests & UI Tests) |

5. Click **Next**
6. **IMPORTANT:** Navigate to your cloned repo folder: `~/Desktop/lyrics-widget-app/`
7. Click **Create**

> ⚠️ The project files should be created **directly inside** `lyrics-widget-app/`, NOT in a subfolder like `lyrics-widget-app/LyricsWidget/`. If Xcode creates a subfolder, that's fine — the `.xcodeproj` file should be at the top level of the git repo.

### Step 4: Verify Project Structure

Open Terminal and check:

```bash
cd ~/Desktop/lyrics-widget-app
ls -la
```

You should see something like:

```
.git/
LyricsWidget/
LyricsWidget.xcodeproj/
```

Inside `LyricsWidget/`:
```
LyricsWidget/
├── Assets.xcassets/
├── ContentView.swift
├── LyricsWidgetApp.swift
└── Preview Content/
```

### Step 5: Connect iPhone & First Run

1. **Plug in your iPhone** to the Mac via USB cable
2. On your iPhone: tap **Trust** when asked "Trust This Computer?" → enter your passcode
3. In Xcode, look at the **top toolbar** — there's a dropdown that says something like "iPhone 15 Simulator"
4. Click it and select your **physical iPhone** from the list (it should appear under "Devices")
   - If your iPhone doesn't appear: unplug and replug, make sure the phone is unlocked
5. Click the **▶ Play** button (or press `Cmd+R`)
6. Xcode will:
   - Compile the project
   - Install the app on your iPhone
   - Launch it

**First-time errors you'll see (and how to fix them):**

#### Error: "Untrusted Developer"
On your iPhone:
1. Go to **Settings** → **General** → scroll down → **VPN & Device Management**
2. Under "DEVELOPER APP", you'll see your Apple ID email
3. Tap it → tap **Trust "[your email]"** → tap **Trust**
4. Go back to Xcode and press ▶ Run again

#### Error: "Could not launch"
- Make sure Developer Mode is enabled (you did this in pre-prep)
- Make sure the phone is unlocked when you press Run
- Try unplugging and re-plugging the cable

#### Error: "Failed to register bundle identifier"
- This means someone else has `com.lyrico.LyricsWidget` — change it to something unique like `com.lyrico.LyricsWidget2` or `com.yourname.LyricsWidget`

> ✅ **Success looks like:** A blank white screen appears on your iPhone. That's the default SwiftUI "Hello, World!" app. This confirms your device is registered and code signing works.

### Step 6: Record Your Credentials

Open a notes app or text file and save these values:

#### A) Team ID

**Method 1 (easier):** In Terminal:
```bash
cd ~/Desktop/lyrics-widget-app
grep "DEVELOPMENT_TEAM" LyricsWidget.xcodeproj/project.pbxproj | head -1
```
You'll see something like: `DEVELOPMENT_TEAM = A1B2C3D4E5;` — that 10-character code is your Team ID.

**Method 2:** Xcode → Settings → Accounts → select your Apple ID → the Team ID is shown next to your name/team.

#### B) Bundle Identifier

This is `com.lyrico.LyricsWidget` (or whatever you set in Step 3). Confirm in Xcode: select the project → LyricsWidget target → General tab → "Bundle Identifier".

#### C) Write them down:

```
Team ID:             ___________________________
Bundle Identifier:   com.lyrico.LyricsWidget
Apple ID Email:      ___________________________
```

### Step 7: Export the Development Certificate (.p12)

1. Open **Keychain Access** (Spotlight → "Keychain Access")
2. In the left sidebar:
   - Keychain: **login**
   - Category: **My Certificates**
3. Find the certificate named **"Apple Development: your@email.com"**
   - If you see multiple, pick the one with the latest expiry date
4. **Right-click** on it → **Export "Apple Development: ..."**
5. Choose a save location (Desktop is fine)
6. Format: **Personal Information Exchange (.p12)**
7. Click **Save**
8. **Set a password** — this is important, you'll need it later
   - Use something you'll remember, like `lyrico2025`
   - You'll be prompted for your Mac login password too — enter it
9. Copy the `.p12` file to your USB drive or upload to cloud storage

### Step 8: Export the Provisioning Profile (.mobileprovision)

1. In Finder, press **Cmd+Shift+G** (Go to Folder)
2. Paste this path: `~/Library/MobileDevice/Provisioning Profiles/`
3. Press Enter
4. You'll see files with UUID names like `abc12345-def6-7890.mobileprovision`

**To find the right one**, run this in Terminal:

```bash
for f in ~/Library/MobileDevice/Provisioning\ Profiles/*.mobileprovision; do
  echo ""
  echo "=============================="
  echo "File: $(basename "$f")"
  echo "=============================="
  security cms -D -i "$f" 2>/dev/null | grep -A1 -E "<key>(Name|AppIDName|TeamName|ExpirationDate)</key>"
done
```

Look for the one where:
- **Name** or **AppIDName** contains `LyricsWidget` or `com.lyrico.LyricsWidget`
- **TeamName** matches your name

Copy that `.mobileprovision` file to your USB drive or cloud storage alongside the `.p12`.

### Step 9: Switch to Manual Signing

This step is important so that GitHub Actions can build without needing Xcode's automatic signing (which requires an interactive Apple ID login).

1. In Xcode, select the **LyricsWidget** project in the left sidebar
2. Select the **LyricsWidget** target
3. Go to the **Signing & Capabilities** tab
4. **Uncheck** "Automatically manage signing"
5. Two sections appear: **Signing (Debug)** and **Signing (Release)**
6. For **BOTH** Debug and Release:
   - **Provisioning Profile**: Click the dropdown → select the profile Xcode generated (it should show your app name)
   - **Signing Certificate**: Select **"Apple Development"**
7. Build again (`Cmd+B`) to make sure it still compiles with manual signing

> ⚠️ If you get signing errors after switching to manual, you can leave it as automatic for now. We'll handle it in the CI workflow by disabling signing entirely (`CODE_SIGNING_ALLOWED=NO`).

### Step 10: Create .gitignore

Create a `.gitignore` file in the repo root. In Terminal:

```bash
cd ~/Desktop/lyrics-widget-app
cat > .gitignore << 'EOF'
# Xcode
*.xcuserdata/
*.xcworkspace/
xcuserdata/
DerivedData/
build/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# macOS
.DS_Store
.AppleDouble
.LSOverride

# CocoaPods
Pods/

# Swift Package Manager
.build/
.swiftpm/

# Fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output
EOF
```

### Step 11: Commit & Push to GitHub

```bash
cd ~/Desktop/lyrics-widget-app
git add .
git commit -m "initial Xcode project — LyricsWidget with manual signing"
git push origin main
```

If prompted for GitHub credentials:
- Username: your GitHub username
- Password: your **Personal Access Token** (NOT your GitHub password)

### Step 12: Verify on GitHub

Open your browser and go to `https://github.com/YOUR_USERNAME/lyrics-widget-app`

You should see:
- `LyricsWidget/` folder
- `LyricsWidget.xcodeproj/` folder
- `.gitignore` file

---

## Final Checklist Before Leaving the Mac

- [ ] App ran successfully on your iPhone (even if just a white screen)
- [ ] You have the **Team ID** written down
- [ ] You have the **Bundle Identifier** confirmed
- [ ] You have the `.p12` certificate file saved (with its password)
- [ ] You have the `.mobileprovision` file saved
- [ ] Project is pushed to GitHub and visible in the browser
- [ ] `.gitignore` is in the repo

---

## Troubleshooting

### "Xcode cannot find my iPhone"
- Unplug and replug the cable
- Make sure the iPhone is unlocked
- Try a different USB port
- In Xcode menu: Window → Devices and Simulators — your phone should appear here

### "Failed to create provisioning profile"
- Make sure Bundle Identifier is unique (`com.lyrico.LyricsWidget`)
- If taken, try `com.lyrico.LyricsWidget2` or use your own name

### "Developer Mode not visible in Settings"
- Connect iPhone to the Mac with Xcode open
- The option should appear after Xcode detects the device
- Requires iOS 16 or later

### "git push rejected"
- Make sure you created the repo as empty (no README)
- If the repo has a README, do: `git pull --rebase origin main` first, then push

---

## What Happens Next

Take your `.p12`, `.mobileprovision`, and credentials notes home. On your Windows PC, proceed to:

→ **[Phase 1: Windows Dev Environment Setup](./phase-1-windows-setup.md)**
