# Epoxy Vision — iOS App

**Native Swift/iOS app** for the Epoxy Visualizer. Installer-facing mobile app.

## This repo = iOS only

- **Swift/Xcode** — native iOS app
- No web frontend, no React, no Expo

## Related repos

| Repo | Contents |
|------|----------|
| [epoxy-visualizer](https://github.com/KBPUBLISH/epoxy-visualizer) | Web app (React/Vite) + Admin panel + Backend (Node/Express) |
| **EpoxyVisionSwift** (this repo) | iOS app only |

Both apps use the same backend API (hosted on Render).

## Setup

1. Open `ios/EpoxyVisualize.xcodeproj` in Xcode
2. Set the API base URL in `Config.swift` (or use the default)
3. Build and run on a device or simulator
