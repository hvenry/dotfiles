pragma ComponentBehavior: Bound

import qs.components
import qs.config
import QtQuick

Item {
    id: root

    required property var visibilities
    readonly property real notchWidth: content.implicitWidth + Appearance.padding.normal * 2
    readonly property real notchHeight: Config.notch.sizes.height
    readonly property real notchX: (parent.width - notchWidth) / 2

    anchors.fill: parent

    Background {
        y: -Config.notch.sizes.rounding / 2
        anchors.horizontalCenter: parent.horizontalCenter

        notchWidth: root.notchWidth
        notchHeight: root.notchHeight

        Content {
            id: content
            anchors.centerIn: parent
        }
    }
}
