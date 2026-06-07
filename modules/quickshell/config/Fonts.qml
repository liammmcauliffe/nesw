pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string fontsDir: Quickshell.env("HOME") + "/.local/share/fonts"
    readonly property string fontsSubdir: fontsDir + "/satoshi"

    readonly property int sizeNotch: 18
    readonly property int weightBlack: Font.Black
    readonly property int weightBold: Font.Bold
    readonly property int weightRegular: Font.Normal

    function fontUrl(dir, file) {
        return "file://" + dir + "/" + file
    }

    FontLoader { id: blackFlat; source: fontUrl(fontsDir, "Satoshi-Black.otf") }
    FontLoader { id: blackNested; source: fontUrl(fontsDir, "Satoshi-Black.otf") }
    FontLoader { id: boldFlat; source: fontUrl(fontsDir, "Satoshi-Bold.otf") }
    FontLoader { id: boldNested; source: fontUrl(fontsSubdir, "Satoshi-Bold.otf") }
    FontLoader { id: regularFlat; source: fontUrl(fontsDir, "Satoshi-Regular.otf") }
    FontLoader { id: regularNested; source: fontUrl(fontsSubdir, "Satoshi-Regular.otf") }

    readonly property bool ready:
        blackFlat.status === FontLoader.Ready
        || blackNested.status === FontLoader.Ready
        || boldFlat.status === FontLoader.Ready
        || boldNested.status === FontLoader.Ready
        || regularFlat.status === FontLoader.Ready
        || regularNested.status === FontLoader.Ready

    readonly property string family: {
        if (blackFlat.status === FontLoader.Ready)
            return blackFlat.name
        if (blackNested.status === FontLoader.Ready)
            return blackNested.name
        if (boldFlat.status === FontLoader.Ready)
            return boldFlat.name
        if (boldNested.status === FontLoader.Ready)
            return boldNested.name
        if (regularFlat.status === FontLoader.Ready)
            return regularFlat.name
        if (regularNested.status === FontLoader.Ready)
            return regularNested.name
        return "Satoshi"
    }
}
