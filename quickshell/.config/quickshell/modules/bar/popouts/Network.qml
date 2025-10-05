pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property var wrapper

    property string passwordPromptSsid: ""

    spacing: Appearance.spacing.small
    width: Config.bar.sizes.networkWidth

    StyledText {
        Layout.topMargin: Appearance.padding.normal
        Layout.rightMargin: Appearance.padding.small
        text: qsTr("Wifi %1").arg(Network.wifiEnabled ? "enabled" : "disabled")
        font.weight: 500
    }

    Toggle {
        label: qsTr("Enabled")
        checked: Network.wifiEnabled
        toggle.onToggled: Network.enableWifi(checked)
    }

    StyledRect {
        Layout.topMargin: Appearance.spacing.small
        Layout.fillWidth: true
        implicitHeight: rescanBtn.implicitHeight + Appearance.padding.small * 2

        radius: Appearance.rounding.full
        color: Colours.palette.m3primaryContainer

        StateLayer {
            color: Colours.palette.m3onPrimaryContainer
            disabled: Network.scanning || !Network.wifiEnabled

            function onClicked(): void {
                Network.rescanWifi();
            }
        }

        RowLayout {
            id: rescanBtn

            anchors.centerIn: parent
            spacing: Appearance.spacing.small
            opacity: Network.scanning ? 0 : 1

            MaterialIcon {
                id: scanIcon

                animate: true
                text: "wifi_find"
                color: Colours.palette.m3onPrimaryContainer
            }

            StyledText {
                text: qsTr("Rescan networks")
                color: Colours.palette.m3onPrimaryContainer
            }

            Behavior on opacity {
                Anim {}
            }
        }

        CircularIndicator {
            anchors.centerIn: parent
            strokeWidth: Appearance.padding.small / 2
            bgColour: "transparent"
            implicitHeight: parent.implicitHeight - Appearance.padding.smaller * 2
            running: Network.scanning
        }
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.small
        Layout.rightMargin: Appearance.padding.small
        text: qsTr("%1 networks available").arg(Network.networks.length)
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.small
    }

    Repeater {
        model: ScriptModel {
            values: [...Network.networks].sort((a, b) => {
                if (a.active !== b.active)
                    return b.active - a.active;
                return b.strength - a.strength;
            }).slice(0, 8)
        }

        ColumnLayout {
            id: networkWrapper
            required property Network.AccessPoint modelData

            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            RowLayout {
                id: networkItem

                readonly property bool isConnecting: Network.connectingToSsid === networkWrapper.modelData.ssid
                readonly property bool loading: networkItem.isConnecting || (Network.isConnecting && networkWrapper.modelData.ssid === Network.connectingToSsid)

                Layout.fillWidth: true
                Layout.rightMargin: Appearance.padding.small
                spacing: Appearance.spacing.small

                opacity: 0
                scale: 0.7

                Component.onCompleted: {
                    opacity = 1;
                    scale = 1;
                }

                Behavior on opacity {
                    Anim {}
                }

                Behavior on scale {
                    Anim {}
                }

                MaterialIcon {
                    text: Icons.getNetworkIcon(networkWrapper.modelData.strength)
                    color: networkWrapper.modelData.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }

                MaterialIcon {
                    visible: networkWrapper.modelData.isSecure
                    text: "lock"
                    font.pointSize: Appearance.font.size.small
                }

                StyledText {
                    Layout.leftMargin: Appearance.spacing.small / 2
                    Layout.rightMargin: Appearance.spacing.small / 2
                    Layout.fillWidth: true
                    text: networkWrapper.modelData.ssid
                    elide: Text.ElideRight
                    font.weight: networkWrapper.modelData.active ? 500 : 400
                    color: networkWrapper.modelData.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
                }

                StyledRect {
                    id: connectBtn

                    implicitWidth: implicitHeight
                    implicitHeight: connectIcon.implicitHeight + Appearance.padding.small

                    radius: Appearance.rounding.full
                    color: Qt.alpha(Colours.palette.m3primary, networkWrapper.modelData.active ? 1 : 0)

                    CircularIndicator {
                        anchors.fill: parent
                        running: networkItem.loading
                    }

                    StateLayer {
                        color: networkWrapper.modelData.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        disabled: networkItem.loading || !Network.wifiEnabled

                        function onClicked(): void {
                            if (networkWrapper.modelData.active) {
                                Network.disconnectFromNetwork();
                            } else if (networkWrapper.modelData.isSecure && root.passwordPromptSsid !== networkWrapper.modelData.ssid) {
                                // Show password prompt for secure networks
                                root.passwordPromptSsid = networkWrapper.modelData.ssid;
                            } else {
                                // Connect to open network
                                Network.connectToNetwork(networkWrapper.modelData.ssid, "", networkWrapper.modelData.bssid);
                            }
                        }
                    }

                    MaterialIcon {
                        id: connectIcon

                        anchors.centerIn: parent
                        animate: true
                        text: networkWrapper.modelData.active ? "link_off" : "link"
                        color: networkWrapper.modelData.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

                        opacity: networkItem.loading ? 0 : 1

                        Behavior on opacity {
                            Anim {}
                        }
                    }
                }
            }

            // Password input field
            RowLayout {
                id: passwordRow

                Layout.fillWidth: true
                Layout.rightMargin: Appearance.padding.small
                Layout.leftMargin: Appearance.padding.normal
                spacing: Appearance.spacing.small

                visible: root.passwordPromptSsid === networkWrapper.modelData.ssid
                opacity: visible ? 1 : 0
                Layout.preferredHeight: visible ? implicitHeight : 0

                Behavior on opacity {
                    Anim {}
                }

                Behavior on Layout.preferredHeight {
                    Anim {}
                }

                StyledTextField {
                    id: passwordField

                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter password")
                    echoMode: TextInput.Password
                    focus: true

                    Component.onCompleted: {
                        if (visible) {
                            forceActiveFocus();
                        }
                    }

                    onVisibleChanged: {
                        if (visible) {
                            forceActiveFocus();
                        }
                    }

                    Keys.onReturnPressed: {
                        if (text.length > 0) {
                            Network.connectToNetwork(networkWrapper.modelData.ssid, text, networkWrapper.modelData.bssid);
                            root.passwordPromptSsid = "";
                            text = "";
                        }
                    }

                    Keys.onEscapePressed: {
                        root.passwordPromptSsid = "";
                        text = "";
                    }
                }

                StyledRect {
                    implicitWidth: implicitHeight
                    implicitHeight: connectPasswordIcon.implicitHeight + Appearance.padding.small

                    radius: Appearance.rounding.full
                    color: Colours.palette.m3primary

                    StateLayer {
                        color: Colours.palette.m3onPrimary
                        disabled: passwordField.text.length === 0

                        function onClicked(): void {
                            Network.connectToNetwork(networkWrapper.modelData.ssid, passwordField.text, networkWrapper.modelData.bssid);
                            root.passwordPromptSsid = "";
                            passwordField.text = "";
                        }
                    }

                    MaterialIcon {
                        id: connectPasswordIcon

                        anchors.centerIn: parent
                        text: "check"
                        color: Colours.palette.m3onPrimary
                    }
                }

                StyledRect {
                    implicitWidth: implicitHeight
                    implicitHeight: cancelIcon.implicitHeight + Appearance.padding.small

                    radius: Appearance.rounding.full
                    color: Colours.palette.m3surfaceContainerHighest

                    StateLayer {
                        color: Colours.palette.m3onSurface

                        function onClicked(): void {
                            root.passwordPromptSsid = "";
                            passwordField.text = "";
                        }
                    }

                    MaterialIcon {
                        id: cancelIcon

                        anchors.centerIn: parent
                        text: "close"
                        color: Colours.palette.m3onSurface
                    }
                }
            }
        }
    }

    StyledRect {
        Layout.topMargin: Appearance.spacing.normal

        implicitWidth: expandBtn.implicitWidth + Appearance.padding.normal * 2
        implicitHeight: expandBtn.implicitHeight + Appearance.padding.small

        radius: Appearance.rounding.normal
        color: Colours.palette.m3primaryContainer

        StateLayer {
            color: Colours.palette.m3onPrimaryContainer

            function onClicked(): void {
                root.wrapper.detach("network");
            }
        }

        RowLayout {
            id: expandBtn

            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            StyledText {
                Layout.leftMargin: Appearance.padding.smaller
                text: qsTr("Open panel")
                color: Colours.palette.m3onPrimaryContainer
            }

            MaterialIcon {
                text: "chevron_right"
                color: Colours.palette.m3onPrimaryContainer
                font.pointSize: Appearance.font.size.large
            }
        }
    }

    // Reset password prompt when connection completes
    Connections {
        target: Network

        function onIsConnectingChanged(): void {
            if (!Network.isConnecting) {
                root.passwordPromptSsid = "";
            }
        }

        function onScanningChanged(): void {
            if (!Network.scanning)
                scanIcon.rotation = 0;
        }
    }

    component Toggle: RowLayout {
        required property string label
        property alias checked: toggle.checked
        property alias toggle: toggle

        Layout.fillWidth: true
        Layout.rightMargin: Appearance.padding.small
        spacing: Appearance.spacing.normal

        StyledText {
            Layout.fillWidth: true
            text: parent.label
        }

        StyledSwitch {
            id: toggle
        }
    }
}
