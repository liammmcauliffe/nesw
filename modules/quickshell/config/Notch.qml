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
    // reserving (notchHeight - borderWidth) makes the notch-to-window gap
    // always equal the window-to-border gap on the sides/bottom: both come
    // out to (gaps_out - borderWidth), so they stay in sync however hyprland
    // gaps are tuned
    exclusiveZone: Constants.notchHeight - Constants.borderWidth
    WlrLayershell.namespace: "nesw-notch"

    // audio
    readonly property PwNode audioSink: Pipewire.defaultAudioSink
    readonly property real volume: audioSink && audioSink.audio ? audioSink.audio.volume : 0
    readonly property bool muted: audioSink && audioSink.audio ? audioSink.audio.muted : false

    // audioMode swaps the notch content from the workspace ruler to the volume hud
    property bool audioMode: false
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

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activespecialv2" || event.name === "activespecial")
                Hyprland.refreshMonitors();
        }
    }

    onInSpecialWsChanged: {
        if (inSpecialWs) {
            audioMode = false
            reveal()
        }
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

    // workspace whose tick sits at the center notch (counts up as ticks pass under)
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

    Component.onCompleted: {
        Hyprland.refreshMonitors();
        slideOffset = -(activeWs - 1) * Constants.stepPx
        slideReady = true
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: root.audioReady = true
    }

    onActiveWsChanged: {
        if (!slideReady)
            return
        audioMode = false
        animateSlideTo(activeWs)
        reveal()
    }

    function slideDuration(fromWs, toWs) {
        const dist = Math.abs(toWs - fromWs)
        if (dist === 0)
            return 0
        // ~40ms per tick; fast enough to read each number on long jumps
        return Math.min(450, Math.max(60, dist * 40))
    }

    function reveal() {
        expanded = true
        collapseTimer.restart()
    }

    function showAudio() {
        if (!audioReady)
            return
        audioMode = true
        expanded = true
        audioTimer.restart()
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
        const target = -(ws - 1) * Constants.stepPx
        const fromWs = displayNumber

        if (Math.abs(slideOffset - target) < 0.5) {
            slideOffset = target
            return
        }

        slideAnim.stop()
        slideAnim.duration = slideDuration(fromWs, ws)
        slideAnim.from = slideOffset
        slideAnim.to = target
        slideAnim.start()
    }

    function goToWorkspace(n) {
        const target = Math.max(1, Math.round(n))
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + target + " })")
        reveal()
    }

    // settle a scrub: glide the ruler to the nearest tick and focus that workspace
    function commitWorkspaceDrag() {
        const ws = displayNumber
        slideAnim.stop()
        slideAnim.duration = 160
        slideAnim.from = slideOffset
        slideAnim.to = -(ws - 1) * Constants.stepPx
        slideAnim.start()
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
            root.audioMode = false;
        }
    }

    Behavior on notchWidth {
        NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }

    NumberAnimation {
        id: slideAnim
        target: root
        property: "slideOffset"
        easing.type: Easing.Linear
        onFinished: root.slideOffset = to
    }

    // clickthrough
    Item {
        id: hitMask
        x: (root.width - shape.width) / 2
        y: 0
        width: shape.width
        height: hit.height
        visible: false
    }

    mask: Region {
        item: hitMask
    }

    // shape
    // continuous loop matching the canvas arcTo path: travels along the 6px
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

            // left edge of the top strip
            PathLine {
                x: 0
                y: Constants.borderWidth
            }

            // S-curve: strip bottom edge flares into the left notch wall
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

            // bottom-left rounded corner
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

            // bottom-right rounded corner
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

            // S-curve back up to the strip's bottom edge
            PathArc {
                x: shape.width
                y: Constants.borderWidth
                radiusX: Constants.notchRadius
                radiusY: Constants.notchRadius
                direction: PathArc.Clockwise
            }

            // right edge of the top strip, then back across the screen top
            PathLine { x: shape.width; y: 0 }
            PathLine { x: 0; y: 0 }
        }
    }

    // content
    Item {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        y: Constants.borderWidth
        width: root.notchWidth - Constants.notchPadding * 2
        height: Constants.notchHeight - Constants.borderWidth
        clip: true

        // in audio mode the slider needs pointer events, so lift content above
        // the workspace input layer (hit) below
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
            displayNumber: root.displayNumber
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

    // input
    Item {
        id: hit
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.notchWidth
        height: root.expanded ? Constants.hitHeight : Constants.notchHeight

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
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

        // click-and-drag to scrub through workspaces, mirroring the volume
        // slider; a plain click never crosses the drag threshold, so the
        // focused workspace is left untouched
        DragHandler {
            id: wsDrag
            enabled: root.expanded && !root.audioMode
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            property real startOffset: 0

            onActiveChanged: {
                if (wsDrag.active) {
                    slideAnim.stop()
                    wsDrag.startOffset = root.slideOffset
                    collapseTimer.stop()
                } else {
                    root.commitWorkspaceDrag()
                }
            }
            onActiveTranslationChanged: {
                if (wsDrag.active)
                    root.slideOffset = wsDrag.startOffset + wsDrag.activeTranslation.x
            }
        }

        // tapping a visible switcher jumps to the workspace under the cursor;
        // while collapsed (blank notch) taps are ignored so a stray click can't
        // switch. drags are handled by wsDrag, so a tap only fires for a click
        // that never crossed the drag threshold
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
