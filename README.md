# Deepin — Focus, Visualized

A minimalist iOS app that transforms your screen time into a living, breathing sphere. The more you focus, the brighter it glows. The more you drift, the more it fades.

---

## Overview

Deepin is built on a simple idea: **what if you could see your focus?**

Instead of numbers and charts, Deepin gives you a dynamic sphere that reflects your mental state in real time. It reacts to how much time you spend on distracting apps — decaying visually as distraction grows, glowing when you're deep in focus.

---

## Features

- **Dynamic Sphere** — A living visual that decays with distraction and glows with focus
- **Depth Score** — A proprietary formula that weighs focus time against distraction time
- **Focus Sessions** — Built-in timer with live comparison vs. distraction
- **App Shielding** — Blocks distracting apps when you hit your daily limit
- **Home Screen Widget** — Small and medium widgets showing your current focus state
- **Dynamic Island** — Live Activity that updates as your session progresses
- **Weekly Report** — Every Sunday, a summary of your week's depth
- **Daily Note** — A one-sentence reflection saved with each day's record
- **Bilingual** — Full Arabic and English support with carefully chosen terminology
- **Custom Goals** — Set your own focus goal and distraction limit

---

## Technical Architecture
Deepin.xcodeproj
├── Deepin                    # Main App Target (SwiftUI)
├── DeepinMonitor             # DeviceActivity Extension
├── DeepinWidget              # WidgetKit + Live Activities
└── DeepinShield              # Shield Configuration Extension

### Key Frameworks
- **FamilyControls** — Authorization and app selection
- **DeviceActivity** — Usage monitoring and threshold events  
- **ManagedSettings** — App shielding when limits are exceeded
- **WidgetKit** — Home screen widgets
- **ActivityKit** — Dynamic Island Live Activities
- **SwiftUI** — All UI, including dynamic animations

### Data Flow
DeviceActivity → SharedDataManager (App Group) → FocusMonitor → DeepSphere
→ WidgetKit
→ Live Activity

---

## Depth Score Formula

Deepin uses a custom formula to calculate focus quality:
focusProgress   = focusMinutes / focusGoal
distractionRate = distractionMinutes / distractionLimit
base    = (focusProgress × 0.6) + ((1 - distractionRate) × 0.4)
penalty = exceeding distraction limit → up to -0.50
bonus   = achieving focus goal → up to +0.10
Depth Score = clamp(base - penalty + bonus, 0.0, 1.0)
Decay Level = 1.0 - Depth Score

---

## Sphere States

| Depth Score | State | Arabic |
|---|---|---|
| 80–100% | Deep Focus | تركيز |
| 60–79% | Focused | — |
| 40–59% | Balanced | شارد |
| 20–39% | Drifting | مشوش |
| 0–19% | Lost | متشتت |

---

## Requirements

- iOS 17.0+
- Xcode 16+
- Apple Developer Account
- FamilyControls Entitlement (individual use)

---

## Built With

- Swift 5.9
- SwiftUI
- Combine
- FamilyControls / DeviceActivity / ManagedSettings
- WidgetKit / ActivityKit

---

## Author

**Hamad Alsultan**  
[GitHub](https://github.com/HSSTDA)

---

## License
This project is a personal initiative — built to serve a real need, 
and a hands-on journey into iOS development. Every line of code 
was a lesson.
