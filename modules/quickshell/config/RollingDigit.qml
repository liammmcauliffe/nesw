import QtQuick

// rolls 0–9 with the same step timing as the notch workspace ruler
Item {
    id: root

    property int digit: 0
    property int fontSize: 18
    property string family: Fonts.family
    property int fontWeight: Fonts.weightBaseline
    property color color: "white"
    property var fontFeatures: Fonts.featuresTabular

    readonly property real lineHeight: measureLine.height

    implicitWidth: measureChar.implicitWidth
    implicitHeight: lineHeight
    clip: true

    property real position: 0
    property bool initialized: false

    Text {
        id: measureChar
        visible: false
        font.pixelSize: root.fontSize
        font.family: root.family
        font.weight: root.fontWeight
        font.features: root.fontFeatures
        text: "0"
    }

    Text {
        id: measureLine
        visible: false
        font.pixelSize: root.fontSize
        font.family: root.family
        font.weight: root.fontWeight
        font.features: root.fontFeatures
        text: "0"
    }

    onDigitChanged: {
        if (!initialized) {
            position = digit
            initialized = true
            return
        }

        const old = Math.round(position)
        const normalized = ((old % 10) + 10) % 10
        let dist = digit - normalized
        if (dist > 5)
            dist -= 10
        if (dist < -5)
            dist += 10

        if (dist === 0)
            return

        rollAnim.stop()
        rollAnim.from = position
        rollAnim.to = position + dist
        const steps = Math.abs(dist)
        rollAnim.duration = Math.min(450, Math.max(60, steps * 40))
        rollAnim.start()
    }

    NumberAnimation {
        id: rollAnim
        target: root
        property: "position"
        easing.type: Easing.Linear
        onStopped: root.position = root.digit
    }

    Column {
        y: -root.position * root.lineHeight

        Repeater {
            model: 40

            Text {
                required property int index
                width: root.implicitWidth
                height: root.lineHeight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                text: index % 10
                color: root.color
                font.pixelSize: root.fontSize
                font.family: root.family
                font.weight: root.fontWeight
                font.features: root.fontFeatures
            }
        }
    }
}
