pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: hitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    // hyprland adds gaps_out (12px) on top of this, so reserve less than the
    // full notch height to leave only ~2px between windows and the notch
    exclusiveZone: notchHeight - 10
    WlrLayershell.namespace: "nesw-notch"

    // Notch
    readonly property int minWidth: 300
    readonly property int maxWidth: 360
    readonly property int notchHeight: 40
    readonly property int notchRadius: 15
    readonly property int borderWidth: 6
    readonly property int notchPadding: 16
    readonly property int hitHeight: 120
    readonly property color notchColor: "black"

    // Ruler
    readonly property int stepPx: 46
    readonly property int rulerBuffer: 5
    readonly property int frameInset: 4

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
        slideOffset = -(activeWs - 1) * stepPx
        slideReady = true
    }

    onActiveWsChanged: {
        if (!slideReady)
            return
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

    Timer {
        id: collapseTimer
        interval: 1500
        onTriggered: {
            if (hoverHandler.hovered)
                return;
            root.expanded = false;
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

    // Clickthrough
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

    // Shape
    // Continuous loop matching the canvas arcTo path: travels along the 6px
    // top strip, dips down with an S-curve tangent to the strip's bottom edge,
    // runs across the bottom, and curves back up to meet the strip again.
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

            // Left edge of the top strip
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

            // Bottom-left rounded corner
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

            // Bottom-right rounded corner
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

            // Right edge of the top strip, then back across the screen top
            PathLine { x: shape.width; y: 0 }
            PathLine { x: 0; y: 0 }
        }
    }

    // Content
    Item {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.borderWidth
        width: root.notchWidth - root.notchPadding * 2
        height: root.notchHeight - root.borderWidth
        clip: true

        opacity: root.expanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Row {
            id: strip
            height: parent.height
            x: content.width / 2 - root.stepPx / 2 + root.slideOffset

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
            text: root.displayNumber
            color: Colors.palette.m3primary
            font.family: Fonts.family
            font.pixelSize: Fonts.sizeNotch
            font.weight: Fonts.weightBold
            anchors.left: content.horizontalCenter
            anchors.leftMargin: 6
            anchors.verticalCenter: content.verticalCenter
        }
    }

    // Input
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
            orientation: Qt.Horizontal
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                let delta = event.angleDelta.x
                if (delta === 0)
                    delta = event.pixelDelta.x
                hit.consumeWheelDelta(delta)
            }
        }

        TapHandler {
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
                    if (root.expanded)
                        collapseTimer.stop();
                } else if (root.expanded) {
                    collapseTimer.restart();
                }
            }
        }
    }
}
