pragma ComponentBehavior: Bound

import qs.services
import qs.config
import qs.utils
import Quickshell.Services.SystemTray
import QtQuick

MouseArea {
    id: root

    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: Appearance.font.size.small * 2
    implicitHeight: Appearance.font.size.small * 2

    onClicked: event => {
        if (event.button === Qt.LeftButton)
            modelData.activate();
        else
            modelData.secondaryActivate();
    }

    Image {
        id: icon

        anchors.fill: parent
        source: Icons.getTrayIcon(root.modelData.id, root.modelData.icon)
        sourceSize: Qt.size(width, height)
        asynchronous: true
    }
}
