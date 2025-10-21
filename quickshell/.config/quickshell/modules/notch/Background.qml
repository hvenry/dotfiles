import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    required property real notchWidth
    required property real notchHeight

    width: notchWidth
    height: notchHeight

    Shape {
        anchors.fill: parent

        ShapePath {
            fillColor: Colours.tPalette.m3surface
            strokeColor: "transparent"

            startX: 0
            startY: 0

            // Top left corner (sharp)
            PathLine { x: 0; y: 0 }

            // Top edge
            PathLine { x: root.notchWidth; y: 0 }

            // Top right corner (sharp)
            PathLine { x: root.notchWidth; y: 0 }

            // Right edge down to rounded corner
            PathLine { x: root.notchWidth; y: root.notchHeight - Config.notch.sizes.rounding }

            // Bottom right rounded corner
            PathArc {
                x: root.notchWidth - Config.notch.sizes.rounding
                y: root.notchHeight
                radiusX: Config.notch.sizes.rounding
                radiusY: Config.notch.sizes.rounding
            }

            // Bottom edge
            PathLine { x: Config.notch.sizes.rounding; y: root.notchHeight }

            // Bottom left rounded corner
            PathArc {
                x: 0
                y: root.notchHeight - Config.notch.sizes.rounding
                radiusX: Config.notch.sizes.rounding
                radiusY: Config.notch.sizes.rounding
            }

            // Left edge back to start
            PathLine { x: 0; y: 0 }
        }
    }
}
