pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Quickshell.Singleton {
    id: root

    readonly property Palette palette: current
    readonly property Palette current: Palette {}

    component Palette: QtObject {
        property color m3primary: "#e4e4e7"
        property color m3onPrimary: "#18181b"
        property color m3primaryContainer: "#3f3f46"
        property color m3onPrimaryContainer: "#f4f4f5"

        property color m3secondary: "#a1a1aa"
        property color m3onSecondary: "#27272a"
        property color m3secondaryContainer: "#3f3f46"
        property color m3onSecondaryContainer: "#d4d4d8"

        property color m3tertiary: "#71717a"
        property color m3onTertiary: "#fafafa"

        property color m3background: "#09090b"
        property color m3onBackground: "#fafafa"

        property color m3surface: "#09090b"
        property color m3onSurface: "#fafafa"
        property color m3surfaceContainerLowest: "#09090b"
        property color m3surfaceContainerLow: "#18181b"
        property color m3surfaceContainer: "#1c1c1f"
        property color m3surfaceContainerHigh: "#27272a"
        property color m3surfaceContainerHighest: "#3f3f46"
        property color m3surfaceVariant: "#3f3f46"
        property color m3onSurfaceVariant: "#a1a1aa"

        property color m3outline: "#52525b"
        property color m3outlineVariant: "#3f3f46"

        property color m3error: "#f87171"
        property color m3onError: "#450a0a"

        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
    }
}
