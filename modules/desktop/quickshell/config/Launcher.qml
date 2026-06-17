pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "icons"

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
    // stay mapped always - toggling visibility remaps the layer and hyprland
    // animates that with "slide bottom" (see animations.lua layersIn)
    visible: true

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nesw-launcher"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // geometry (~40% larger than original)
    readonly property int panelWidth: Math.min(Constants.launcherWidth, Math.floor(width * 0.88))
    readonly property int searchHeight: 76
    readonly property int itemHeight: 70
    readonly property int maxResults: 8
    readonly property int panelRadius: 20
    readonly property int panelPadding: 16
    readonly property int rowRadius: 8
    readonly property int emptyBlockHeight: itemHeight
    readonly property int openHintWidth: 96
    readonly property real panelTopMarginRatio: Constants.launcherTopMarginRatio

    readonly property int visCount: Math.min(results.length, maxResults)
    readonly property bool showEmpty: query.length > 0 && results.length === 0
    readonly property bool showResultsBlock: visCount > 0 || showEmpty
    readonly property int resultsHeight: showResultsBlock
        ? panelPadding * 2 + (showEmpty ? emptyBlockHeight : visCount * itemHeight)
        : 0
    readonly property int panelHeight: searchHeight + (showResultsBlock ? 1 + resultsHeight : 0)

    // neutral chrome - black card, mostly opaque
    readonly property color panelBg: "#f0000000"
    readonly property color textPrimary: "#f2f2f2"
    readonly property color textSecondary: "#888888"
    readonly property color textPlaceholder: "#555555"
    readonly property color dividerColor: "#18ffffff"

    property bool open: false
    property string query: ""

    readonly property string historyPath: `${Quickshell.env("HOME")}/.local/state/nesw/launcher-history.json`
    property var launchHistory: ({})
    property int historyEpoch: 0

    function historyKey(entry) {
        if (!entry)
            return "";
        return entry.id || entry.name || "";
    }

    function loadHistory(text) {
        if (!text)
            return;
        try {
            launchHistory = JSON.parse(text);
            historyEpoch++;
        } catch (e) {}
    }

    function persistHistory() {
        const json = JSON.stringify(launchHistory);
        const dir = `${Quickshell.env("HOME")}/.local/state/nesw`;
        const path = root.historyPath;
        Quickshell.execDetached({
            command: [
                "sh", "-c",
                `mkdir -p '${dir}' && printf '%s' '${json.replace(/'/g, "'\\''")}' > '${path}'`
            ],
        });
    }

    function saveHistory(entry) {
        const key = historyKey(entry);
        if (!key)
            return;
        const next = Object.assign({}, launchHistory);
        next[key] = Date.now();
        launchHistory = next;
        historyEpoch++;
        persistHistory();
    }

    FileView {
        path: root.historyPath
        watchChanges: false
        printErrors: false
        onLoaded: root.loadHistory(text())
    }

    readonly property var results: {
        const _epoch = historyEpoch;
        const q = query.trim().toLowerCase();
        const all = DesktopEntries.applications.values.filter(a => a && !a.noDisplay);

        if (q.length === 0) {
            return all.slice().sort((a, b) => {
                const ta = root.launchHistory[root.historyKey(a)] || 0;
                const tb = root.launchHistory[root.historyKey(b)] || 0;
                if (tb !== ta)
                    return tb - ta;
                return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
            });
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

    readonly property var selectedApp: results.length > 0 && list.currentIndex >= 0
        ? results[list.currentIndex]
        : null

    onOpenChanged: {
        if (open) {
            query = "";
            searchInput.text = "";
            list.currentIndex = 0;
            panelHost.playOpen();
            focusTimer.start();
        } else {
            panelHost.playClose();
        }
    }

    function toggle(): void {
        open = !open;
    }

    function launch(entry): void {
        if (!entry)
            return;
        saveHistory(entry);
        entry.execute();
        open = false;
    }

    Timer {
        id: focusTimer
        interval: 30
        onTriggered: searchInput.forceActiveFocus()
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

    // wayland only delivers clicks inside the input mask - without this the
    // fullscreen overlay layer eats every click even when the launcher is closed
    Item {
        id: hitMask
        x: 0
        y: 0
        width: root.open ? root.width : 0
        height: root.open ? root.height : 0
        visible: false
    }

    mask: Region {
        item: hitMask
    }

    // invisible full-screen hit target - click outside the card to dismiss
    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.open = false
    }

    Item {
        id: panelHost

        x: (parent.width - width) / 2
        y: parent.height * root.panelTopMarginRatio
        width: root.panelWidth
        height: root.panelHeight

        // top origin - height changes while searching don't yank the visual center
        transformOrigin: Item.Top

        enabled: root.open
        visible: opacity > 0.01

        opacity: 0
        scale: 0.88

        function playOpen() {
            openScale.stop();
            openOpacity.stop();
            closeScale.stop();
            closeOpacity.stop();
            scale = 0.88;
            opacity = 0;
            openScale.start();
            openOpacity.start();
        }

        function playClose() {
            openScale.stop();
            openOpacity.stop();
            closeScale.stop();
            closeOpacity.stop();
            closeScale.start();
            closeOpacity.start();
        }

        NumberAnimation {
            id: openScale
            target: panelHost
            property: "scale"
            to: 1
            duration: 160
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            id: closeScale
            target: panelHost
            property: "scale"
            to: 0.88
            duration: 100
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            id: openOpacity
            target: panelHost
            property: "opacity"
            to: 1
            duration: 160
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            id: closeOpacity
            target: panelHost
            property: "opacity"
            to: 0
            duration: 100
            easing.type: Easing.InCubic
        }

        Rectangle {
            id: panel

            width: parent.width
            height: parent.height

            radius: root.panelRadius
            color: root.panelBg
            border.width: 1
            border.color: "#22ffffff"
            clip: true

            readonly property bool hasResults: root.results.length > 0

            MouseArea {
                anchors.fill: parent
            }

            Item {
                id: searchRow
                width: parent.width
                height: root.searchHeight

                TintedSvgIcon {
                    size: 26
                    color: root.textSecondary
                    source: Qt.resolvedUrl("assets/search.svg")
                    anchors.left: parent.left
                    anchors.leftMargin: 28
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.leftMargin: 70
                    anchors.right: selectedAppBadge.left
                    anchors.rightMargin: 20
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
                        } else if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier) && list.count > 0) {
                            list.currentIndex = (list.currentIndex + 1) % list.count;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier) && list.count > 0) {
                            list.currentIndex = (list.currentIndex - 1 + list.count) % list.count;
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

                Item {
                    id: selectedAppBadge
                    width: 36
                    height: 36
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.results.length > 0
                    opacity: visible ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }

                    Image {
                        id: selectedIcon
                        anchors.fill: parent
                        sourceSize.width: 36
                        sourceSize.height: 36
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        source: {
                            const app = root.selectedApp;
                            if (!app || !app.icon)
                                return "";
                            return app.icon.startsWith("/") ? "file://" + app.icon : Quickshell.iconPath(app.icon, true);
                        }
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 11
                        color: "#22ffffff"
                        visible: selectedIcon.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: root.selectedApp && root.selectedApp.name
                                ? root.selectedApp.name.charAt(0).toUpperCase()
                                : "?"
                            color: root.textSecondary
                            font.family: Fonts.family
                            font.pixelSize: 17
                            font.weight: Fonts.weightBold
                        }
                    }
                }
            }

            Rectangle {
                id: divider
                anchors.top: searchRow.bottom
                width: parent.width
                height: 1
                color: root.dividerColor
                visible: panel.hasResults || root.showEmpty
            }

            ListView {
                id: list
                anchors.top: divider.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: root.panelPadding
                anchors.rightMargin: root.panelPadding
                anchors.topMargin: root.panelPadding
                anchors.bottomMargin: root.panelPadding
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
                        radius: root.rowRadius
                        color: Colors.palette.m3primary
                        opacity: appRow.active ? 0.22 : 0
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
                        anchors.leftMargin: 20
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
                        anchors.leftMargin: 20
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
                        anchors.leftMargin: 72
                        anchors.right: parent.right
                        anchors.rightMargin: root.openHintWidth
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: appRow.modelData ? appRow.modelData.name : ""
                            elide: Text.ElideRight
                            color: root.textPrimary
                            font.family: Fonts.family
                            font.pixelSize: 20
                            font.weight: appRow.active ? Fonts.weightBold : Fonts.weightBaseline
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

                    Row {
                        id: openHint
                        spacing: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        visible: appRow.active
                        opacity: visible ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 80 }
                        }

                        Text {
                            text: "Open"
                            color: root.textSecondary
                            font.family: Fonts.family
                            font.pixelSize: 16
                            font.weight: Fonts.weightBaseline
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TintedSvgIcon {
                            size: 26
                            color: root.textSecondary
                            source: Qt.resolvedUrl("assets/return-key.svg")
                            anchors.verticalCenter: parent.verticalCenter
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

            Item {
                anchors.top: divider.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: root.panelPadding
                anchors.bottomMargin: root.panelPadding
                anchors.bottom: parent.bottom
                visible: root.showEmpty

                Text {
                    anchors.centerIn: parent
                    text: "No results"
                    color: root.textSecondary
                    font.family: Fonts.family
                    font.pixelSize: 20
                }
            }
        }
    }
}
