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
    anchors.bottom: true

    implicitWidth: hitWidth
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone: 0
    WlrLayershell.namespace: "nesw-notch"

    // Notch (vertical, hugs the left edge near the top)
    readonly property int collapsedLength: 200
    readonly property int expandedLength: 300
    readonly property int notchThickness: 34
    readonly property int hitWidth: 120
    readonly property int bottomRadius: 14
    readonly property int topRadius: 14
    readonly property int edgeMargin: 8
    readonly property color notchColor: "black"

    // Ruler
    readonly property int stepPx: 46
    readonly property int rulerBuffer: 5
    readonly property int frameInset: 4

    property bool expanded: false
    property real notchLength: expanded ? expandedLength : collapsedLength
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

    Behavior on notchLength {
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
        anchors.left: parent.left
        anchors.verticalCenter: shape.verticalCenter
        width: hit.width
        height: shape.height
        visible: false
    }

    mask: Region {
        item: hitMask
    }

    // Shape
    Shape {
        id: shape
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: root.edgeMargin

        width: root.notchThickness
        height: root.notchLength + root.topRadius * 2
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.notchColor
            strokeWidth: 0

            startX: 0
            startY: 0

            PathArc {
                x: root.topRadius
                y: root.topRadius
                radiusX: root.topRadius
                radiusY: root.topRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.notchThickness - root.bottomRadius
                y: root.topRadius
            }

            PathArc {
                x: root.notchThickness
                y: root.topRadius + root.bottomRadius
                radiusX: root.bottomRadius
                radiusY: root.bottomRadius
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.notchThickness
                y: shape.height - root.topRadius - root.bottomRadius
            }

            PathArc {
                x: root.notchThickness - root.bottomRadius
                y: shape.height - root.topRadius
                radiusX: root.bottomRadius
                radiusY: root.bottomRadius
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.topRadius
                y: shape.height - root.topRadius
            }

            PathArc {
                x: 0
                y: shape.height
                radiusX: root.topRadius
                radiusY: root.topRadius
                direction: PathArc.Counterclockwise
            }

            PathLine { x: 0; y: 0 }
        }
    }

    // Content
    Item {
        id: content
        anchors.left: parent.left
        anchors.verticalCenter: shape.verticalCenter
        width: root.notchThickness
        height: root.notchLength
        clip: true

        opacity: root.expanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Column {
            id: strip
            width: parent.width
            y: content.height / 2 - root.stepPx / 2 + root.slideOffset

            Repeater {
                model: root.rulerMax

                delegate: Item {
                    id: tick
                    required property int index

                    readonly property int wsNumber: index + 1
                    readonly property bool isActive: wsNumber === root.displayNumber
                    readonly property bool isOccupied: root.occupied[wsNumber] === true

                    width: content.width
                    height: root.stepPx

                    Repeater {
                        // +3 fills the midpoint to the next workspace tick
                        model: [-2, -1, 1, 2, 3]

                        delegate: Rectangle {
                            required property int modelData

                            // hide the sub-ticks before the first workspace
                            visible: !(tick.wsNumber === 1 && modelData < 0)

                            width: 6
                            height: 1
                            radius: 0.5
                            color: Colors.palette.m3onSurfaceVariant
                            opacity: 0.3
                            y: tick.height / 2 + modelData * (root.stepPx / 6) - height / 2
                            anchors.horizontalCenter: tick.horizontalCenter
                        }
                    }

                    Rectangle {
                        height: 2
                        width: tick.isActive ? content.width - root.frameInset * 2
                             : tick.isOccupied ? 14 : 9
                        radius: 1
                        color: tick.isActive ? Colors.palette.m3primary
                             : tick.isOccupied ? Colors.palette.m3onSurface
                             : Colors.palette.m3onSurfaceVariant
                        opacity: tick.isActive || tick.isOccupied ? 1 : 0.5
                        anchors.horizontalCenter: tick.horizontalCenter
                        anchors.verticalCenter: tick.verticalCenter

                        Behavior on width {
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
            font.weight: Fonts.weightBlack
            anchors.horizontalCenter: content.horizontalCenter
            anchors.verticalCenter: content.verticalCenter
        }
    }

    // Input
    Item {
        id: hit
        anchors.left: parent.left
        anchors.verticalCenter: shape.verticalCenter
        height: root.notchLength
        width: root.expanded ? root.hitWidth : root.notchThickness

        Behavior on width {
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
            orientation: Qt.Vertical
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                let delta = event.angleDelta.y
                if (delta === 0)
                    delta = event.pixelDelta.y
                hit.consumeWheelDelta(delta)
            }
        }

        TapHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onTapped: eventPoint => {
                const steps = Math.round((eventPoint.position.y - hit.height / 2) / root.stepPx)
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
