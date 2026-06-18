import Quickshell

// Quickshell root entry point. Each child is a top-level overlay component.
// To add a new UI surface: create a QML file in this directory, then list it here.
// Shared styling comes from Colors.qml (palette) and Fonts.qml (typography).
ShellRoot {
    TopBar {}
    Border {}
    Notch {}
    Clock {}
    Launcher {}
    Logout {}
}
