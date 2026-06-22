import QtQuick
import Quickshell.Networking
import qs.icons

Item {
    id: root

    property int iconSize: 26

    readonly property var wifiDevice: Array.from(Networking.devices.values)
        .find(d => d.type === DeviceType.Wifi) ?? null

    readonly property var ethernetDevice: Array.from(Networking.devices.values)
        .find(d => d.type === DeviceType.Wired) ?? null

    readonly property bool onEthernet: ethernetDevice && ethernetDevice.connected

    readonly property var activeWifi: wifiDevice
        ? Array.from(wifiDevice.networks.values).find(n => n.connected) ?? null
        : null

    readonly property bool wifiConnecting: {
        const dev = wifiDevice
        if (!dev)
            return false
        return dev.state === ConnectionState.Connecting
            || dev.state === ConnectionState.Disconnecting
    }

    readonly property string wifiGlyph: {
        if (!Networking.wifiEnabled || !Networking.wifiHardwareEnabled)
            return "none"
        if (wifiConnecting)
            return "connecting"
        if (!activeWifi)
            return "none"
        const s = activeWifi.signalStrength
        if (s >= 0.75) return "high"
        if (s >= 0.50) return "medium"
        return "low"
    }

    readonly property bool showWifiIcon: !onEthernet && wifiDevice !== null
    readonly property bool showEthernetIcon: onEthernet
    readonly property bool showIcon: showWifiIcon || showEthernetIcon

    implicitWidth: showIcon ? iconSize : 0
    implicitHeight: iconSize

    Binding {
        target: wifiDevice
        property: "scannerEnabled"
        value: wifiConnecting
        when: wifiDevice !== null
    }

    WifiIcon {
        visible: root.showWifiIcon
        glyph: root.wifiGlyph
        size: root.iconSize
        anchors.centerIn: parent
    }

    TintedSvgIcon {
        visible: root.showEthernetIcon
        color: "white"
        size: root.iconSize
        source: Qt.resolvedUrl("../icons/assets/ethernet.svg")
        anchors.centerIn: parent
    }
}
