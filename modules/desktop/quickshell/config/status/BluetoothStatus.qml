import QtQuick
import Quickshell.Bluetooth
import qs.icons

Item {
    id: root

    property int iconSize: 26

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    readonly property var adapterDevices: root.adapter
        ? Array.from(root.adapter.devices.values)
        : []

    readonly property bool hasConnectedDevice: root.adapterDevices.some(d => d.connected)

    readonly property bool isBusy: {
        const adp = root.adapter
        if (!adp)
            return false
        if (adp.discovering)
            return true
        return root.adapterDevices.some(d =>
            d.pairing || d.state === BluetoothDevice.Connecting)
    }

    readonly property string glyph: {
        const adp = root.adapter
        if (!adp || !adp.enabled
                || adp.state === BluetoothAdapter.Disabled
                || adp.state === BluetoothAdapter.Blocked)
            return "off"
        if (root.hasConnectedDevice)
            return "connected"
        if (root.isBusy)
            return "searching"
        return "on"
    }

    readonly property bool showIcon: root.adapter !== null

    implicitWidth: showIcon ? iconSize : 0
    implicitHeight: iconSize

    BluetoothIcon {
        visible: root.showIcon
        glyph: root.glyph
        size: root.iconSize
        anchors.centerIn: parent
    }
}
