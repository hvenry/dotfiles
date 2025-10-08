pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property ShellScreen screen
    required property Session session

    implicitWidth: layout.implicitWidth + Appearance.padding.larger * 4
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Appearance.padding.larger * 2
        spacing: Appearance.spacing.normal

        NavItem {
            Layout.topMargin: Appearance.spacing.large * 2
            icon: "network_manage"
            label: "network"
        }

        NavItem {
            icon: "settings_bluetooth"
            label: "bluetooth"
        }

        NavItem {
            icon: "tune"
            label: "audio"
        }
    }

    component NavItem: Item {
        id: item

        required property string icon
        required property string label
        readonly property bool active: root.session.active === label

        implicitWidth: background.implicitWidth
        implicitHeight: background.implicitHeight

        StyledRect {
            id: background

            radius: Appearance.rounding.full
            color: Qt.alpha(Colours.palette.m3secondaryContainer, item.active ? 1 : 0)

            implicitWidth: icon.implicitWidth + icon.anchors.leftMargin * 2
            implicitHeight: icon.implicitHeight + Appearance.padding.small * 2

            StateLayer {
                color: item.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

                function onClicked(): void {
                    root.session.active = item.label;
                }
            }

            MaterialIcon {
                id: icon

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Appearance.padding.large

                text: item.icon
                color: item.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.large
                fill: item.active ? 1 : 0

                Behavior on fill {
                    Anim {}
                }
            }
        }
    }
}
