pragma Singleton

import QtQuick
import Quickshell.Services.UPower

// aggregates UPower signals — DisplayDevice and onBattery are wrong on some
// machines, so we fall through several independent checks before giving up
Singleton {
    id: root

    readonly property var display: UPower.displayDevice

    readonly property var primaryBattery: {
        const list = UPower.devices.values
        for (let i = 0; i < list.length; i++) {
            const d = list[i]
            if (d.isLaptopBattery && d.isPresent)
                return d
        }
        return null
    }

    readonly property var powerSource: primaryBattery ?? (display.ready ? display : null)

    readonly property bool showBattery: {
        if (primaryBattery)
            return primaryBattery.isPresent
        return display.ready && display.isPresent
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

    function devicePluggedIn(device) {
        if (!device || !device.ready)
            return false

        if (isChargingState(device.state))
            return true

        // quickshell: positive = charging, negative = discharging
        if (device.changeRate > 0.5)
            return true

        if (device.timeToFull > 0 && device.timeToEmpty <= 0)
            return true

        const icon = device.iconName ?? ""
        if (icon.includes("charging") || icon.includes("plugged") || icon.includes("ac-adapter"))
            return true

        return false
    }

    function linePowerOnline(device) {
        return device.type === UPowerDeviceType.LinePower
            && device.isPresent
            && device.powerSupply
    }

    readonly property bool pluggedIn: {
        // works on most systems — keep as first check
        if (!UPower.onBattery)
            return true

        const list = UPower.devices.values

        for (let i = 0; i < list.length; i++) {
            if (linePowerOnline(list[i]))
                return true
        }

        const pb = primaryBattery
        if (pb && devicePluggedIn(pb))
            return true

        if (display.ready && devicePluggedIn(display))
            return true

        for (let i = 0; i < list.length; i++) {
            const d = list[i]
            if (d.type === UPowerDeviceType.Battery && d.isPresent && devicePluggedIn(d))
                return true
        }

        return false
    }
}
