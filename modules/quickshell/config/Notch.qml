pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: Constants.hitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    // reserving (notchHeight - borderWidth + 4) keeps the notch-to-window gap
    // aligned with the side/bottom window gaps after thinning the screen frame
    exclusiveZone: Constants.notchHeight - Constants.borderWidth + 4
    WlrLayershell.namespace: "nesw-notch"

    // audio
    readonly property PwNode audioSink: Pipewire.defaultAudioSink
    readonly property real volume: audioSink && audioSink.audio ? audioSink.audio.volume : 0
    readonly property bool muted: audioSink && audioSink.audio ? audioSink.audio.muted : false

    // audioMode swaps the notch content from the workspace ruler to the volume hud
    property bool audioMode: false
    property bool isVolumeChanging: false
    // armed after startup so the initial pipewire sync doesn't pop the hud
    property bool audioReady: false

    // Hyprland keeps the normal workspace as focusedWorkspace while a special
    // workspace is open — check the monitor's specialWorkspace field instead
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
            if (event.name === "activespecialv2" || event.name === "activespecial")
                Hyprland.refreshMonitors();
        }
    }

    onInSpecialWsChanged: {
        if (!inSpecialWs || audioLockTimer.running)
            return
        audioMode = false
        reveal()
    }

    // volume/muted are invalid unless the node is bound; tracking binds it
    PwObjectTracker {
        objects: [root.audioSink]
    }

    onVolumeChanged: showAudio()
    onMutedChanged: showAudio()

    property bool expanded: false
    property real notchWidth: Math.min(Constants.maxWidth, Math.max(Constants.minWidth, expanded ? Constants.maxWidth : Constants.minWidth))
    property real slideOffset: 0

    // workspace whose tick sits at the center notch (derived while scrubbing)
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

    // shown in the notch — active workspace unless the user is scrubbing
    readonly property int indicatorWs: workspaceScrubbing ? displayNumber : activeWs

    Component.onCompleted: {
        Hyprland.refreshMonitors();
        slideOffset = slideTargetForWs(activeWs)
        slideReady = true
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: root.audioReady = true
    }

    Timer {
        id: audioLockTimer
        interval: 800
        repeat: false
        onTriggered: {
            root.isVolumeChanging = false
            if (!hoverHandler.hovered && !audioHud.dragContainsMouse && !audioTimer.running)
                root.audioMode = false
        }
    }

    onActiveWsChanged: {
        if (!slideReady)
            return
        if (audioLockTimer.running)
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
        if (!audioReady)
            return
        isVolumeChanging = true
        audioMode = true
        expanded = true
        audioLockTimer.restart()
        audioTimer.restart()
    }

    function setVolume(fraction) {
        if (!audioSink || !audioSink.audio)
            return
        audioSink.audio.muted = false
        audioSink.audio.volume = Math.max(0, Math.min(1, fraction))
        isVolumeChanging = true
        audioMode = true
        expanded = true
        audioLockTimer.restart()
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

    // settle a scrub: glide the ruler to the nearest tick and focus that workspace
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
            if (hoverHandler.hovered || audioHud.dragContainsMouse) {
                restart();
                return;
            }
            root.expanded = false;
            if (!audioLockTimer.running)
                root.audioMode = false;
        }
    }

    Behavior on notchWidth {
        SpringAnimation {
            spring: 3
            damping: 0.3
            mass: 0.6
            epsilon: 0.01
        }
    }

    Behavior on slideOffset {
        enabled: !wsDrag.active
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    // input mask: center gets the full expanded hit depth; screen sides only
  // the visible notch strip so clicks pass through to maximized windows below
    Item {
        id: hitMask
        anchors.fill: parent
        visible: false

        readonly property real centerX: (width - shape.width) / 2
        readonly property real centerHitHeight: root.expanded ? Constants.hitHeight : Constants.notchHeight

        Item {
            x: 0
            y: 0
            width: parent.centerX
            height: Constants.notchHeight
        }

        Item {
            x: parent.centerX
            y: 0
            width: shape.width
            height: parent.centerHitHeight
        }

        Item {
            x: parent.centerX + shape.width
            y: 0
            width: parent.width - x
            height: Constants.notchHeight
        }
    }

    mask: Region {
        item: hitMask
    }

    // shape
    // continuous loop matching the canvas arcTo path: travels along the top
    // top strip, dips down with an S-curve tangent to the strip's bottom edge,
    // runs across the bottom, and curves back up to meet the strip again
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

    // content
    Item {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        y: Constants.borderWidth
        width: root.contentWidth
        height: Constants.notchHeight - Constants.borderWidth
        clip: true

        z: root.audioMode ? 10 : 0

        opacity: root.expanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

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
        }
    }

    // input — workspace interactions live only in the centered notch column
    Item {
        id: hit
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.notchWidth
        height: root.expanded ? Constants.hitHeight : Constants.notchHeight

        Behavior on height {
            SpringAnimation {
                spring: 3
                damping: 0.35
                mass: 0.5
                epsilon: 0.01
            }
        }

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
                    collapseTimer.stop();
                    audioTimer.stop();
                } else if (root.expanded) {
                    if (root.audioMode)
                        audioTimer.restart();
                    else if (!wsDrag.active)
                        collapseTimer.restart();
                }
            }
        }
    }
}
