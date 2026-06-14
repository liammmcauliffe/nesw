pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// spotlight-style app launcher: a floating neutral card, no dimmed backdrop.
// opened/closed over IPC: qs ipc call launcher toggle
PanelWindow {
    id: root

    screen: Quickshell.screens[0]
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"
    visible: mapped

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nesw-launcher"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // geometry (~40% larger than original)
    readonly property int panelWidth: 784
    readonly property int searchHeight: 76
    readonly property int itemHeight: 70
    readonly property int maxResults: 8
    readonly property int panelRadius: 20
    readonly property int resultsBlockHeight: maxResults * itemHeight + 8
    readonly property int panelFullHeight: searchHeight + 1 + resultsBlockHeight
    readonly property real panelTopMarginRatio: 0.17

    // neutral chrome — black card like the notch, translucent like the top bar
    readonly property color panelBg: "#d9000000"
    readonly property color textPrimary: "#f2f2f2"
    readonly property color textSecondary: "#888888"
    readonly property color textPlaceholder: "#555555"
    readonly property color dividerColor: "#18ffffff"

    property bool open: false
    property bool mapped: false
    property string query: ""

    readonly property var results: {
        const q = query.trim().toLowerCase();
        const all = DesktopEntries.applications.values.filter(a => a && !a.noDisplay);

        if (q.length === 0) {
            return all.slice().sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
        }

        return all.map(a => {
            const name = (a.name || "").toLowerCase();
            const generic = (a.genericName || "").toLowerCase();
            const keywords = (a.keywords || []).join(" ").toLowerCase();
            let rank = -1;
            if (name.startsWith(q))
                rank = 0;
            else if (name.includes(q))
                rank = 1;
            else if (generic.includes(q))
                rank = 2;
            else if (keywords.includes(q))
                rank = 3;
            return {
                app: a,
                rank: rank
            };
        }).filter(e => e.rank >= 0).sort((x, y) => x.rank - y.rank || x.app.name.toLowerCase().localeCompare(y.app.name.toLowerCase())).map(e => e.app);
    }

    onOpenChanged: {
        if (open) {
            mapped = true;
            query = "";
            searchInput.text = "";
            list.currentIndex = 0;
            focusTimer.start();
        } else {
            unmapTimer.start();
        }
    }

    function toggle(): void {
        open = !open;
    }

    function launch(entry): void {
        if (!entry)
            return;
        entry.execute();
        open = false;
    }

    Timer {
        id: focusTimer
        interval: 30
        onTriggered: searchInput.forceActiveFocus()
    }
    Timer {
        id: unmapTimer
        interval: 180
        onTriggered: root.mapped = false
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            root.toggle();
        }
        function show(): void {
            root.open = true;
        }
        function hide(): void {
            root.open = false;
        }
    }

    // invisible full-screen hit target — click outside the card to dismiss
    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.open = false
    }

    // pinned to a fixed screen position; scale pops from the top edge so nothing
    // drifts upward when results load or the spring runs
    Item {
        id: panelHost

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * root.panelTopMarginRatio
        width: root.panelWidth
        height: root.panelFullHeight

        transformOrigin: Item.Top

        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.88

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? 120 : 80
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            SpringAnimation {
                spring: 7
                damping: 0.34
                epsilon: 0.001
            }
        }

        Rectangle {
            id: panel

            anchors.fill: parent

            radius: root.panelRadius
            color: root.panelBg
            border.width: 1
            border.color: "#14ffffff"

            readonly property bool hasResults: root.results.length > 0
            readonly property bool showEmpty: !hasResults && root.query.length > 0

            // keep panel clicks from reaching the dismiss layer
            MouseArea {
                anchors.fill: parent
            }

            // search row
            Item {
                id: searchRow
                width: parent.width
                height: root.searchHeight

                SearchIcon {
                    size: 25
                    color: root.textSecondary
                    anchors.left: parent.left
                    anchors.leftMargin: 28
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 70
                    anchors.right: parent.right
                    anchors.rightMargin: 25
                    height: parent.height
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true

                    font.family: Fonts.family
                    font.pixelSize: 22
                    font.weight: Fonts.weightBaseline
                    color: root.textPrimary
                    selectionColor: "#33ffffff"
                    selectedTextColor: root.textPrimary
                    focus: true

                    onTextChanged: {
                        root.query = text;
                        list.currentIndex = 0;
                    }

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Escape) {
                            root.open = false;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Space && (event.modifiers & Qt.MetaModifier)) {
                            root.open = false;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            list.currentIndex = Math.max(0, list.currentIndex - 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launch(root.results[list.currentIndex]);
                            event.accepted = true;
                        }
                    }

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "Search apps…"
                        color: root.textPlaceholder
                        font: searchInput.font
                        visible: searchInput.text.length === 0
                    }
                }
            }

            Rectangle {
                id: divider
                anchors.top: searchRow.bottom
                width: parent.width
                height: 1
                color: root.dividerColor
                visible: panel.hasResults
            }

            ListView {
                id: list
                anchors.top: divider.bottom
                anchors.topMargin: 3
                anchors.left: parent.left
                anchors.right: parent.right
                height: root.resultsBlockHeight - 6
                clip: true
                interactive: count > root.maxResults
                boundsBehavior: Flickable.StopAtBounds
                visible: panel.hasResults

                model: root.results
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Item {
                    id: appRow
                    required property int index
                    required property var modelData
                    width: ListView.view.width
                    height: root.itemHeight

                    readonly property bool active: ListView.isCurrentItem

                    // only the selected row picks up the accent
                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        anchors.topMargin: 2
                        anchors.bottomMargin: 2
                        radius: 11
                        color: Colors.palette.m3primary
                        opacity: appRow.active ? 0.14 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 80
                            }
                        }
                    }

                    Image {
                        id: appIcon
                        width: 36
                        height: 36
                        anchors.left: parent.left
                        anchors.leftMargin: 28
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize.width: 36
                        sourceSize.height: 36
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        source: {
                            const ic = appRow.modelData ? appRow.modelData.icon : "";
                            if (!ic)
                                return "";
                            return ic.startsWith("/") ? "file://" + ic : Quickshell.iconPath(ic, true);
                        }
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 11
                        anchors.left: parent.left
                        anchors.leftMargin: 28
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#22ffffff"
                        visible: appIcon.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: appRow.modelData && appRow.modelData.name ? appRow.modelData.name.charAt(0).toUpperCase() : "?"
                            color: root.textSecondary
                            font.family: Fonts.family
                            font.pixelSize: 17
                            font.weight: Fonts.weightBold
                        }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 81
                        anchors.right: parent.right
                        anchors.rightMargin: 22
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1

                        Text {
                            width: parent.width
                            text: appRow.modelData ? appRow.modelData.name : ""
                            elide: Text.ElideRight
                            color: root.textPrimary
                            font.family: Fonts.family
                            font.pixelSize: 20
                            font.weight: Fonts.weightBaseline
                        }
                        Text {
                            width: parent.width
                            text: appRow.modelData && appRow.modelData.genericName ? appRow.modelData.genericName : ""
                            visible: text.length > 0
                            elide: Text.ElideRight
                            color: root.textSecondary
                            font.family: Fonts.family
                            font.pixelSize: 17
                            font.weight: Fonts.weightBaseline
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = appRow.index
                        onClicked: root.launch(appRow.modelData)
                    }
                }
            }

            Text {
                anchors.top: divider.bottom
                anchors.topMargin: 3
                anchors.horizontalCenter: parent.horizontalCenter
                height: root.resultsBlockHeight - 6
                verticalAlignment: Text.AlignVCenter
                visible: panel.showEmpty
                text: "No results"
                color: root.textSecondary
                font.family: Fonts.family
                font.pixelSize: 20
            }
        }
    }
}
