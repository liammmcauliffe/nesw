import QtQuick
import common

Item {
    id: root

    property int fontSize: 18

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

    implicitWidth: clockLabel.implicitWidth
    implicitHeight: clockLabel.implicitHeight

    Timer {
        id: minuteTimer
        interval: 60000 - (Date.now() % 60000) + 50
        running: true
        repeat: true
        onTriggered: {
            interval = 60000
            root.now = new Date()
            if (!root.clockReady) {
                root.minuteSlide = root.minuteIndex(root.now)
                root.clockReady = true
                return
            }
            root.animateToNow()
        }
    }

    Component.onCompleted: {
        root.now = new Date()
        root.minuteSlide = root.minuteIndex(root.now)
        root.clockReady = true
    }

    NumberAnimation {
        id: minuteAnim
        target: root
        property: "minuteSlide"
        easing.type: Easing.Linear
    }

    Text {
        id: clockLabel
        text: root.clockText
        color: "white"
        font.family: Fonts.family
        font.pixelSize: root.fontSize
        font.weight: Fonts.weightBaseline
        anchors.centerIn: parent
    }
}
