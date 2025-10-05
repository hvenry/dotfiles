pragma ComponentBehavior: Bound

import qs.components
import qs.config
import QtQuick

Item {
    id: root

    required property var visibilities
    readonly property alias notchX: bg.notchX
    readonly property alias notchWidth: bg.notchWidth
    readonly property alias notchHeight: bg.notchHeight

    anchors.fill: parent

    Background {
        id: bg

        Content {}
    }
}
