import QtQuick
import qs.common

Item {
    id: root

    property int fontSize: 18

    property date now: new Date()

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

    readonly property string clockText: formatClock(root.now)

    implicitWidth: clockLabel.implicitWidth
    implicitHeight: clockLabel.implicitHeight

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
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
