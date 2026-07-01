# Phase 4 — Sideloading via AltStore

> **Where:** Windows PC & iPhone  
> **Time:** ~30 minutes  
> **Prerequisite:** Phase 1 (AltServer setup) & Phase 3 (Downloaded `.ipa` file) complete  
> **Goal:** Sideload the generated unsigned `.ipa` to your iPhone using AltStore

---

## Checklist

- [ ] Connect iPhone to Windows PC via USB
- [ ] Install AltStore to iPhone (if not already done)
- [ ] Trust the developer certificate on iPhone
- [ ] Transfer the `.ipa` file to your iPhone
- [ ] Install the `.ipa` via AltStore
- [ ] Verify the app launches and works

---

## Step 1: Install AltStore on your iPhone

If AltStore is already running on your iPhone, you can skip to **Step 3**. Otherwise:

1. Connect your iPhone to your Windows PC using the USB data cable.
2. Open **iTunes** on your PC to verify the device is recognized.
   - If iTunes asks, click **Trust this computer** and enter your passcode on the iPhone.
   - In iTunes, select your device icon near the top-left, and under **Options**, check the box for **Sync with this iPhone over Wi-Fi**. Click **Apply**.
3. Locate the **AltServer** icon in your Windows system tray (bottom-right).
4. Click the AltServer icon → hover over **Install AltStore** → select your **iPhone**.
5. Enter your **Apple ID** and **Password**.
   - *Note: These credentials are sent directly to Apple's servers to request a development certificate. If you use Two-Factor Authentication, you will receive a verification code on your phone to enter into AltServer.*
6. A notification will appear on Windows stating that AltStore is installing. Wait about 1-2 minutes until you see the success message.
7. The **AltStore** icon will now appear on your iPhone's home screen.

---

## Step 2: Trust the Profile on iPhone

Before opening AltStore for the first time:

1. Open **Settings** on your iPhone.
2. Go to **General** > **VPN & Device Management**.
3. Under **Developer App**, tap on your **Apple ID Email**.
4. Tap **Trust "[your email]"** and confirm by tapping **Trust** again.
5. You can now open the AltStore app on your iPhone.

---

## Step 3: Transfer the `.ipa` to iPhone

Since you downloaded the `.zip` file from GitHub Actions on your PC, you need to get the `.ipa` onto your iPhone:

**Method A: Direct Download on iPhone (Easiest)**
1. Open Safari on your iPhone.
2. Go to `https://github.com/YOUR_GITHUB_USERNAME/lyrics-widget-app/actions`.
3. Sign in to GitHub and tap on your latest completed build.
4. Scroll to the bottom, tap **Lyrico-ipa** to download it.
5. Open the **Files** app on iPhone, go to **Downloads**, and tap the downloaded `Lyrico-ipa.zip` file to extract the `.ipa` file.

**Method B: Local Network Share / Email**
1. Unzip the file on your PC to extract `LyricsWidget.ipa`.
2. Email the `.ipa` file to yourself as an attachment, or save it to a cloud drive (Google Drive, iCloud Drive, OneDrive).
3. Open the corresponding app (Mail, Drive) on your iPhone and save the `.ipa` to your local **Files** app.

---

## Step 4: Sideload Lyrico via AltStore

1. Open **AltStore** on your iPhone.
2. Tap the **My Apps** tab at the bottom.
3. Tap the **+** button in the top-left corner.
4. Select the `LyricsWidget.ipa` file you transferred in Step 3.
5. If this is your first time using AltStore to sideload, it will ask you to sign in with your Apple ID and password again.
6. AltStore will begin installing the app. A progress bar will appear at the top.
7. Once finished, **Lyrico** will appear under **Active Apps** inside AltStore, and the app icon will show up on your iPhone's Home Screen.

---

## Step 5: Test the App

1. Launch **Lyrico** from your home screen.
2. Search for any song (e.g., "Bohemian Rhapsody" or "Blinding Lights").
3. Verify that:
   - Search results load successfully from the LRCLIB API.
   - Tapping on a song displays the full lyric lines.
   - Tapping "Set as Widget Lyrics" saves it (shows success toast).

---

## Troubleshooting

### "AltServer could not be found"
- Make sure AltServer is running in your Windows tray.
- Verify your iPhone is on the **same Wi-Fi network** as your PC.
- If it still fails, connect the iPhone via USB cable to perform the install.

### "App exceeds maximum App ID limit"
- Free developer accounts are limited to **10 App IDs** active per week. If you have built too many test apps recently, you will need to wait for them to expire (usually shown in AltStore under My Apps) or use the same Bundle ID.

---

## What's Next

Now that the core application works on your device, we are ready to introduce the Home Screen Widget target!

→ **[Phase 5: Mac Session #2 — Widget Target Setup](./phase-5-mac-session-2.md)**
