pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session
    readonly property var network: session.network.active
    readonly property bool isConnected: network?.active ?? false

    StyledFlickable {
        anchors.fill: parent

        flickableDirection: Flickable.VerticalFlick
        contentHeight: layout.height

        ColumnLayout {
            id: layout

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.spacing.normal

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                animate: true
                text: root.network?.isSecure ? "lock" : "wifi"
                font.pointSize: Appearance.font.size.extraLarge * 3
                font.bold: true
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                animate: true
                text: root.network?.ssid || qsTr("Unknown network")
                font.pointSize: Appearance.font.size.large
                font.bold: true
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Connection status")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("Current connection state")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: networkStatus.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: networkStatus

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.large

                    spacing: Appearance.spacing.larger

                    Toggle {
                        label: qsTr("Connected")
                        checked: root.isConnected
                        toggle.enabled: false
                    }

                    Toggle {
                        label: qsTr("Secure network")
                        checked: root.network?.isSecure ?? false
                        toggle.enabled: false
                    }
                }
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Signal information")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("Signal strength and frequency details")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: signalInfo.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: signalInfo

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.large

                    spacing: Appearance.spacing.larger

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.normal

                        MaterialIcon {
                            text: "signal_cellular_alt"
                            color: Colours.palette.m3primary
                            font.pointSize: Appearance.font.size.large
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Signal strength: %1%").arg(root.network?.strength ?? 0)
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Appearance.padding.smaller

                        Row {
                            anchors.fill: parent
                            spacing: Appearance.spacing.small / 2

                            StyledRect {
                                height: parent.height
                                width: root.network ? (parent.width - spacing) * (root.network.strength / 100) : 0
                                radius: Appearance.rounding.full
                                color: Colours.palette.m3primary
                            }

                            StyledRect {
                                height: parent.height
                                width: root.network ? (parent.width - spacing) * ((100 - root.network.strength) / 100) : parent.width - spacing
                                radius: Appearance.rounding.full
                                color: Colours.palette.m3secondaryContainer
                            }
                        }
                    }
                }
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Network information")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("Technical details about this network")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: networkInfo.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: networkInfo

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.large

                    spacing: Appearance.spacing.small / 2

                    StyledText {
                        text: qsTr("SSID (Network name)")
                    }

                    StyledText {
                        text: root.network?.ssid || qsTr("Unknown")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        Layout.topMargin: Appearance.spacing.normal
                        text: qsTr("BSSID (Access point)")
                    }

                    StyledText {
                        text: root.network?.bssid || qsTr("Unknown")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        Layout.topMargin: Appearance.spacing.normal
                        text: qsTr("Frequency")
                    }

                    StyledText {
                        text: root.network ? qsTr("%1 MHz (%2)").arg(root.network.frequency).arg(root.network.frequency >= 5000 ? "5 GHz" : "2.4 GHz") : qsTr("Unknown")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        Layout.topMargin: Appearance.spacing.normal
                        text: qsTr("Security")
                    }

                    StyledText {
                        text: root.network?.security || qsTr("Open network")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }
                }
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Connection actions")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("Manage this network connection")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: connectionActions.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: connectionActions

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.large

                    spacing: Appearance.spacing.larger

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: connectBtn.implicitHeight + Appearance.padding.normal * 2
                        visible: !root.isConnected

                        radius: Appearance.rounding.small
                        color: Colours.palette.m3primaryContainer

                        StateLayer {
                            color: Colours.palette.m3onPrimaryContainer
                            disabled: !Network.wifiEnabled

                            function onClicked(): void {
                                root.session.network.connectingNetwork = root.network;
                                root.session.network.showPasswordDialog = true;
                            }
                        }

                        RowLayout {
                            id: connectBtn

                            anchors.centerIn: parent
                            spacing: Appearance.spacing.normal

                            MaterialIcon {
                                text: "link"
                                color: Colours.palette.m3onPrimaryContainer
                                font.pointSize: Appearance.font.size.large
                            }

                            StyledText {
                                text: qsTr("Connect to network")
                                color: Colours.palette.m3onPrimaryContainer
                            }
                        }
                    }

                    StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: disconnectBtn.implicitHeight + Appearance.padding.normal * 2
                        visible: root.isConnected

                        radius: Appearance.rounding.small
                        color: Colours.palette.m3errorContainer

                        StateLayer {
                            color: Colours.palette.m3onErrorContainer

                            function onClicked(): void {
                                Network.disconnectFromNetwork();
                                root.session.network.active = null;
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
        }
    }

    // Password dialog overlay
    StyledRect {
        anchors.centerIn: parent
        implicitWidth: Math.min(parent.width - Appearance.padding.large * 4, 400)
        implicitHeight: passwordDialog.implicitHeight + Appearance.padding.large * 4

        visible: root.session.network.showPasswordDialog
        radius: Appearance.rounding.normal
        color: Colours.palette.m3surface

        Elevation {
            anchors.fill: parent
            radius: parent.radius
            level: 3
        }

        ColumnLayout {
            id: passwordDialog

            anchors.centerIn: parent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Appearance.padding.large * 2

            spacing: Appearance.spacing.large

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Enter password for %1").arg(root.session.network.connectingNetwork?.ssid ?? "")
                font.pointSize: Appearance.font.size.large
                font.weight: 500
            }

            StyledTextField {
                id: passwordField

                Layout.fillWidth: true
                placeholderText: qsTr("Password")
                echoMode: TextInput.Password

                onAccepted: {
                    if (text.length > 0 && root.session.network.connectingNetwork) {
                        Network.connectToNetwork(
                            root.session.network.connectingNetwork.ssid,
                            text,
                            root.session.network.connectingNetwork.bssid
                        );
                        root.session.network.showPasswordDialog = false;
                        text = "";
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: cancelBtn.implicitHeight + Appearance.padding.normal * 2

                    radius: Appearance.rounding.small
                    color: Colours.palette.m3secondaryContainer

                    StateLayer {
                        color: Colours.palette.m3onSecondaryContainer

                        function onClicked(): void {
                            root.session.network.showPasswordDialog = false;
                            passwordField.text = "";
                        }
                    }

                    StyledText {
                        id: cancelBtn

                        anchors.centerIn: parent
                        text: qsTr("Cancel")
                        color: Colours.palette.m3onSecondaryContainer
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: okBtn.implicitHeight + Appearance.padding.normal * 2

                    radius: Appearance.rounding.small
                    color: Colours.palette.m3primaryContainer

                    StateLayer {
                        color: Colours.palette.m3onPrimaryContainer

                        function onClicked(): void {
                            passwordField.accepted();
                        }
                    }

                    StyledText {
                        id: okBtn

                        anchors.centerIn: parent
                        text: qsTr("Connect")
                        color: Colours.palette.m3onPrimaryContainer
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
