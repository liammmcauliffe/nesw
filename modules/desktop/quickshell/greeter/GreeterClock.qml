import QtQuick
import qs.common

Item {
    id: root

    property date now: new Date()

    readonly property string timeText: formatTime(root.now)
    readonly property string dateText: formatDate(root.now)

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    function formatTime(d): string {
        const hours = String(d.getHours()).padStart(2, "0");
        const minutes = String(d.getMinutes()).padStart(2, "0");
        return hours + ":" + minutes;
    }

    function formatDate(d): string {
        const days = [
            "Sunday", "Monday", "Tuesday", "Wednesday",
            "Thursday", "Friday", "Saturday",
        ];
        const months = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December",
        ];
        return days[d.getDay()] + ", " + months[d.getMonth()] + " " + d.getDate();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Column {
        id: column
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.timeText
            color: "white"
            font.family: Fonts.family
            font.pixelSize: 96
            font.weight: Fonts.weightBold
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.dateText
            color: "white"
            font.family: Fonts.family
            font.pixelSize: 24
            font.weight: Fonts.weightBaseline
        }
    }
}
