pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    spacing: Appearance.spacing.normal

    MaterialIcon {
        Layout.alignment: Qt.AlignHCenter
        text: "wifi"
        font.pointSize: Appearance.font.size.extraLarge * 3
        font.bold: true
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("Network settings")
        font.pointSize: Appearance.font.size.large
        font.bold: true
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("WiFi status")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Enable or disable WiFi radio")
        color: Colours.palette.m3outline
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: wifiStatus.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: wifiStatus

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large

            spacing: Appearance.spacing.larger

            Toggle {
                label: qsTr("WiFi enabled")
                checked: Network.wifiEnabled
                toggle.onToggled: Network.enableWifi(checked)
            }

            Toggle {
                label: qsTr("Scanning")
                checked: Network.scanning
                toggle.enabled: false
            }
        }
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Active connection")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Currently connected network")
        color: Colours.palette.m3outline
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: activeConnection.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: activeConnection

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large

            spacing: Appearance.spacing.small / 2

            StyledText {
                text: qsTr("Connected to")
            }

            StyledText {
                text: Network.active?.ssid || qsTr("Not connected")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.normal
                text: qsTr("Signal strength")
            }

            StyledText {
                text: Network.active ? qsTr("%1%").arg(Network.active.strength) : qsTr("N/A")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.normal
                text: qsTr("Frequency")
            }

            StyledText {
                text: Network.active ? qsTr("%1 MHz").arg(Network.active.frequency) : qsTr("N/A")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.normal
                text: qsTr("Security")
            }

            StyledText {
                text: Network.active?.security || qsTr("N/A")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }
        }
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Network tools")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Network management actions")
        color: Colours.palette.m3outline
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: networkTools.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: networkTools

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large

            spacing: Appearance.spacing.larger

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: scanBtn.implicitHeight + Appearance.padding.normal * 2

                radius: Appearance.rounding.small
                color: Colours.palette.m3secondaryContainer

                StateLayer {
                    color: Colours.palette.m3onSecondaryContainer
                    disabled: !Network.wifiEnabled || Network.scanning

                    function onClicked(): void {
                        Network.rescanWifi();
                    }
                }

                RowLayout {
                    id: scanBtn

                    anchors.centerIn: parent
                    spacing: Appearance.spacing.normal

                    MaterialIcon {
                        text: "wifi_find"
                        color: Colours.palette.m3onSecondaryContainer
                        font.pointSize: Appearance.font.size.large
                    }

                    StyledText {
                        text: Network.scanning ? qsTr("Scanning...") : qsTr("Scan for networks")
                        color: Colours.palette.m3onSecondaryContainer
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: disconnectBtn.implicitHeight + Appearance.padding.normal * 2
                visible: Network.active

                radius: Appearance.rounding.small
                color: Colours.palette.m3errorContainer

                StateLayer {
                    color: Colours.palette.m3onErrorContainer
                    disabled: !Network.active

                    function onClicked(): void {
                        Network.disconnectFromNetwork();
                    }
                }

                RowLayout {
                    id: disconnectBtn

                    anchors.centerIn: parent
                    spacing: Appearance.spacing.normal

                    MaterialIcon {
                        text: "link_off"
                        color: Colours.palette.m3onErrorContainer
                        font.pointSize: Appearance.font.size.large
                    }

                    StyledText {
                        text: qsTr("Disconnect")
                        color: Colours.palette.m3onErrorContainer
                    }
                }
            }
        }
    }

    component Toggle: RowLayout {
        required property string label
        property alias checked: toggle.checked
        property alias toggle: toggle

        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        StyledText {
            Layout.fillWidth: true
            text: parent.label
        }

        StyledSwitch {
            id: toggle

            cLayer: 2
        }
    }
}
