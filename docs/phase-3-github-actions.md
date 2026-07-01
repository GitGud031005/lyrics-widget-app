# Phase 3 — GitHub Actions CI (Automated Cloud Building)

> **Where:** Windows PC  
> **Time:** ~20 minutes  
> **Prerequisite:** Phase 2 complete (code pushed to GitHub)  
> **Goal:** Set up GitHub Actions to build your iOS app on every push

---

## Checklist

- [ ] Create the workflow file
- [ ] Push to GitHub
- [ ] Trigger a build
- [ ] Download the artifact

---

## How It Works

```
Your code on GitHub
       ↓
GitHub spins up a macOS virtual machine
       ↓
Installs your code on it
       ↓
Runs xcodebuild (compiles Swift → .app bundle)
       ↓
Packages the .app into a downloadable .ipa
       ↓
You download it and sideload via AltStore
```

### Why Unsigned?

A free Apple Developer account **cannot** use `xcodebuild -exportArchive` to produce a signed IPA — that requires the paid $99/year program. Instead, we:

1. Build with `CODE_SIGNING_ALLOWED=NO` (produces an unsigned `.app` bundle)
2. Package it into an IPA structure (just a zip file)
3. AltStore re-signs it with your Apple ID when sideloading

**This means zero certificates or profiles need to be uploaded to GitHub.**

---

## Step 1: Create the Workflow File

Create the directory structure:

```powershell
mkdir -p .github\workflows
```

Create file: `.github/workflows/build.yml`

```yaml
name: Build iOS App

# When to run this workflow:
on:
  # Automatically on every push to main
  push:
    branches: [main]
  
  # Manually from the GitHub Actions tab
  workflow_dispatch:

jobs:
  build:
    name: Build Lyrico
    runs-on: macos-latest
    timeout-minutes: 30

    steps:
      # Step 1: Get our code
      - name: Checkout code
        uses: actions/checkout@v4

      # Step 2: Show build environment info (helpful for debugging)
      - name: Show environment
        run: |
          echo "=== Xcode Version ==="
          xcodebuild -version
          echo ""
          echo "=== Available SDKs ==="
          xcodebuild -showsdks | grep iphoneos
          echo ""
          echo "=== Project Schemes ==="
          xcodebuild -project LyricsWidget.xcodeproj -list

      # Step 3: Build the app (unsigned — AltStore will re-sign)
      - name: Build .app bundle
        run: |
          xcodebuild \
            -project LyricsWidget.xcodeproj \
            -scheme LyricsWidget \
            -configuration Debug \
            -destination 'generic/platform=iOS' \
            -derivedDataPath build \
            CODE_SIGNING_ALLOWED=NO \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGN_IDENTITY="" \
            DEVELOPMENT_TEAM="" \
            build \
            2>&1 | tail -50

          echo ""
          echo "=== Build Complete ==="

      # Step 4: Package the .app into an IPA
      - name: Package as IPA
        run: |
          # Find the built .app bundle
          APP_PATH=$(find build/Build/Products -name "*.app" -type d | head -1)
          
          if [ -z "$APP_PATH" ]; then
            echo "ERROR: Could not find .app bundle!"
            echo "Contents of build directory:"
            find build -type d -name "*.app"
            exit 1
          fi
          
          echo "Found app at: $APP_PATH"
          
          # Create the IPA structure (IPA = zip containing Payload/*.app)
          mkdir -p package/Payload
          cp -r "$APP_PATH" package/Payload/
          
          # Create the IPA file
          cd package
          zip -r ../LyricsWidget.ipa Payload/
          cd ..
          
          # Verify
          echo ""
          echo "=== IPA Created ==="
          ls -lh LyricsWidget.ipa

      # Step 5: Upload the IPA as a downloadable artifact
      - name: Upload IPA
        uses: actions/upload-artifact@v4
        with:
          name: Lyrico-ipa
          path: LyricsWidget.ipa
          retention-days: 30
```

---

## Step 2: Push to GitHub

```powershell
git add .github/workflows/build.yml
git commit -m "add GitHub Actions workflow for iOS build"
git push origin main
```

---

## Step 3: Watch the Build

1. Open your browser and go to: `https://github.com/YOUR_USERNAME/lyrics-widget-app/actions`
2. You should see a workflow run starting (triggered by your push)
3. Click on it to watch the live logs
4. Each step shows a green checkmark when complete
5. The full build typically takes **5-10 minutes**

### If the build fails:

**Common issues and fixes:**

| Error | Fix |
|---|---|
| `xcodebuild: error: The project 'LyricsWidget.xcodeproj' does not contain a scheme named 'LyricsWidget'` | The scheme might have a different name. Check the "Show environment" step's output — it lists available schemes. Update the `-scheme` value in the workflow. |
| `error: no such module 'WidgetKit'` | Remove the `import WidgetKit` line from `LyricsStore.swift` — we don't need it until Phase 6. Replace with a comment `// TODO: import WidgetKit after Phase 5` |
| `Compile error: files not in project` | The new Swift files aren't registered in `project.pbxproj`. See Phase 2 Step 9 for how to fix this. |
| `error: Signing for "LyricsWidget" requires a development team` | Make sure `DEVELOPMENT_TEAM=""` is in the xcodebuild command (it should be). |

### Note about WidgetKit import

If `LyricsStore.swift` fails to compile because it imports `WidgetKit` but the widget target doesn't exist yet, **temporarily comment out** or remove these lines until Phase 6:

```swift
// In LyricsStore.swift, comment out or remove:
// import WidgetKit
// ...and in the reloadWidget() method...
// WidgetCenter.shared.reloadAllTimelines()
```

---

## Step 4: Download the Artifact

Once the build completes successfully:

1. Go to the completed workflow run page on GitHub
2. Scroll down to the **Artifacts** section
3. Click on **Lyrico-ipa** to download
4. You'll get a `.zip` file containing `LyricsWidget.ipa`
5. Extract the `.ipa` — this is what you'll sideload in Phase 4

---

## Cost & Limits

| Aspect | Value |
|---|---|
| **Price** | $0 (public repo = unlimited free minutes) |
| macOS runner time | 10x multiplier on billing (but unlimited for public repos) |
| Typical build | 5-10 minutes |
| Artifact retention | 30 days (then auto-deleted) |
| Concurrent builds | 1 at a time (free tier) |

---

## Useful Commands

### Trigger a build manually (without pushing code):

1. GitHub → your repo → **Actions** tab
2. Click **"Build iOS App"** in the left sidebar
3. Click **"Run workflow"** → **"Run workflow"** button

### Check build status from VS Code:

If you installed the GitHub Actions extension:
- Look in the left sidebar for the GitHub Actions icon
- It shows running/completed/failed workflows

---

## Optional: Build Only on Manual Trigger

If you don't want builds on every push (to save resources), change the trigger:

```yaml
on:
  workflow_dispatch:   # only manual trigger, no auto-build on push
```

---

## What's Next

→ **[Phase 4: Sideloading via AltStore](./phase-4-sideloading.md)** — install the built app on your iPhone
