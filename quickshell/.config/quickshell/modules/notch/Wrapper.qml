pragma ComponentBehavior: Bound

import qs.components
import qs.config
import QtQuick

Item {
    id: root

    required property var visibilities
    readonly property real notchWidth: content.implicitWidth + Config.notch.sizes.padding * 4
    readonly property real notchHeight: Config.notch.sizes.height

    anchors.fill: parent

    Background {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        notchWidth: root.notchWidth
        notchHeight: root.notchHeight

        Content {
            id: content
            anchors.centerIn: parent
        }
    }
}
