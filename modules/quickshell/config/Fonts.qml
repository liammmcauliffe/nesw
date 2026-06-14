pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // installed system-wide via fonts.packages (dm-sans)
    readonly property string family: "DM Sans"

    readonly property int sizeNotch: 21

    // Medium (500) is the baseline UI weight, not Regular
    readonly property int weightBaseline: Font.Medium
    readonly property int weightSemiBold: Font.DemiBold
    readonly property int weightBold: Font.Bold
}
