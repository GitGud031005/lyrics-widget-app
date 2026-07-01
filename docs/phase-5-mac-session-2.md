# Phase 5 — Mac Session #2: Widget Extension

> **Where:** Borrowed Mac  
> **Time:** ~1 hour  
> **Prerequisite:** Phase 4 complete (app successfully sideloaded and running)  
> **Goal:** Create the Widget Extension target in Xcode, enable App Groups on both targets, and push the scaffolding to GitHub

---

## Checklist

- [ ] Fetch the latest code onto the Mac
- [ ] Add the **Widget Extension** target in Xcode
- [ ] Create and enable the **App Group** capability on BOTH targets
- [ ] Verify the project builds and runs on your physical iPhone
- [ ] Commit and push the structural changes to GitHub

---

## Step 1: Sync Your Workspace on the Mac

1. Sit down at the borrowed Mac.
2. Open **Terminal** and navigate to your local repo folder:
   ```bash
   cd ~/Desktop/lyrics-widget-app
   ```
3. Pull the latest code (which now contains your Phase 2 & 3 files):
   ```bash
   git pull origin main
   ```
4. Open the project in Xcode:
   ```bash
   open LyricsWidget.xcodeproj
   ```

---

## Step 2: Add Files to project.pbxproj (If you haven't yet)

If you chose to wait and add the Swift files (created in Phase 2) via the Mac instead of hand-editing the workspace files on Windows:

1. Right-click on the `LyricsWidget` folder in Xcode's left Project Navigator.
2. Select **Add Files to "LyricsWidget"...**
3. Select the `Models/`, `Services/`, `Views/`, and `Storage/` directories.
4. Ensure **Copy items if needed** is **UNCHECKED** (since they are already in the directory).
5. Ensure **Create groups** is checked, and target **LyricsWidget** is checked.
6. Click **Add**.
7. Press `Cmd + B` to ensure Xcode compiles the project without errors.

---

## Step 3: Create the Widget Extension Target

1. Go to Xcode menu → **File** > **New** > **Target...**
2. In the template dialog, select the **iOS** tab, search for "widget", and select **Widget Extension**. Click **Next**.
3. Fill in the configuration:
   - **Product Name**: `LyricsWidgetExtension`
   - **Include Live Activity**: **Uncheck**
   - **Include Configuration Intent**: **Uncheck** (we will use our custom AppIntent)
4. Click **Finish**.
5. Xcode will ask if you want to activate the new scheme: **"Activate 'LyricsWidgetExtensionExtension' scheme?"** → click **Activate**.

Xcode will now generate a new folder in your project directory called `LyricsWidgetExtension` with files:
- `LyricsWidget.swift` (Contains sample code for a widget)
- `LyricsWidgetBundle.swift`
- `LyricsWidgetExtension.entitlements`

---

## Step 4: Configure App Groups (Crucial for Storage Sharing)

iOS apps and widget extensions run in separate sandboxes. To share data (so the widget can see what song you searched for in the app), we must register them in the same **App Group**.

### 1. Enable App Groups on the Main App Target
1. Select the root **LyricsWidget** project file in the left navigator.
2. Select the **LyricsWidget** target under Targets.
3. Click the **Signing & Capabilities** tab.
4. Click the **+ Capability** button in the top left.
5. Double-click **App Groups** in the list.
6. Scroll down to the newly added "App Groups" section.
7. Click the **+** button under App Groups.
8. Enter: `group.com.lyrico.LyricsWidget` and click **OK**.
9. Ensure the checkbox next to the group name is checked.

### 2. Enable App Groups on the Widget Extension Target
1. Under Targets, select the **LyricsWidgetExtension** target.
2. Click the **Signing & Capabilities** tab.
3. Click **+ Capability** → double-click **App Groups**.
4. You should see `group.com.lyrico.LyricsWidget` already in the list.
5. **Check the box** next to it to enable it for the extension.

---

## Step 5: Test Build on iPhone

1. Make sure your physical iPhone is connected and selected in the top bar.
2. Select the main **LyricsWidget** scheme in the top bar.
3. Press **▶ Run** (`Cmd + R`).
4. Once the app launches on your phone, go back to your Home Screen.
5. Long-press on an empty area of your Home Screen to enter "jiggle mode".
6. Tap the **+** button in the top-left corner.
7. Search for **LyricsWidget** (or **Lyrico**).
8. Add the widget to your home screen. It will show default dummy calendar/clock text — that means it's running Xcode's template code!

---

## Step 6: Commit and Push

1. Open Terminal on the Mac:
   ```bash
   cd ~/Desktop/lyrics-widget-app
   git add .
   git commit -m "add widget target with App Groups capability"
   git push origin main
   ```
2. You can now close Xcode. The remaining widget code, layout design, and interactive button scrolling will be written on Windows.

---

## What's Next

Now we return to Windows to replace the template widget code with our interactive lyrics scroller!

→ **[Phase 6: Shared Storage & Widget Code](./phase-6-widget-code.md)**
