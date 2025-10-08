import qs.components
import qs.services
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var client

    anchors.fill: parent
    spacing: Appearance.spacing.small

    StyledText {
        Layout.topMargin: Appearance.padding.large
        Layout.leftMargin: Appearance.padding.large
        Layout.rightMargin: Appearance.padding.large
        text: qsTr("Move to workspace")
        elide: Text.ElideRight
    }

    GridLayout {
        id: wsGrid

        Layout.fillWidth: true
        Layout.leftMargin: Appearance.padding.large * 2
        Layout.rightMargin: Appearance.padding.large * 2
        Layout.topMargin: Appearance.spacing.normal

        rowSpacing: Appearance.spacing.smaller
        columnSpacing: Appearance.spacing.normal
        columns: 5

        Repeater {
            model: 5

            Button {
                required property int index
                readonly property int wsId: index + 1
                readonly property bool isCurrent: root.client?.workspace.id === wsId

                color: isCurrent ? Colours.tPalette.m3surfaceContainerHighest : Colours.palette.m3tertiaryContainer
                onColor: isCurrent ? Colours.palette.m3onSurface : Colours.palette.m3onTertiaryContainer
                text: wsId
                disabled: isCurrent

                function onClicked(): void {
                    Hypr.dispatch(`movetoworkspace ${wsId},address:0x${root.client?.address}`);
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.padding.large
        Layout.rightMargin: Appearance.padding.large
        Layout.bottomMargin: Appearance.padding.large

        spacing: root.client?.lastIpcObject.floating ? Appearance.spacing.normal : Appearance.spacing.small

        Button {
            color: Colours.palette.m3secondaryContainer
            onColor: Colours.palette.m3onSecondaryContainer
            text: root.client?.lastIpcObject.floating ? qsTr("Tile") : qsTr("Float")

            function onClicked(): void {
                Hypr.dispatch(`togglefloating address:0x${root.client?.address}`);
            }
        }

        Loader {
            active: root.client?.lastIpcObject.floating
            asynchronous: true
            Layout.fillWidth: active
            Layout.leftMargin: active ? 0 : -parent.spacing
            Layout.rightMargin: active ? 0 : -parent.spacing

            sourceComponent: Button {
                color: Colours.palette.m3secondaryContainer
                onColor: Colours.palette.m3onSecondaryContainer
                text: root.client?.lastIpcObject.pinned ? qsTr("Unpin") : qsTr("Pin")

                function onClicked(): void {
                    Hypr.dispatch(`pin address:0x${root.client?.address}`);
                }
            }
        }

        Button {
            color: Colours.palette.m3errorContainer
            onColor: Colours.palette.m3onErrorContainer
            text: qsTr("Kill")

            function onClicked(): void {
                Hypr.dispatch(`killwindow address:0x${root.client?.address}`);
            }
        }
    }

    component Button: StyledRect {
        property color onColor: Colours.palette.m3onSurface
        property alias disabled: stateLayer.disabled
        property alias text: label.text

        function onClicked(): void {
        }

        radius: Appearance.rounding.small

        Layout.fillWidth: true
        implicitHeight: label.implicitHeight + Appearance.padding.small * 2

        StateLayer {
            id: stateLayer

            color: parent.onColor

            function onClicked(): void {
                parent.onClicked();
            }
        }

        StyledText {
            id: label

            anchors.centerIn: parent

            animate: true
            color: parent.onColor
            font.pointSize: Appearance.font.size.normal
        }
    }
}
