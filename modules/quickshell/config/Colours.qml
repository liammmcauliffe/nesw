pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Material 3 colour scheme, modelled on caelestia's services/Colours.qml.
// The palette ships with sane dark defaults and is hot-reloaded from a
// generated scheme.json (e.g. produced by matugen/wallust) when present, so
// colours can follow the wallpaper without touching any consumer code.
Singleton {
    id: root

    readonly property Palette palette: current
    readonly property Palette current: Palette {}

    // Path a colour generator can write to. Lives in a writable state dir so it
    // is independent of the read-only home-manager/nix config copy.
    readonly property string schemePath: `${Quickshell.env("HOME")}/.local/state/nesw/scheme.json`

    // Parse a scheme file of the form { "colours": { "primary": "rrggbb", ... } }
    // (a leading '#' on values is optional) and apply it over the palette.
    function load(data: string): void {
        if (!data)
            return;

        let scheme;
        try {
            scheme = JSON.parse(data);
        } catch (e) {
            return;
        }

        const colours = scheme.colours ?? scheme;
        for (const name in colours) {
            if (!current.hasOwnProperty(name))
                continue;
            const value = colours[name];
            current[name] = value.startsWith("#") ? value : `#${value}`;
        }
    }

    FileView {
        path: root.schemePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text())
    }

    component Palette: QtObject {
        property color primary: "#ffb0ca"
        property color onPrimary: "#541d34"
        property color primaryContainer: "#6f334a"
        property color onPrimaryContainer: "#ffd9e3"

        property color secondary: "#e2bdc7"
        property color onSecondary: "#422932"
        property color secondaryContainer: "#5a3f48"
        property color onSecondaryContainer: "#ffd9e3"

        property color tertiary: "#f0bc95"
        property color onTertiary: "#48290c"

        property color background: "#191114"
        property color onBackground: "#efdfe2"

        property color surface: "#191114"
        property color onSurface: "#efdfe2"
        property color surfaceContainerLowest: "#130c0e"
        property color surfaceContainerLow: "#22191c"
        property color surfaceContainer: "#261d20"
        property color surfaceContainerHigh: "#31282a"
        property color surfaceContainerHighest: "#3c3235"
        property color surfaceVariant: "#514347"
        property color onSurfaceVariant: "#d5c2c6"

        property color outline: "#9e8c91"
        property color outlineVariant: "#514347"

        property color error: "#ffb4ab"
        property color onError: "#690005"

        property color shadow: "#000000"
        property color scrim: "#000000"
    }
}
