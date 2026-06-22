pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property var targetList
    property var onClose
    property var onAccept
    property bool enabled: true

    Keys.onPressed: function (event) {
        root.press(event)
    }

    function press(event) {
        if (!root.enabled || !event)
            return

        const list = root.targetList
        if (!list)
            return

        if (event.key === Qt.Key_Escape) {
            if (root.onClose)
                root.onClose()
            event.accepted = true
        } else if (event.key === Qt.Key_Space && (event.modifiers & Qt.MetaModifier)) {
            if (root.onClose)
                root.onClose()
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            list.currentIndex = Math.max(0, list.currentIndex - 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.onAccept)
                root.onAccept()
            event.accepted = true
        } else if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier) && list.count > 0) {
            list.currentIndex = (list.currentIndex + 1) % list.count
            event.accepted = true
        } else if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier) && list.count > 0) {
            list.currentIndex = (list.currentIndex - 1 + list.count) % list.count
            event.accepted = true
        }
    }
}
