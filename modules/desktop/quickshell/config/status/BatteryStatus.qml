import QtQuick
import Quickshell.Services.UPower
import qs.icons

Item {
    id: root

    property int iconSize: 26

    readonly property var batteryDisplay: UPower.displayDevice

    readonly property var primaryBattery: {
        const list = UPower.devices.values
        for (let i = 0; i < list.length; i++) {
            const d = list[i]
            if (d.isLaptopBattery && d.isPresent)
                return d
        }
        return null
    }

    readonly property var powerSource: primaryBattery ?? (batteryDisplay.ready ? batteryDisplay : null)

    readonly property bool showBattery: {
        if (primaryBattery)
            return primaryBattery.isPresent
        return batteryDisplay.ready && batteryDisplay.isPresent
    }

    readonly property real percentage: {
        const src = powerSource
        return src ? src.percentage : 0
    }

    function isChargingState(state) {
        return state === UPowerDeviceState.Charging
            || state === UPowerDeviceState.PendingCharge
            || state === UPowerDeviceState.FullyCharged
    }

    function isDischargingState(state) {
        return state === UPowerDeviceState.Discharging
            || state === UPowerDeviceState.PendingDischarge
    }

    function pluggedInFromDevice(device) {
        if (!device || !device.ready)
            return null

        if (isChargingState(device.state))
            return true

        if (isDischargingState(device.state))
            return false

        return null
    }

    readonly property bool pluggedIn: {
        const pb = primaryBattery
        let onAc = pluggedInFromDevice(pb)
        if (onAc !== null)
            return onAc

        onAc = pluggedInFromDevice(batteryDisplay)
        if (onAc !== null)
            return onAc

        if (!batteryDisplay.ready)
            return false

        return !UPower.onBattery
    }

    readonly property string glyph: {
        if (percentage >= 0.90) return "full"
        if (percentage >= 0.60) return "high"
        if (percentage >= 0.30) return "medium"
        if (percentage >= 0.10) return "low"
        return "empty"
    }

    implicitWidth: showBattery ? iconSize : 0
    implicitHeight: iconSize

    BatteryIcon {
        visible: root.showBattery
        glyph: root.glyph
        charging: root.pluggedIn
        size: root.iconSize
        anchors.centerIn: parent
    }
}
