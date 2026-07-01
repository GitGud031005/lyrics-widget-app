# Phase 5 — Windows: Widget Target Setup (No-Mac Route)

> **Where:** Windows PC  
> **Prerequisite:** Phase 4 complete (app successfully sideloaded and running)  
> **Goal:** Create the Widget Extension target, configure App Groups manually inside the project database (`project.pbxproj`), and enable sharing entitlements on Windows.

---

## Overview

Usually, adding targets and enabling capabilities like **App Groups** requires Xcode on macOS. However, we can bypass the Mac completely by manually creating the entitlement XML files and adding target configurations directly into the OpenStep plist structure of `project.pbxproj` on Windows. 

When you push these files, the macOS runner in GitHub Actions compiles both targets into a single `.ipa` bundle, and AltStore signs both the app and the widget dynamically when installing on your iPhone.

---

## Step 1: Create App Group Entitlement Files

Both the main app and the widget extension must belong to the same **App Group** to share settings and active lyrics (since they run in separate iOS sandboxes). We enable this by creating `.entitlements` files.

### 1. Create Main App Entitlements
Create file: `LyricsWidget/LyricsWidget.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.lyrico.LyricsWidget</string>
	</array>
</dict>
</plist>
```

### 2. Create Widget Extension Entitlements
Create file: `LyricsWidgetExtension/LyricsWidgetExtension.entitlements`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.lyrico.LyricsWidget</string>
	</array>
</dict>
</plist>
```

---

## Step 2: Configure Widget target in project.pbxproj

To tell the Xcode build system about the new `LyricsWidgetExtension` target, we register it inside `LyricsWidget.xcodeproj/project.pbxproj`.

This involves adding:
1. **PBXFileReference** entries for the widget files (timeline provider, intents, view) and the `.appex` bundle product.
2. **PBXNativeTarget** to define the `LyricsWidgetExtension` target (product type: `com.apple.product-type.app-extension`).
3. **PBXCopyFilesBuildPhase** (Embed App Extensions) inside the main `LyricsWidget` target to embed the compiled `.appex` in the main app's `PlugIns` directory.
4. **PBXTargetDependency** and **PBXContainerItemProxy** settings to compile the widget target prior to packaging the main app.
5. **XCBuildConfiguration** blocks for the widget target including target configurations for **Debug** and **Release** that point to our custom `CODE_SIGN_ENTITLEMENTS` file.

---

## Step 3: Write Widget Source Code

Create the files inside `LyricsWidgetExtension/` for the widget implementation:
* `LyricsWidget.swift` (Widget Configuration Entrypoint)
* `LyricsWidgetBundle.swift` (Widget bundle loop)
* `LyricsWidgetIntents.swift` (App Intents for button taps)
* `LyricsTimelineProvider.swift` (Widget lifecycle & timeline events)
* `LyricsWidgetEntryView.swift` (Widget layout & buttons)

*(Note: We implement these files in Phase 6).*

---

## Step 4: Verify, Commit, and Push

1. Stage all changes on Windows:
   ```powershell
   git add .
   ```
2. Commit the new target configurations:
   ```powershell
   git commit -m "feat: configure widget target and app group entitlements"
   ```
3. Push to GitHub to trigger compilation:
   ```powershell
   git push origin main
   ```
4. Verify the GitHub Actions build compiles both targets without errors.

---

## What's Next

Now we proceed directly to writing the interactive widget code on Windows.

→ **[Phase 6: Shared Storage & Widget Code](./phase-6-widget-code.md)**
