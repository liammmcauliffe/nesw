pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Material 3 colour scheme, modelled on caelestia's services/Colours.qml.
// Roles are prefixed with `m3` (e.g. m3primary, m3onSurface) because QML treats
// identifiers starting with `on` + a capital letter as signal handlers, which
// is why caelestia uses this prefix too.
// The palette ships with dark defaults and is hot-reloaded from a generated
// scheme.json (e.g. produced by matugen/wallust) when present.
Singleton {
    id: root

    readonly property Palette palette: current
    readonly property Palette current: Palette {}

    // Path a colour generator can write to. Lives in a writable state dir so it
    // is independent of the read-only home-manager/nix config copy.
    readonly property string schemePath: `${Quickshell.env("HOME")}/.local/state/nesw/scheme.json`

    // Parse a scheme file of the form { "colours": { "primary": "rrggbb", ... } }
    // (unprefixed keys, a leading '#' on values is optional) and apply it.
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
            const propName = name.startsWith("m3") ? name : `m3${name}`;
            if (!current.hasOwnProperty(propName))
                continue;
            const value = colours[name];
            current[propName] = value.startsWith("#") ? value : `#${value}`;
        }
    }

    FileView {
        path: root.schemePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text())
    }

    component Palette: QtObject {
        property color m3primary: "#ffb0ca"
        property color m3onPrimary: "#541d34"
        property color m3primaryContainer: "#6f334a"
        property color m3onPrimaryContainer: "#ffd9e3"

        property color m3secondary: "#e2bdc7"
        property color m3onSecondary: "#422932"
        property color m3secondaryContainer: "#5a3f48"
        property color m3onSecondaryContainer: "#ffd9e3"

        property color m3tertiary: "#f0bc95"
        property color m3onTertiary: "#48290c"

        property color m3background: "#191114"
        property color m3onBackground: "#efdfe2"

        property color m3surface: "#191114"
        property color m3onSurface: "#efdfe2"
        property color m3surfaceContainerLowest: "#130c0e"
        property color m3surfaceContainerLow: "#22191c"
        property color m3surfaceContainer: "#261d20"
        property color m3surfaceContainerHigh: "#31282a"
        property color m3surfaceContainerHighest: "#3c3235"
        property color m3surfaceVariant: "#514347"
        property color m3onSurfaceVariant: "#d5c2c6"

        property color m3outline: "#9e8c91"
        property color m3outlineVariant: "#514347"

        property color m3error: "#ffb4ab"
        property color m3onError: "#690005"

        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
    }
}
