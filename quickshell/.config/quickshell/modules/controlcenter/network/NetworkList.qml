pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

StyledFlickable {
    id: root

    required property Session session

    flickableDirection: Flickable.VerticalFlick
    contentHeight: mainLayout.height

    ColumnLayout {
        id: mainLayout

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Appearance.spacing.small

        RowLayout {
            spacing: Appearance.spacing.smaller

            StyledText {
                text: qsTr("WiFi")
                font.pointSize: Appearance.font.size.large
                font.weight: 500
            }

            Item {
                Layout.fillWidth: true
            }

            ToggleButton {
                toggled: Network.wifiEnabled
                icon: "wifi"
                accent: "Tertiary"

                function onClicked(): void {
                    Network.toggleWifi();
                }
            }

            ToggleButton {
                toggled: !root.session.network.active
                icon: "settings"
                accent: "Primary"

                function onClicked(): void {
                    if (root.session.network.active)
                        root.session.network.active = null;
                    else {
                        root.session.network.active = Network.active;
                    }
                }
            }
        }

        RowLayout {
            Layout.topMargin: Appearance.spacing.large
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Available networks (%1)").arg(Network.networks.length)
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Network.wifiEnabled ? qsTr("All available WiFi networks") : qsTr("WiFi is disabled")
                    color: Colours.palette.m3outline
                }
            }

            StyledRect {
                implicitWidth: implicitHeight
                implicitHeight: scanIcon.implicitHeight + Appearance.padding.normal * 2

                radius: Network.scanning ? Appearance.rounding.normal : implicitHeight / 2 * Math.min(1, Appearance.rounding.scale)
                color: Network.scanning ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer

                StateLayer {
                    color: Network.scanning ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                    disabled: !Network.wifiEnabled

                    function onClicked(): void {
                        Network.rescanWifi();
                    }
                }

                MaterialIcon {
                    id: scanIcon

                    anchors.centerIn: parent
                    animate: true
                    text: "wifi_find"
                    color: Network.scanning ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                    fill: Network.scanning ? 1 : 0
                }

                Behavior on radius {
                    Anim {}
                }
            }
        }

        Repeater {
            model: Network.networks

            StyledRect {
                id: network

                required property var modelData
                readonly property bool active: modelData.active
                readonly property bool connecting: Network.isConnecting && Network.connectingToSsid === modelData.ssid

                Layout.fillWidth: true
                implicitHeight: networkInner.implicitHeight + Appearance.padding.normal * 2

                color: Qt.alpha(Colours.tPalette.m3surfaceContainer, root.session.network.active === modelData ? Colours.tPalette.m3surfaceContainer.a : 0)
                radius: Appearance.rounding.normal

                StateLayer {
                    id: stateLayer

                    function onClicked(): void {
                        root.session.network.active = network.modelData;
                    }
                }

                RowLayout {
                    id: networkInner

                    anchors.fill: parent
                    anchors.margins: Appearance.padding.normal

                    spacing: Appearance.spacing.normal

                    StyledRect {
                        implicitWidth: implicitHeight
                        implicitHeight: icon.implicitHeight + Appearance.padding.normal * 2

                        radius: Appearance.rounding.normal
                        color: network.active ? Colours.palette.m3primaryContainer : network.modelData.isSecure ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainerHigh

                        StyledRect {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.alpha(network.active ? Colours.palette.m3onPrimaryContainer : network.modelData.isSecure ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface, stateLayer.pressed ? 0.1 : stateLayer.containsMouse ? 0.08 : 0)
                        }

                        MaterialIcon {
                            id: icon

                            anchors.centerIn: parent
                            text: network.modelData.isSecure ? "lock" : "wifi"
                            color: network.active ? Colours.palette.m3onPrimaryContainer : network.modelData.isSecure ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.large
                            fill: network.active ? 1 : 0

                            Behavior on fill {
                                Anim {}
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: network.modelData.ssid
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: {
                                if (network.connecting) return qsTr("Connecting...");
                                if (network.active) return qsTr("Connected");
                                return qsTr("Signal: %1%").arg(network.modelData.strength);
                            }
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    CircularIndicator {
                        implicitWidth: Appearance.padding.normal * 2
                        implicitHeight: Appearance.padding.normal * 2
                        running: network.connecting
                        visible: network.connecting
                    }

                    StyledRect {
                        id: connectBtn

                        visible: !network.connecting
                        implicitWidth: implicitHeight
                        implicitHeight: connectIcon.implicitHeight + Appearance.padding.smaller * 2

                        radius: Appearance.rounding.full
                        color: Qt.alpha(Colours.palette.m3primaryContainer, network.active ? 1 : 0)

                        StateLayer {
                            color: network.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
                            disabled: !Network.wifiEnabled

                            function onClicked(): void {
                                if (network.active) {
                                    Network.disconnectFromNetwork();
                                } else {
                                    root.session.network.connectingNetwork = network.modelData;
                                    root.session.network.showPasswordDialog = true;
                                }
                            }
                        }

                        MaterialIcon {
                            id: connectIcon

                            anchors.centerIn: parent
                            animate: true
                            text: network.active ? "link_off" : "link"
                            color: network.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface

                            Behavior on opacity {
                                Anim {}
                            }
                        }
                    }
                }
            }
        }
    }

    component ToggleButton: StyledRect {
        id: toggleBtn

        required property bool toggled
        property string icon
        property string label
        property string accent: "Secondary"

        function onClicked(): void {
        }

        Layout.preferredWidth: implicitWidth + (toggleStateLayer.pressed ? Appearance.padding.normal * 2 : toggled ? Appearance.padding.small * 2 : 0)
        implicitWidth: toggleBtnInner.implicitWidth + Appearance.padding.large * 2
        implicitHeight: toggleBtnIcon.implicitHeight + Appearance.padding.normal * 2

        radius: toggled || toggleStateLayer.pressed ? Appearance.rounding.small : Math.min(width, height) / 2 * Math.min(1, Appearance.rounding.scale)
        color: toggled ? Colours.palette[`m3${accent.toLowerCase()}`] : Colours.palette[`m3${accent.toLowerCase()}Container`]

        StateLayer {
            id: toggleStateLayer

            color: toggleBtn.toggled ? Colours.palette[`m3on${toggleBtn.accent}`] : Colours.palette[`m3on${toggleBtn.accent}Container`]

            function onClicked(): void {
                toggleBtn.onClicked();
            }
        }

        RowLayout {
            id: toggleBtnInner

            anchors.centerIn: parent
            spacing: Appearance.spacing.normal

            MaterialIcon {
                id: toggleBtnIcon

                visible: !!text
                fill: toggleBtn.toggled ? 1 : 0
                text: toggleBtn.icon
                color: toggleBtn.toggled ? Colours.palette[`m3on${toggleBtn.accent}`] : Colours.palette[`m3on${toggleBtn.accent}Container`]
                font.pointSize: Appearance.font.size.large

                Behavior on fill {
                    Anim {}
                }
            }

            Loader {
                asynchronous: true
                active: !!toggleBtn.label
                visible: active

                sourceComponent: StyledText {
                    text: toggleBtn.label
                    color: toggleBtn.toggled ? Colours.palette[`m3on${toggleBtn.accent}`] : Colours.palette[`m3on${toggleBtn.accent}Container`]
                }
            }
        }

        Behavior on radius {
            Anim {
                duration: Appearance.anim.durations.expressiveFastSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
            }
        }

        Behavior on Layout.preferredWidth {
            Anim {
                duration: Appearance.anim.durations.expressiveFastSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveFastSpatial
            }
        }
    }
}
