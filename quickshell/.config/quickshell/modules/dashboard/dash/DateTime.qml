pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    anchors.fill: parent

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Appearance.spacing.smaller

        StyledText {
            Layout.alignment: Qt.AlignRight
            text: Time.format("hh:mm:ss A").split(" ")[0]
            color: Colours.palette.m3secondary
            font.pointSize: Appearance.font.size.extraLarge * 0.9
            font.family: Appearance.font.family.clock
            font.weight: 600
        }

        StyledText {
            Layout.alignment: Qt.AlignRight
            text: Time.format("hh:mm:ss A").split(" ")[1]
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal * 1.2
            font.family: Appearance.font.family.clock
            font.weight: 500
        }
    }
}
