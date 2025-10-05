pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session
    readonly property PwNode device: session.audio.active
    readonly property bool isSink: device?.isSink ?? true

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
                text: root.isSink ? "volume_up" : "mic"
                font.pointSize: Appearance.font.size.extraLarge * 3
                font.bold: true
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                animate: true
                text: root.device?.description || root.device?.name || qsTr("Unknown device")
                font.pointSize: Appearance.font.size.large
                font.bold: true
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Device status")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("Current device state and controls")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: deviceStatus.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: deviceStatus

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.large

                    spacing: Appearance.spacing.larger

                    Toggle {
                        label: qsTr("Active")
                        checked: root.isSink ? (Audio.sink?.id === root.device?.id) : (Audio.source?.id === root.device?.id)
                        toggle.onToggled: {
                            if (root.isSink)
                                Audio.setAudioSink(root.device);
                            else
                                Audio.setAudioSource(root.device);
                        }
                    }

                    Toggle {
                        label: qsTr("Muted")
                        checked: root.device?.audio?.muted ?? false
                        toggle.onToggled: {
                            if (root.device?.audio)
                                root.device.audio.muted = checked;
                        }
                    }
                }
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Volume control")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("Adjust device volume")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: volumeControl.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: volumeControl

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.large

                    spacing: Appearance.spacing.larger

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.normal

                        MaterialIcon {
                            text: root.device?.audio?.muted ? "volume_off" : root.isSink ? "volume_up" : "mic"
                            color: root.isSink ? Colours.palette.m3primary : Colours.palette.m3secondary
                            font.pointSize: Appearance.font.size.large
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Volume (%1)").arg(root.device?.audio?.muted ? qsTr("Muted") : `${Math.round((root.device?.audio?.volume ?? 0) * 100)}%`)
                        }
                    }

                    CustomMouseArea {
                        Layout.fillWidth: true
                        implicitHeight: Appearance.padding.normal * 3

                        onWheel: event => {
                            if (!root.device?.audio) return;
                            const vol = root.device.audio.volume;
                            const increment = 0.05;
                            if (event.angleDelta.y > 0)
                                root.device.audio.volume = Math.min(1, vol + increment);
                            else if (event.angleDelta.y < 0)
                                root.device.audio.volume = Math.max(0, vol - increment);
                        }

                        StyledSlider {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            implicitHeight: parent.implicitHeight

                            value: root.device?.audio?.volume ?? 0
                            onMoved: {
                                if (root.device?.audio) {
                                    root.device.audio.muted = false;
                                    root.device.audio.volume = value;
                                }
                            }

                            Behavior on value {
                                Anim {}
                            }
                        }
                    }
                }
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.large
                text: qsTr("Device information")
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: qsTr("Technical information about this device")
                color: Colours.palette.m3outline
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: deviceInfo.implicitHeight + Appearance.padding.large * 2

                radius: Appearance.rounding.normal
                color: Colours.tPalette.m3surfaceContainer

                ColumnLayout {
                    id: deviceInfo

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.large

                    spacing: Appearance.spacing.small / 2

                    StyledText {
                        text: qsTr("Device type")
                    }

                    StyledText {
                        text: root.isSink ? qsTr("Output device") : qsTr("Input device")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        Layout.topMargin: Appearance.spacing.normal
                        text: qsTr("Device name")
                    }

                    StyledText {
                        text: root.device?.name ?? qsTr("Unknown")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        Layout.topMargin: Appearance.spacing.normal
                        text: qsTr("Description")
                    }

                    StyledText {
                        text: root.device?.description ?? qsTr("No description")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        Layout.topMargin: Appearance.spacing.normal
                        text: qsTr("Device ID")
                    }

                    StyledText {
                        text: `${root.device?.id ?? -1}`
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        Layout.topMargin: Appearance.spacing.normal
                        text: qsTr("Ready")
                    }

                    StyledText {
                        text: root.device?.ready ? qsTr("Yes") : qsTr("No")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
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
