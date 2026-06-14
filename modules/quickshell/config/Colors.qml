pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick 2.15
import Quickshell
import Quickshell.Io

// the palette ships with dark defaults and is hot-reloaded from a generated
// scheme.json (e.g. produced by matugen/wallust) when present
Singleton {
    id: root

    readonly property Palette palette: current
    readonly property Palette current: Palette {}

    // path a color generator can write to. lives in a writable state dir so it
    // is independent of the read-only home-manager/nix config copy
    readonly property string schemePath: `${Quickshell.env("HOME")}/.local/state/nesw/scheme.json`

    // parse a scheme file of the form { "colors": { "primary": "rrggbb", ... } }
    // (also accepts "colours" from external generators; unprefixed keys, optional '#')
    function load(data: string): void {
        if (!data)
            return;

        let scheme;
        try {
            scheme = JSON.parse(data);
        } catch (e) {
            return;
        }

        const colors = scheme.colors ?? scheme.colours ?? scheme;
        for (const name in colors) {
            const propName = name.startsWith("m3") ? name : `m3${name}`;
            if (!current.hasOwnProperty(propName))
                continue;
            const value = colors[name];
            current[propName] = value.startsWith("#") ? value : `#${value}`;
        }
    }

    FileView {
        path: root.schemePath
        watchChanges: true
        printErrors: false // scheme.json is optional; defaults are used if absent
        onFileChanged: reload()
        onLoaded: root.load(text())
    }

    component Palette: QtObject {
        // neutral dark baseline — muted zinc/slate, no wallpaper tint.
        // scheme.json still overrides these when matugen/wallust is wired up.
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
