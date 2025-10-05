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
        text: "volume_up"
        font.pointSize: Appearance.font.size.extraLarge * 3
        font.bold: true
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("Audio settings")
        font.pointSize: Appearance.font.size.large
        font.bold: true
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Output volume")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Control output volume and mute")
        color: Colours.palette.m3outline
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: outputVolume.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: outputVolume

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large

            spacing: Appearance.spacing.larger

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    text: Audio.muted ? "volume_off" : "volume_up"
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.large
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Volume (%1)").arg(Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`)
                }

                StyledSwitch {
                    checked: !Audio.muted
                    onToggled: {
                        if (Audio.sink?.audio)
                            Audio.sink.audio.muted = !checked;
                    }
                    cLayer: 2
                }
            }

            CustomMouseArea {
                Layout.fillWidth: true
                implicitHeight: Appearance.padding.normal * 3

                onWheel: event => {
                    if (event.angleDelta.y > 0)
                        Audio.incrementVolume();
                    else if (event.angleDelta.y < 0)
                        Audio.decrementVolume();
                }

                StyledSlider {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: parent.implicitHeight

                    value: Audio.volume
                    onMoved: Audio.setVolume(value)

                    Behavior on value {
                        Anim {}
                    }
                }
            }
        }
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Input volume")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Control input volume and mute")
        color: Colours.palette.m3outline
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: inputVolume.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer

        ColumnLayout {
            id: inputVolume

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large

            spacing: Appearance.spacing.larger

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                MaterialIcon {
                    text: Audio.sourceMuted ? "mic_off" : "mic"
                    color: Colours.palette.m3secondary
                    font.pointSize: Appearance.font.size.large
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Microphone (%1)").arg(Audio.sourceMuted ? qsTr("Muted") : `${Math.round(Audio.sourceVolume * 100)}%`)
                }

                StyledSwitch {
                    checked: !Audio.sourceMuted
                    onToggled: {
                        if (Audio.source?.audio)
                            Audio.source.audio.muted = !checked;
                    }
                    cLayer: 2
                }
            }

            CustomMouseArea {
                Layout.fillWidth: true
                implicitHeight: Appearance.padding.normal * 3

                onWheel: event => {
                    if (event.angleDelta.y > 0)
                        Audio.incrementSourceVolume();
                    else if (event.angleDelta.y < 0)
                        Audio.decrementSourceVolume();
                }

                StyledSlider {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    implicitHeight: parent.implicitHeight

                    value: Audio.sourceVolume
                    onMoved: Audio.setSourceVolume(value)

                    Behavior on value {
                        Anim {}
                    }
                }
            }
        }
    }

    StyledText {
        Layout.topMargin: Appearance.spacing.large
        text: qsTr("Active devices")
        font.pointSize: Appearance.font.size.larger
        font.weight: 500
    }

    StyledText {
        text: qsTr("Currently selected audio devices")
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
                text: qsTr("Output device")
            }

            StyledText {
                text: Audio.sink?.description || Audio.sink?.name || qsTr("No device")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.normal
                text: qsTr("Input device")
            }

            StyledText {
                text: Audio.source?.description || Audio.source?.name || qsTr("No device")
                color: Colours.palette.m3outline
                font.pointSize: Appearance.font.size.small
            }
        }
    }
}
