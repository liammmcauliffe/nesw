import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import "icons"

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.right: true

    implicitWidth: row.implicitWidth + sideMargin * 2
    implicitHeight: notchHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-clock"

    readonly property int notchHeight: 40
    readonly property int borderWidth: 6
    readonly property int sideMargin: 24
    readonly property int clockFontSize: 18

    mask: Region {}

    // battery — DisplayDevice/onBattery lie on some machines; fall through several checks
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

    function devicePluggedIn(device) {
        if (!device || !device.ready)
            return false

        if (isChargingState(device.state))
            return true

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

        if (batteryDisplay.ready && devicePluggedIn(batteryDisplay))
            return true

        for (let i = 0; i < list.length; i++) {
            const d = list[i]
            if (d.type === UPowerDeviceType.Battery && d.isPresent && devicePluggedIn(d))
                return true
        }

        return false
    }

    readonly property bool isLow: percentage < 0.15 && !pluggedIn

    readonly property string glyph: {
        if (percentage >= 0.90) return "full"
        if (percentage >= 0.60) return "high"
        if (percentage >= 0.30) return "medium"
        if (percentage >= 0.10) return "low"
        return "empty"
    }

    readonly property color batteryColor: {
        if (isLow)      return Colors.palette.m3error
        if (pluggedIn)  return "#4ade80"
        return "white"
    }

    // same tick-step animation as the notch workspace number
    property real minuteSlide: 0
    property bool clockReady: false

    function minuteIndex(d) {
        return Math.floor(d.getTime() / 60000)
    }

    function slideDuration(fromIdx, toIdx) {
        const dist = Math.abs(toIdx - fromIdx)
        if (dist === 0)
            return 0
        return Math.min(450, Math.max(60, dist * 40))
    }

    function animateToNow() {
        const target = minuteIndex(clock.date)
        if (Math.abs(minuteSlide - target) < 0.5) {
            minuteSlide = target
            return
        }

        minuteAnim.stop()
        minuteAnim.duration = slideDuration(Math.round(minuteSlide), target)
        minuteAnim.from = minuteSlide
        minuteAnim.to = target
        minuteAnim.start()
    }

    readonly property string clockText: Qt.formatDateTime(
        new Date(Math.round(minuteSlide) * 60000),
        "ddd MMM d  h:mm AP"
    )

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        onDateChanged: {
            if (!root.clockReady) {
                root.minuteSlide = root.minuteIndex(clock.date)
                root.clockReady = true
                return
            }
            root.animateToNow()
        }
    }

    NumberAnimation {
        id: minuteAnim
        target: root
        property: "minuteSlide"
        easing.type: Easing.Linear
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.rightMargin: root.sideMargin
        spacing: 28
        y: root.borderWidth + (root.notchHeight - root.borderWidth - height) / 2

        BatteryIcon {
            visible: root.showBattery
            glyph: root.glyph
            color: root.batteryColor
            shellColor: Colors.palette.m3onSurfaceVariant
            size: 32
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 300 } }
            Behavior on shellColor { ColorAnimation { duration: 300 } }
        }

        Text {
            id: clockLabel
            text: root.clockText
            color: "white"
            font.family: Fonts.family
            font.pixelSize: root.clockFontSize
            font.weight: Fonts.weightBaseline
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
