# Lyrico — UI/UX Redesign Specification & Feature Brief

This document outlines the **functional intentions** and **technical constraints** of the Lyrico ecosystem (an iOS app + interactive home screen widget). It focuses on *what* the user needs to achieve and *why*, leaving visual styling, layouts, components, and design systems entirely open for the design agent to define.

---

## 📖 App & Ecosystem Overview

Lyrico allows users to search for song lyrics, customize the widget's appearance, and display a manual lyric prompt or karaoke guide on their Home Screen. The widget allows users to step through lyric lines line-by-line using interactive controls.

### System Integration
*   **The iOS Host App:** Core hub for searching, reviewing lyrics, and configuring options.
*   **The Home Screen Widget:** A glanceable viewport on the iOS home screen displaying the current lyrics.
*   **Shared State:** An App Group (`UserDefaults`) holds the active song, user preferences, and current line position. Changes in the app must sync instantly to the widget.

---

## 🎨 Intent of Customization Tokens

The design agent has complete freedom to define the theme architecture, palettes, and typography. The underlying system supports:

1.  **Background Theme:** A way to set the overall backdrop color/style of the widget.
2.  **Muted Text Style:** The base styling for surrounding/contextual lyric lines.
3.  **Highlighted Text Style:** A distinct visual treatment for the currently active lyric line.
4.  **Text Sizing:** A user-controlled scaling factor for reading accessibility.
5.  **Line Capacity:** A control specifying how many concurrent lines of text the user wants to see on their widget.

---

## 📱 App Screen Intentions

### 1. Search Screen (`LyricsSearchView`)
*   **Core Goal:** Help users find a specific song's lyrics as fast as possible.
*   **User Intentions & States:**
    *   *Idle/Welcome State:* Guide users on what to do. Show the song currently active on the widget.
    *   *Search Input:* An entry field to type song or artist names.
    *   *Loading Feedback:* A clear indication that a search is in progress.
    *   *Results Feed:* Displays matching songs with indicators distinguishing **synced (timestamped) lyrics** from **plain text (static) lyrics**, alongside song duration.
    *   *Errors & Empty States:* Friendly feedback if no results are found or if the network request fails, with an easy option to retry.

### 2. Lyrics Display Screen (`LyricsDisplayView`)
*   **Core Goal:** Review song details, preview/select the lyric starting point, and deploy the lyrics to the widget.
*   **User Intentions & States:**
    *   *Song Identity:* Clearly display metadata (Track, Artist, Album, Duration, Lyrics Type).
    *   *Lyric Review View:* 
        *   For **synced lyrics**: Allow the user to scroll through, tap any line to set it as the active line, and view timestamp timings.
        *   For **plain text**: Renders the complete, static lyrics.
    *   *Activation Trigger:* A prominent control to set the selected song and active line as the live widget content.
    *   *Success Confirmation:* Immediate, clear visual feedback when the lyrics are successfully sent to the widget.

### 3. Settings Screen (`SettingsView`)
*   **Core Goal:** Customize the look and feel of the widget and verify the setup.
*   **User Intentions & States:**
    *   *Real-time Preview:* An interactive mockup of the widget showing how the chosen style settings (colors, size, visible lines) will look on the Home Screen.
    *   *Quick Styling Presets:* One-tap theme selections (e.g., pre-built color pairings).
    *   *Manual Adjustments:* Controls to manually configure color codes, adjust font size limits, and select how many lines of context to display.
    *   *Diagnostics:* A subtle confirmation showing if the app-to-widget shared storage connection is functional.

---

## 🎛️ Widget Intentions (`LyricsWidgetEntryView`)

The widget acts as a glanceable, manual prompt. It supports three layout containers: **Small**, **Medium**, and **Large**.

### 1. Small Widget (`systemSmall`)
*   **Intent:** A tiny, glanceable window. Shows only a minimal subset of lyric lines with the active line visually distinct. Renders no control buttons due to space restrictions.

### 2. Medium & Large Widgets (`systemMedium`, `systemLarge`)
*   **Intent:** Richer context and control.
*   **Layout Intentions:**
    *   *Header:* Keep the user oriented by displaying the song and artist name.
    *   *Lyrics Viewport:* Displays the currently highlighted lyric line surrounded by preceding/succeeding lines for context. The active line **must** be visually separated (e.g., via color, scale, weight, or backing fill) to guide the reader's eye.
    *   *Manual Stepper Controls:* A set of three controls that allow the user to step **Forward** to the next line, **Backward** to the previous line, or **Reset** to the song's beginning. These inputs trigger instantly on the device.

---

## ⚙️ Technical Constraints

*   **Size Limits:** Layouts must fit iOS widget frames: Small (148x148 pt), Medium (322x148 pt), and Large (322x324 pt). 
*   **Text Safety:** Text must truncate cleanly when lines exceed frame boundaries; clipping or wrapping onto hidden lines is unacceptable.
*   **Animation Restrictions:** iOS widgets do not support continuous live animations or video. Layout states must render statically based on configuration values.
