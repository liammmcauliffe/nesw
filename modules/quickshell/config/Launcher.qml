pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// fullscreen app launcher backed by Quickshell's native DesktopEntries index
// (no external daemon). opened/closed over IPC from a hyprland keybind:
//   qs ipc call launcher toggle
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

    // fullscreen overlay that never reserves screen space
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nesw-launcher"
    // only grab the keyboard while actually open, so the closed (fading) window
    // never steals input from the focused app
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // geometry
    readonly property int panelWidth: 600
    readonly property int searchHeight: 58
    readonly property int itemHeight: 54
    readonly property int maxResults: 8
    readonly property int panelRadius: 16

    // a translucent surface tint so the layer blur (see hyprland rules.lua) reads through
    readonly property color panelBg: Qt.rgba(Colors.palette.m3surface.r, Colors.palette.m3surface.g, Colors.palette.m3surface.b, 0.86)

    // state
    property bool open: false
    // mapped lags `open` so the close animation can finish before the surface unmaps
    property bool mapped: false
    property string query: ""

    // filtered + ranked application list. recomputes when the query changes or
    // the desktop entry index updates
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

    // forceActiveFocus has to wait until the surface is actually mapped/focusable
    Timer {
        id: focusTimer
        interval: 30
        onTriggered: searchInput.forceActiveFocus()
    }
    Timer {
        id: unmapTimer
        interval: 200
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

    // dim + blur backdrop; click anywhere outside the panel to dismiss
    Rectangle {
        anchors.fill: parent
        color: "#66000000"
        opacity: root.open ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }
    }

    // panel
    Rectangle {
        id: panel

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -80

        width: root.panelWidth
        readonly property int visCount: Math.min(root.results.length, root.maxResults)
        readonly property bool hasResults: root.results.length > 0
        readonly property bool showEmpty: !hasResults && root.query.length > 0
        height: root.searchHeight + (hasResults ? 1 + visCount * root.itemHeight + 8 : (showEmpty ? root.itemHeight : 0))

        radius: root.panelRadius
        color: root.panelBg
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.96
        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        // swallow clicks that land on the panel chrome so they don't reach the
        // dismiss backdrop underneath
        MouseArea {
            anchors.fill: parent
        }

        // search row
        Item {
            id: searchRow
            width: parent.width
            height: root.searchHeight

            // magnifier glyph
            Item {
                width: 18
                height: 18
                anchors.left: parent.left
                anchors.leftMargin: 22
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    x: 1
                    y: 1
                    width: 12
                    height: 12
                    radius: 6
                    color: "transparent"
                    border.width: 1.6
                    border.color: Colors.palette.m3onSurfaceVariant
                }
                Rectangle {
                    width: 2
                    height: 7
                    radius: 1
                    color: Colors.palette.m3onSurfaceVariant
                    x: 11
                    y: 9
                    transformOrigin: Item.Center
                    rotation: 45
                }
            }

            TextInput {
                id: searchInput
                anchors.left: parent.left
                anchors.leftMargin: 54
                anchors.right: parent.right
                anchors.rightMargin: 20
                height: parent.height
                verticalAlignment: TextInput.AlignVCenter
                clip: true

                font.family: Fonts.family
                font.pixelSize: 17
                font.weight: Fonts.weightBaseline
                color: Colors.palette.m3onSurface
                selectionColor: Colors.palette.m3primaryContainer
                selectedTextColor: Colors.palette.m3onPrimaryContainer
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
                        // SUPER+space is the open shortcut; while focused it toggles closed
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
                    color: Qt.rgba(Colors.palette.m3onSurfaceVariant.r, Colors.palette.m3onSurfaceVariant.g, Colors.palette.m3onSurfaceVariant.b, 0.55)
                    font: searchInput.font
                    visible: searchInput.text.length === 0
                }
            }
        }

        // divider
        Rectangle {
            id: divider
            anchors.top: searchRow.bottom
            width: parent.width
            height: 1
            color: Qt.rgba(1, 1, 1, 0.07)
            visible: panel.hasResults
        }

        // results
        ListView {
            id: list
            anchors.top: divider.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
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

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    anchors.topMargin: 2
                    anchors.bottomMargin: 2
                    radius: 10
                    color: Colors.palette.m3primary
                    opacity: appRow.active ? 0.16 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }

                Image {
                    id: appIcon
                    width: 28
                    height: 28
                    anchors.left: parent.left
                    anchors.leftMargin: 22
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize.width: 28
                    sourceSize.height: 28
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    asynchronous: true
                    source: {
                        const ic = appRow.modelData ? appRow.modelData.icon : "";
                        if (!ic)
                            return "";
                        // absolute paths are used directly; names resolve via the icon theme
                        return ic.startsWith("/") ? "file://" + ic : Quickshell.iconPath(ic, true);
                    }
                    visible: status === Image.Ready
                }

                // letter fallback when no themed icon is available
                Rectangle {
                    width: 28
                    height: 28
                    radius: 9
                    anchors.left: parent.left
                    anchors.leftMargin: 22
                    anchors.verticalCenter: parent.verticalCenter
                    color: Colors.palette.m3primaryContainer
                    visible: appIcon.status !== Image.Ready

                    Text {
                        anchors.centerIn: parent
                        text: appRow.modelData && appRow.modelData.name ? appRow.modelData.name.charAt(0).toUpperCase() : "?"
                        color: Colors.palette.m3onPrimaryContainer
                        font.family: Fonts.family
                        font.pixelSize: 13
                        font.weight: Fonts.weightBold
                    }
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 62
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        width: parent.width
                        text: appRow.modelData ? appRow.modelData.name : ""
                        elide: Text.ElideRight
                        color: appRow.active ? Colors.palette.m3primary : Colors.palette.m3onSurface
                        font.family: Fonts.family
                        font.pixelSize: 15
                        font.weight: appRow.active ? Fonts.weightSemiBold : Fonts.weightBaseline
                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                    }
                    Text {
                        width: parent.width
                        text: appRow.modelData && appRow.modelData.genericName ? appRow.modelData.genericName : ""
                        visible: text.length > 0
                        elide: Text.ElideRight
                        color: Colors.palette.m3onSurfaceVariant
                        font.family: Fonts.family
                        font.pixelSize: 12
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

        // empty state
        Text {
            anchors.top: searchRow.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            height: root.itemHeight
            verticalAlignment: Text.AlignVCenter
            visible: panel.showEmpty
            text: "No results"
            color: Colors.palette.m3onSurfaceVariant
            font.family: Fonts.family
            font.pixelSize: 14
        }
    }
}
