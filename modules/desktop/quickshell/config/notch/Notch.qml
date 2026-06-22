pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import qs.common

PanelWindow {
    id: root

    screen: Constants.shellScreen

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: Constants.notchHeight

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone: Constants.notchHeight - Constants.borderWidth + 4
    WlrLayershell.namespace: "nesw-notch"

    // audio
    readonly property PwNode audioSink: Pipewire.defaultAudioSink
    readonly property real volume: audioSink && audioSink.audio ? audioSink.audio.volume : 0
    readonly property bool muted: audioSink && audioSink.audio ? audioSink.audio.muted : false

    property bool audioMode: false
    property real _lastVolume: -1

    readonly property bool inSpecialWs: {
        const mon = Hyprland.monitorFor(root.screen);
        if (!mon)
            return false;
        const special = mon.lastIpcObject.specialWorkspace;
        const name = special ? (special.name ?? "") : "";
        return name.length > 0;
    }

    readonly property real contentWidth: notchWidth - Constants.notchPadding * 2

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecialv2")
                Hyprland.refreshMonitors();
        }
    }

    onInSpecialWsChanged: {
        if (!inSpecialWs || audioTimer.running)
            return
        audioMode = false
        reveal()
    }

    PwObjectTracker {
        objects: [root.audioSink]
    }

    onVolumeChanged: {
        if (_lastVolume < 0) {
            _lastVolume = volume;
            return;
        }
        if (Math.abs(volume - _lastVolume) > 0.001) {
            _lastVolume = volume;
            showAudio();
        }
    }

    onMutedChanged: {
        showAudio();
    }

    property bool expanded: false
    property real notchWidth: Constants.minWidth
    property real contentOpacity: 0
    property real slideOffset: 0

    readonly property int expandWidthDuration: 220
    readonly property int collapseWidthDuration: 180
    readonly property int expandOpacityDuration: 150
    readonly property int collapseOpacityDuration: 120
    readonly property int expandOpacityDelay: 50

    readonly property int displayNumber: Math.max(1, Math.round(1 - slideOffset / Constants.stepPx))

    readonly property int activeWs: {
        const ws = Hyprland.focusedWorkspace;
        return ws ? Math.max(1, ws.id) : 1;
    }

    readonly property int maxOccupied: {
        let m = 0;
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            const id = list[i].id;
            if (id > m)
                m = id;
        }
        return m;
    }

    readonly property var occupied: {
        const s = {};
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            const id = list[i].id;
            if (id > 0)
                s[id] = true;
        }
        return s;
    }

    readonly property int rulerMax: Math.max(activeWs, maxOccupied, displayNumber) + Constants.rulerBuffer

    property bool slideReady: false
    property bool workspaceScrubbing: false

    readonly property int indicatorWs: workspaceScrubbing ? displayNumber : activeWs

    Component.onCompleted: {
        Hyprland.refreshMonitors();
        slideOffset = slideTargetForWs(activeWs)
        slideReady = true
    }

    onActiveWsChanged: {
        if (!slideReady)
            return
        if (audioTimer.running)
            return

        audioMode = false
        animateSlideTo(activeWs)
        reveal()
    }

    function slideTargetForWs(ws) {
        return -(ws - 1) * Constants.stepPx
    }

    function reveal() {
        expanded = true
        collapseTimer.restart()
    }

    function showAudio() {
        collapseTimer.stop()
        audioMode = true
        expanded = true
        audioTimer.restart()
    }

    function toggleMute() {
        if (!audioSink || !audioSink.audio)
            return
        audioSink.audio.muted = !audioSink.audio.muted
    }

    function setVolume(fraction) {
        if (!audioSink || !audioSink.audio)
            return
        audioSink.audio.muted = false
        audioSink.audio.volume = Math.max(0, Math.min(1, fraction))
        audioMode = true
        expanded = true
        audioTimer.restart()
    }

    function bumpVolume(delta) {
        setVolume(volume + delta)
    }

    function animateSlideTo(ws) {
        const target = slideTargetForWs(ws)

        if (Math.abs(slideOffset - target) < 0.5) {
            slideOffset = target
            return
        }

        slideOffset = target
    }

    function goToWorkspace(n) {
        const target = Math.max(1, Math.round(n))
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + target + " })")
        reveal()
    }

    function commitWorkspaceDrag() {
        const ws = displayNumber
        slideOffset = slideTargetForWs(ws)
        goToWorkspace(ws)
    }

    Timer {
        id: collapseTimer
        interval: 1500
        onTriggered: {
            if (hoverHandler.hovered || root.audioMode || wsDrag.active)
                return;
            root.expanded = false;
        }
    }

    Timer {
        id: audioTimer
        interval: 2000
        onTriggered: {
            if (audioHud.interacting) {
                restart()
                return
            }
            root.expanded = false
            root.audioMode = false
        }
    }

    onExpandedChanged: {
        if (expanded) {
            widthCollapseAnim.stop()
            contentOpacityOutAnim.stop()
            contentOpacityDelay.stop()
            widthExpandAnim.restart()
            contentOpacityDelay.restart()
        } else {
            widthExpandAnim.stop()
            contentOpacityInAnim.stop()
            contentOpacityDelay.stop()
            contentOpacityOutAnim.restart()
            widthCollapseAnim.restart()
        }
    }

    NumberAnimation {
        id: widthExpandAnim
        target: root
        property: "notchWidth"
        to: Constants.maxWidth
        duration: root.expandWidthDuration
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: widthCollapseAnim
        target: root
        property: "notchWidth"
        to: Constants.minWidth
        duration: root.collapseWidthDuration
        easing.type: Easing.OutCubic
    }

    Timer {
        id: contentOpacityDelay
        interval: root.expandOpacityDelay
        onTriggered: contentOpacityInAnim.restart()
    }

    NumberAnimation {
        id: contentOpacityInAnim
        target: root
        property: "contentOpacity"
        to: 1
        duration: root.expandOpacityDuration
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: contentOpacityOutAnim
        target: root
        property: "contentOpacity"
        to: 0
        duration: root.collapseOpacityDuration
        easing.type: Easing.OutCubic
    }

    Behavior on slideOffset {
        enabled: !wsDrag.active
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    Item {
        id: hitMask
        anchors.fill: parent
        visible: false

        Item {
            x: (parent.width - shape.width) / 2
            y: 0
            width: shape.width
            height: Constants.notchHeight
        }
    }

    mask: Region {
        item: hitMask
    }

    Shape {
        id: shape
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.notchWidth + Constants.notchRadius * 2
        height: Constants.notchHeight
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Constants.notchColor
            strokeWidth: 0

            startX: 0
            startY: 0

            PathLine {
                x: 0
                y: Constants.borderWidth
            }

            PathArc {
                x: Constants.notchRadius
                y: Constants.borderWidth + Constants.notchRadius
                radiusX: Constants.notchRadius
                radiusY: Constants.notchRadius
                direction: PathArc.Clockwise
            }

            PathLine {
                x: Constants.notchRadius
                y: Constants.notchHeight - Constants.notchRadius
            }

            PathArc {
                x: Constants.notchRadius * 2
                y: Constants.notchHeight
                radiusX: Constants.notchRadius
                radiusY: Constants.notchRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: shape.width - Constants.notchRadius * 2
                y: Constants.notchHeight
            }

            PathArc {
                x: shape.width - Constants.notchRadius
                y: Constants.notchHeight - Constants.notchRadius
                radiusX: Constants.notchRadius
                radiusY: Constants.notchRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: shape.width - Constants.notchRadius
                y: Constants.borderWidth + Constants.notchRadius
            }

            PathArc {
                x: shape.width
                y: Constants.borderWidth
                radiusX: Constants.notchRadius
                radiusY: Constants.notchRadius
                direction: PathArc.Clockwise
            }

            PathLine { x: shape.width; y: 0 }
            PathLine { x: 0; y: 0 }
        }
    }

    Item {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        y: Constants.borderWidth
        width: root.contentWidth
        height: Constants.notchHeight - Constants.borderWidth
        clip: true

        opacity: root.contentOpacity

        WorkspaceRuler {
            anchors.fill: parent
            slideOffset: root.slideOffset
            expanded: root.expanded
            audioMode: root.audioMode
            inSpecialWs: root.inSpecialWs
            indicatorWs: root.indicatorWs
            rulerMax: root.rulerMax
            occupied: root.occupied
        }

        AudioHud {
            id: audioHud
            anchors.fill: parent
            expanded: root.expanded
            audioMode: root.audioMode
            volume: root.volume
            muted: root.muted
            onRequestSetVolume: fraction => root.setVolume(fraction)
            onRequestBumpVolume: delta => root.bumpVolume(delta)
            onRequestToggleMute: root.toggleMute()
        }
    }

    // input
    Item {
        id: hit
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.notchWidth
        height: Constants.notchHeight

        property real wheelAccum: 0
        readonly property real wheelStep: 120

        function consumeWheelDelta(delta) {
            if (delta === 0)
                return

            wheelAccum += delta
            let steps = 0

            while (wheelAccum <= -wheelStep) {
                steps += 1
                wheelAccum += wheelStep
            }

            while (wheelAccum >= wheelStep) {
                steps -= 1
                wheelAccum -= wheelStep
            }

            if (steps !== 0)
                root.goToWorkspace(root.displayNumber + steps)
        }

        WheelHandler {
            enabled: !root.audioMode
            orientation: Qt.Horizontal
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                let delta = event.angleDelta.x
                if (delta === 0)
                    delta = event.pixelDelta.x
                hit.consumeWheelDelta(delta)
            }
        }

        DragHandler {
            id: wsDrag
            enabled: root.expanded && !root.audioMode
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            property real startOffset: 0

            onActiveChanged: {
                if (wsDrag.active) {
                    root.workspaceScrubbing = true
                    wsDrag.startOffset = root.slideOffset
                    collapseTimer.stop()
                } else {
                    root.workspaceScrubbing = false
                    root.commitWorkspaceDrag()
                }
            }
            onActiveTranslationChanged: {
                if (wsDrag.active)
                    root.slideOffset = wsDrag.startOffset + wsDrag.activeTranslation.x
            }
        }

        TapHandler {
            enabled: root.expanded && !root.audioMode
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onTapped: eventPoint => {
                const steps = Math.round((eventPoint.position.x - hit.width / 2) / Constants.stepPx)
                root.goToWorkspace(root.displayNumber + steps)
            }
        }

        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (hovered) {
                    collapseTimer.stop()
                } else if (root.expanded) {
                    if (root.audioMode)
                        audioTimer.restart()
                    else if (!wsDrag.active)
                        collapseTimer.restart()
                }
            }
        }
    }
}
