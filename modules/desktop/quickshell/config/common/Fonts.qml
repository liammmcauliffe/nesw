pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property string family: "DM Sans"

    readonly property int sizeNotch: 18

    readonly property int weightBaseline: Font.Medium
    readonly property int weightSemiBold: Font.DemiBold
    readonly property int weightBold: Font.Bold
}
