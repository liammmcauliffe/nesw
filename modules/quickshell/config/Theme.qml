pragma Singleton

import Quickshell

// Placeholder palette using Material-You-style role names so it can later be
// swapped for a generated scheme without touching consumers.
Singleton {
    id: theme

    // Accent / highlight
    readonly property color primary: "#9FC0FF"
    readonly property color onPrimary: "#10243E"

    // Surfaces
    readonly property color surface: "#0E0E0E"
    readonly property color surfaceContainer: "#1B1B1B"

    // Foreground text / lines
    readonly property color onSurface: "#E6E6E6"
    readonly property color onSurfaceVariant: "#9BA0A6"
    readonly property color outline: "#5A5F66"
}
