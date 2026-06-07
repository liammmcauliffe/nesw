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

    implicitWidth: reservedWidth
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone: reservedWidth
    WlrLayershell.namespace: "nesw-notch"

    // Panel (vertical switcher, top-left, always shown)
    readonly property int panelMargin: 6
    readonly property int panelWidth: 72
    readonly property int panelHeight: 360
    readonly property int panelRadius: 18
    readonly property int reservedWidth: panelMargin + panelWidth + 10
    readonly property color panelColor: Colors.palette.m3surface

    // Ruler
    readonly property int stepPx: 46
    readonly property int rulerBuffer: 5
    readonly property int tickLeft: 16
    readonly property int minorLen: 7
    readonly property int majorLen: 13
    readonly property int activeLen: 22

    property real slideOffset: 0

    // workspace whose tick sits at the centre line (counts up as ticks pass it)
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
    }

    function slideDuration(fromWs, toWs) {
        const dist = Math.abs(toWs - fromWs)
        if (dist === 0)
            return 0
        // ~40ms per tick; fast enough to read each number on long jumps
        return Math.min(450, Math.max(60, dist * 40))
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
    }

    NumberAnimation {
        id: slideAnim
        target: root
        property: "slideOffset"
        easing.type: Easing.Linear
        onFinished: root.slideOffset = to
    }

    // Clickthrough: only the panel is interactive
    Item {
        id: hitMask
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: root.panelMargin
        anchors.topMargin: root.panelMargin
        width: root.panelWidth
        height: root.panelHeight
        visible: false
    }

    mask: Region {
        item: hitMask
    }

    // Panel
    Rectangle {
        id: panel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: root.panelMargin
        anchors.topMargin: root.panelMargin
        width: root.panelWidth
        height: root.panelHeight
        radius: root.panelRadius
        color: root.panelColor

        // Ruler (clipped)
        Item {
            id: viewport
            anchors.fill: parent
            clip: true

            Column {
                id: strip
                width: parent.width
                y: panel.height / 2 - root.stepPx / 2 + root.slideOffset

                Repeater {
                    model: root.rulerMax

                    delegate: Item {
                        id: tick
                        required property int index

                        readonly property int wsNumber: index + 1
                        readonly property bool isActive: wsNumber === root.displayNumber
                        readonly property bool isOccupied: root.occupied[wsNumber] === true

                        width: panel.width
                        height: root.stepPx

                        Repeater {
                            // +3 fills the midpoint to the next workspace tick
                            model: [-2, -1, 1, 2, 3]

                            delegate: Rectangle {
                                required property int modelData

                                // hide the sub-ticks before the first workspace
                                visible: !(tick.wsNumber === 1 && modelData < 0)

                                x: root.tickLeft
                                width: root.minorLen
                                height: 1
                                radius: 0.5
                                color: Colors.palette.m3onSurfaceVariant
                                opacity: 0.3
                                y: tick.height / 2 + modelData * (root.stepPx / 6) - height / 2
                            }
                        }

                        Rectangle {
                            x: root.tickLeft
                            height: 2
                            width: tick.isActive ? root.activeLen : root.majorLen
                            radius: 1
                            color: tick.isActive ? Colors.palette.m3primary
                                 : tick.isOccupied ? Colors.palette.m3onSurface
                                 : Colors.palette.m3onSurfaceVariant
                            opacity: tick.isActive || tick.isOccupied ? 1 : 0.45
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
        }

        // Active pointer (fixed at the centre line)
        Shape {
            anchors.verticalCenter: panel.verticalCenter
            x: root.tickLeft - 12
            width: 7
            height: 11
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: Colors.palette.m3primary
                strokeWidth: 0
                startX: 0
                startY: 0
                PathLine { x: 7; y: 5.5 }
                PathLine { x: 0; y: 11 }
                PathLine { x: 0; y: 0 }
            }
        }

        // Active number, to the right of the ticks
        Text {
            text: root.displayNumber
            color: Colors.palette.m3onSurface
            font.family: Fonts.family
            font.pixelSize: Fonts.sizeNotch
            font.weight: Fonts.weightBlack
            x: root.tickLeft + root.activeLen + 8
            anchors.verticalCenter: panel.verticalCenter
        }

        WheelHandler {
            orientation: Qt.Vertical
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                let delta = event.angleDelta.y
                if (delta === 0)
                    delta = event.pixelDelta.y
                wheel.consume(delta)
            }
        }

        TapHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onTapped: eventPoint => {
                const steps = Math.round((eventPoint.position.y - panel.height / 2) / root.stepPx)
                root.goToWorkspace(root.displayNumber + steps)
            }
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }

        QtObject {
            id: wheel

            property real accum: 0
            readonly property real threshold: 120

            function consume(delta) {
                if (delta === 0)
                    return

                accum += delta
                let steps = 0

                while (accum <= -threshold) {
                    steps += 1
                    accum += threshold
                }

                while (accum >= threshold) {
                    steps -= 1
                    accum -= threshold
                }

                if (steps !== 0)
                    root.goToWorkspace(root.displayNumber + steps)
            }
        }
    }
}
