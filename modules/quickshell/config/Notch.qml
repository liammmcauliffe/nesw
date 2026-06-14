pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "icons"

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: hitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    // reserving (notchHeight - borderWidth) makes the notch-to-window gap
    // always equal the window-to-border gap on the sides/bottom: both come
    // out to (gaps_out - borderWidth), so they stay in sync however hyprland
    // gaps are tuned
    exclusiveZone: notchHeight - borderWidth
    WlrLayershell.namespace: "nesw-notch"

    // notch
    readonly property int minWidth: 300
    readonly property int maxWidth: 360
    readonly property int notchHeight: 40
    readonly property int notchRadius: 15
    readonly property int borderWidth: 6
    readonly property int notchPadding: 16
    readonly property int hitHeight: 120
    readonly property color notchColor: "black"

    // ruler
    readonly property int stepPx: 46
    readonly property int rulerBuffer: 5
    readonly property int frameInset: 4

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
    property real notchWidth: Math.min(maxWidth, Math.max(minWidth, expanded ? maxWidth : minWidth))
    property real slideOffset: 0

    // workspace whose tick sits at the center notch (counts up as ticks pass under)
    readonly property int displayNumber: Math.max(1, Math.round(1 - slideOffset / stepPx))

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

    readonly property int rulerMax: Math.max(activeWs, maxOccupied, displayNumber) + rulerBuffer

    property bool slideReady: false

    Component.onCompleted: {
        Hyprland.refreshMonitors();
        slideOffset = -(activeWs - 1) * stepPx
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

    function animateSlideTo(ws) {
        const target = -(ws - 1) * stepPx
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
        slideAnim.to = -(ws - 1) * stepPx
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
            if (hoverHandler.hovered || audioDrag.containsMouse) {
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

    // special workspace glow — stroked outline behind the solid notch
    Shape {
        id: glowShape
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.notchWidth + root.notchRadius * 2
        height: root.notchHeight
        preferredRendererType: Shape.CurveRenderer

        opacity: root.inSpecialWs ? 0.45 : 0
        Behavior on opacity {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: Colors.palette.m3primary
            strokeWidth: 4

            startX: 0
            startY: 0
            PathLine { x: 0; y: root.borderWidth }
            PathArc {
                x: root.notchRadius; y: root.borderWidth + root.notchRadius
                radiusX: root.notchRadius; radiusY: root.notchRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: root.notchRadius; y: root.notchHeight - root.notchRadius }
            PathArc {
                x: root.notchRadius * 2; y: root.notchHeight
                radiusX: root.notchRadius; radiusY: root.notchRadius
                direction: PathArc.Counterclockwise
            }
            PathLine { x: glowShape.width - root.notchRadius * 2; y: root.notchHeight }
            PathArc {
                x: glowShape.width - root.notchRadius; y: root.notchHeight - root.notchRadius
                radiusX: root.notchRadius; radiusY: root.notchRadius
                direction: PathArc.Counterclockwise
            }
            PathLine { x: glowShape.width - root.notchRadius; y: root.borderWidth + root.notchRadius }
            PathArc {
                x: glowShape.width; y: root.borderWidth
                radiusX: root.notchRadius; radiusY: root.notchRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: glowShape.width; y: 0 }
            PathLine { x: 0; y: 0 }
        }
    }

    // shape
    // continuous loop matching the canvas arcTo path: travels along the 6px
    // top strip, dips down with an S-curve tangent to the strip's bottom edge,
    // runs across the bottom, and curves back up to meet the strip again
    Shape {
        id: shape
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.notchWidth + root.notchRadius * 2
        height: root.notchHeight
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.notchColor
            strokeWidth: 0

            startX: 0
            startY: 0

            // left edge of the top strip
            PathLine {
                x: 0
                y: root.borderWidth
            }

            // S-curve: strip bottom edge flares into the left notch wall
            PathArc {
                x: root.notchRadius
                y: root.borderWidth + root.notchRadius
                radiusX: root.notchRadius
                radiusY: root.notchRadius
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.notchRadius
                y: root.notchHeight - root.notchRadius
            }

            // bottom-left rounded corner
            PathArc {
                x: root.notchRadius * 2
                y: root.notchHeight
                radiusX: root.notchRadius
                radiusY: root.notchRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: shape.width - root.notchRadius * 2
                y: root.notchHeight
            }

            // bottom-right rounded corner
            PathArc {
                x: shape.width - root.notchRadius
                y: root.notchHeight - root.notchRadius
                radiusX: root.notchRadius
                radiusY: root.notchRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: shape.width - root.notchRadius
                y: root.borderWidth + root.notchRadius
            }

            // S-curve back up to the strip's bottom edge
            PathArc {
                x: shape.width
                y: root.borderWidth
                radiusX: root.notchRadius
                radiusY: root.notchRadius
                direction: PathArc.Clockwise
            }

            // right edge of the top strip, then back across the screen top
            PathLine { x: shape.width; y: 0 }
            PathLine { x: 0; y: 0 }
        }
    }

    // special workspace indicator dot — always visible, no expand needed
    Rectangle {
        id: specialDot
        width: 5
        height: 5
        radius: 2.5
        color: Colors.palette.m3tertiary
        anchors.horizontalCenter: parent.horizontalCenter
        // sits centered on the bottom lip of the notch pill
        y: root.notchHeight - height / 2

        opacity: root.inSpecialWs ? 0.85 : 0
        Behavior on opacity {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }
    }

    // content
    Item {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.borderWidth
        width: root.notchWidth - root.notchPadding * 2
        height: root.notchHeight - root.borderWidth
        clip: true

        // in audio mode the slider needs pointer events, so lift content above
        // the workspace input layer (hit) below
        z: root.audioMode ? 10 : 0

        opacity: root.expanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Row {
            id: strip
            height: parent.height
            x: content.width / 2 - root.stepPx / 2 + root.slideOffset

            opacity: root.expanded && !root.audioMode ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: root.rulerMax

                delegate: Item {
                    id: tick
                    required property int index

                    readonly property int wsNumber: index + 1
                    readonly property bool isActive: wsNumber === root.displayNumber
                    readonly property bool isOccupied: root.occupied[wsNumber] === true

                    width: root.stepPx
                    height: content.height

                    Repeater {
                        // +3 fills the midpoint to the next workspace tick
                        model: [-2, -1, 1, 2, 3]

                        delegate: Rectangle {
                            required property int modelData

                            // hide the sub-ticks before the first workspace
                            visible: !(tick.wsNumber === 1 && modelData < 0)

                            width: 1
                            height: 6
                            radius: 0.5
                            color: Colors.palette.m3onSurfaceVariant
                            opacity: 0.3
                            x: tick.width / 2 + modelData * (root.stepPx / 6) - width / 2
                            anchors.verticalCenter: tick.verticalCenter
                        }
                    }

                    Rectangle {
                        width: 2
                        height: tick.isActive ? content.height - root.frameInset * 2
                              : tick.isOccupied ? 14 : 9
                        radius: 1
                        color: tick.isActive ? Colors.palette.m3primary
                             : tick.isOccupied ? Colors.palette.m3onSurface
                             : Colors.palette.m3onSurfaceVariant
                        opacity: tick.isActive || tick.isOccupied ? 1 : 0.5
                        anchors.horizontalCenter: tick.horizontalCenter
                        anchors.verticalCenter: tick.verticalCenter

                        Behavior on height {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 180 }
                        }
                    }
                }
            }
        }

        Text {
            text: root.inSpecialWs ? "S" : root.displayNumber
            color: root.inSpecialWs ? Colors.palette.m3tertiary : Colors.palette.m3primary
            font.family: Fonts.family
            font.pixelSize: Fonts.sizeNotch
            font.weight: Fonts.weightBold
            anchors.left: content.horizontalCenter
            anchors.leftMargin: 6
            anchors.verticalCenter: content.verticalCenter

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            opacity: root.expanded && !root.audioMode ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }

        // audio hud: static speaker glyphs flank a draggable level bar tinted
        // with the workspace accent (m3primary)
        Item {
            id: audioHud
            anchors.fill: parent
            visible: opacity > 0
            opacity: root.expanded && root.audioMode ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            VolumeIcon {
                id: volIconMin
                glyph: "none"
                size: 20
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            VolumeIcon {
                id: volIconMax
                glyph: "high"
                size: 20
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                id: track
                height: 20
                anchors.left: volIconMin.right
                anchors.leftMargin: 12
                anchors.right: volIconMax.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                // animate the level, not the pixel width: while the notch expands
                // track.width keeps changing, so binding the fill to level * width
                // lets it stretch in lockstep instead of chasing a width animation
                // toward a target that is still moving
                property real level: Math.max(0, Math.min(1, root.volume))
                Behavior on level {
                    NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 6
                    radius: height / 2
                    color: Colors.palette.m3onSurfaceVariant
                    opacity: 0.3
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    height: 6
                    radius: height / 2
                    width: track.level * track.width
                    color: Colors.palette.m3primary
                    opacity: root.muted ? 0.4 : 1
                }

                MouseArea {
                    id: audioDrag
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    onPressed: mouse => root.setVolume(mouse.x / track.width)
                    onPositionChanged: mouse => {
                        if (audioDrag.pressed)
                            root.setVolume(mouse.x / track.width)
                    }
                }
            }
        }
    }

    // input
    Item {
        id: hit
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.notchWidth
        height: root.expanded ? root.hitHeight : root.notchHeight

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
            enabled: !root.audioMode
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            property real startOffset: 0

            onActiveChanged: {
                if (wsDrag.active) {
                    slideAnim.stop()
                    wsDrag.startOffset = root.slideOffset
                    collapseTimer.stop()
                    root.expanded = true
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
                const steps = Math.round((eventPoint.position.x - hit.width / 2) / root.stepPx)
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
