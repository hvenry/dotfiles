import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Shapes

Item {
    id: root

    default property alias content: contentItem.children

    anchors.fill: parent

    readonly property real notchWidth: contentItem.implicitWidth + Config.notch.sizes.padding * 2
    readonly property real notchHeight: Config.notch.sizes.height
    readonly property real notchX: (parent.width - notchWidth) / 2
    readonly property real rounding: Config.notch.sizes.rounding

    // Background shape
    Shape {
        id: bgShape

        x: root.notchX
        y: 0
        width: root.notchWidth
        height: root.notchHeight

        preferredRendererType: Shape.CurveRenderer

        Behavior on x {
            Anim {
                duration: Appearance.anim.durations.small
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }

        Behavior on width {
            Anim {
                duration: Appearance.anim.durations.small
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }

        ShapePath {
            strokeWidth: -1
            fillColor: Colours.palette.m3surface

            // Start at top-left
            startX: 0
            startY: 0

            // Top-right corner (no rounding at top)
            PathLine {
                x: bgShape.width
                y: 0
            }

            // Right edge down
            PathLine {
                relativeX: 0
                relativeY: bgShape.height - root.rounding
            }

            // Bottom-right corner (rounded)
            PathArc {
                relativeX: -root.rounding
                relativeY: root.rounding
                radiusX: root.rounding
                radiusY: root.rounding
            }

            // Bottom edge
            PathLine {
                x: root.rounding
                y: bgShape.height
            }

            // Bottom-left corner (rounded)
            PathArc {
                relativeX: -root.rounding
                relativeY: -root.rounding
                radiusX: root.rounding
                radiusY: root.rounding
            }

            // Left edge back to start
            PathLine {
                x: 0
                y: 0
            }

            Behavior on fillColor {
                CAnim {}
            }
        }
    }

    // Content container
    Item {
        id: contentItem

        x: (parent.width - implicitWidth) / 2
        y: (parent.height - implicitHeight) / 2
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
