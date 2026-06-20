import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import Quickshell.Networking
import "icons"

// TODO: separate clock, battery, and network stuff into separate components
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
    readonly property int borderWidth: Constants.borderWidth
    readonly property int sideMargin: 24
    readonly property int clockFontSize: 18

    Item {
        id: hitMask
        anchors.fill: parent
        visible: false
    }

    mask: Region {
        item: hitMask
    }

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
        if (pluggedIn)
            return "charging"
        if (percentage >= 0.90) return "full"
        if (percentage >= 0.60) return "high"
        if (percentage >= 0.30) return "medium"
        if (percentage >= 0.10) return "low"
        return "empty"
    }

    readonly property var wifiDevice: {
        const list = Networking.devices.values
        for (let i = 0; i < list.length; i++) {
            if (list[i].type === DeviceType.Wifi)
                return list[i]
        }
        return null
    }

    readonly property var ethernetDevice: {
        const list = Networking.devices.values
        for (let i = 0; i < list.length; i++) {
            if (list[i].type === DeviceType.Wired)
                return list[i]
        }
        return null
    }

    readonly property bool onEthernet: ethernetDevice && ethernetDevice.connected

    readonly property var activeWifi: {
        const dev = wifiDevice
        if (!dev)
            return null
        const nets = dev.networks.values
        for (let i = 0; i < nets.length; i++) {
            if (nets[i].connected)
                return nets[i]
        }
        return null
    }

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

    Binding {
        target: wifiDevice
        property: "scannerEnabled"
        value: wifiConnecting
        when: wifiDevice !== null
    }

    readonly property bool showWifiIcon: !onEthernet && wifiDevice !== null
    readonly property bool showEthernetIcon: onEthernet

    property var now: new Date()
    property real minuteSlide: 0
    property bool clockReady: false

    function minuteIndex(d) {
        return Math.floor(d.getTime() / 60000)
    }

    function formatClock(d) {
        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let hours = d.getHours()
        const ampm = hours >= 12 ? "PM" : "AM"
        hours = hours % 12
        if (hours === 0)
            hours = 12
        const mm = String(d.getMinutes()).padStart(2, "0")
        return days[d.getDay()] + " " + months[d.getMonth()] + " " + d.getDate()
            + "  " + hours + ":" + mm + " " + ampm
    }

    function slideDuration(fromIdx, toIdx) {
        const dist = Math.abs(toIdx - fromIdx)
        if (dist === 0)
            return 0
        return Math.min(450, Math.max(60, dist * 40))
    }

    function animateToNow() {
        const target = minuteIndex(now)
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

    readonly property string clockText: formatClock(
        clockReady
            ? new Date(Math.round(minuteSlide) * 60000)
            : now
    )

    Timer {
        id: minuteTimer
        interval: 60000 - (Date.now() % 60000) + 50
        running: true
        repeat: true
        onTriggered: {
            interval = 60000
            now = new Date()
            if (!root.clockReady) {
                root.minuteSlide = root.minuteIndex(now)
                root.clockReady = true
                return
            }
            root.animateToNow()
        }
    }

    Component.onCompleted: {
        now = new Date()
        minuteSlide = minuteIndex(now)
        clockReady = true
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

        Item {
            id: networkIcon
            visible: root.showWifiIcon || root.showEthernetIcon
            width: 26
            height: 26
            anchors.verticalCenter: parent.verticalCenter

            WifiIcon {
                visible: root.showWifiIcon
                glyph: root.wifiGlyph
                size: 26
                anchors.centerIn: parent
            }

            TintedSvgIcon {
                visible: root.showEthernetIcon
                color: "white"
                size: 26
                source: Qt.resolvedUrl("icons/assets/ethernet.svg")
                anchors.centerIn: parent
            }
        }

        BatteryIcon {
            visible: root.showBattery
            glyph: root.glyph
            size: 26
            anchors.verticalCenter: parent.verticalCenter
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
