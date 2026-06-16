pragma Singleton

import QtQuick

QtObject {
    readonly property real viewBox: 200
    // artwork sits inset inside the 200×200 viewBox — bump uniformly to fill the slot
    readonly property real artScale: 1.15
}
