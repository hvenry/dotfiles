pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Services.Pipewire
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
                text: qsTr("Audio")
                font.pointSize: Appearance.font.size.large
                font.weight: 500
            }

            Item {
                Layout.fillWidth: true
            }

            ToggleButton {
                toggled: !root.session.audio.active
                icon: "settings"
                accent: "Primary"

                function onClicked(): void {
                    if (root.session.audio.active)
                        root.session.audio.active = null;
                    else {
                        root.session.audio.active = Audio.sinks[0] ?? null;
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
                    text: qsTr("Output devices (%1)").arg(Audio.sinks.length)
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("All available audio output devices")
                    color: Colours.palette.m3outline
                }
            }
        }

        Repeater {
            model: Audio.sinks

            StyledRect {
                id: device

                required property PwNode modelData
                readonly property bool active: Audio.sink?.id === modelData.id

                Layout.fillWidth: true
                implicitHeight: deviceInner.implicitHeight + Appearance.padding.normal * 2

                color: Qt.alpha(Colours.tPalette.m3surfaceContainer, root.session.audio.active === modelData ? Colours.tPalette.m3surfaceContainer.a : 0)
                radius: Appearance.rounding.normal

                StateLayer {
                    id: stateLayer

                    function onClicked(): void {
                        root.session.audio.active = device.modelData;
                    }
                }

                RowLayout {
                    id: deviceInner

                    anchors.fill: parent
                    anchors.margins: Appearance.padding.normal

                    spacing: Appearance.spacing.normal

                    StyledRect {
                        implicitWidth: implicitHeight
                        implicitHeight: icon.implicitHeight + Appearance.padding.normal * 2

                        radius: Appearance.rounding.normal
                        color: device.active ? Colours.palette.m3primaryContainer : Colours.tPalette.m3surfaceContainerHigh

                        StyledRect {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.alpha(device.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface, stateLayer.pressed ? 0.1 : stateLayer.containsMouse ? 0.08 : 0)
                        }

                        MaterialIcon {
                            id: icon

                            anchors.centerIn: parent
                            text: "volume_up"
                            color: device.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.large
                            fill: device.active ? 1 : 0

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
                            text: device.modelData.description || device.modelData.name
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: device.active ? qsTr("Active") : qsTr("Available")
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    StyledRect {
                        id: selectBtn

                        implicitWidth: implicitHeight
                        implicitHeight: selectIcon.implicitHeight + Appearance.padding.smaller * 2

                        radius: Appearance.rounding.full
                        color: Qt.alpha(Colours.palette.m3primaryContainer, device.active ? 1 : 0)

                        StateLayer {
                            color: device.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface

                            function onClicked(): void {
                                Audio.setAudioSink(device.modelData);
                            }
                        }

                        MaterialIcon {
                            id: selectIcon

                            anchors.centerIn: parent
                            animate: true
                            text: device.active ? "check" : "radio_button_unchecked"
                            color: device.active ? Colours.palette.m3onPrimaryContainer : Colours.palette.m3onSurface

                            Behavior on opacity {
                                Anim {}
                            }
                        }
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
                    text: qsTr("Input devices (%1)").arg(Audio.sources.length)
                    font.pointSize: Appearance.font.size.large
                    font.weight: 500
                }

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("All available audio input devices")
                    color: Colours.palette.m3outline
                }
            }
        }

        Repeater {
            model: Audio.sources

            StyledRect {
                id: source

                required property PwNode modelData
                readonly property bool active: Audio.source?.id === modelData.id

                Layout.fillWidth: true
                implicitHeight: sourceInner.implicitHeight + Appearance.padding.normal * 2

                color: Qt.alpha(Colours.tPalette.m3surfaceContainer, root.session.audio.active === modelData ? Colours.tPalette.m3surfaceContainer.a : 0)
                radius: Appearance.rounding.normal

                StateLayer {
                    id: sourceStateLayer

                    function onClicked(): void {
                        root.session.audio.active = source.modelData;
                    }
                }

                RowLayout {
                    id: sourceInner

                    anchors.fill: parent
                    anchors.margins: Appearance.padding.normal

                    spacing: Appearance.spacing.normal

                    StyledRect {
                        implicitWidth: implicitHeight
                        implicitHeight: sourceIcon.implicitHeight + Appearance.padding.normal * 2

                        radius: Appearance.rounding.normal
                        color: source.active ? Colours.palette.m3secondaryContainer : Colours.tPalette.m3surfaceContainerHigh

                        StyledRect {
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.alpha(source.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface, sourceStateLayer.pressed ? 0.1 : sourceStateLayer.containsMouse ? 0.08 : 0)
                        }

                        MaterialIcon {
                            id: sourceIcon

                            anchors.centerIn: parent
                            text: "mic"
                            color: source.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.large
                            fill: source.active ? 1 : 0

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
                            text: source.modelData.description || source.modelData.name
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: source.active ? qsTr("Active") : qsTr("Available")
                            color: Colours.palette.m3outline
                            font.pointSize: Appearance.font.size.small
                            elide: Text.ElideRight
                        }
                    }

                    StyledRect {
                        id: sourceSelectBtn

                        implicitWidth: implicitHeight
                        implicitHeight: sourceSelectIcon.implicitHeight + Appearance.padding.smaller * 2

                        radius: Appearance.rounding.full
                        color: Qt.alpha(Colours.palette.m3secondaryContainer, source.active ? 1 : 0)

                        StateLayer {
                            color: source.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

                            function onClicked(): void {
                                Audio.setAudioSource(source.modelData);
                            }
                        }

                        MaterialIcon {
                            id: sourceSelectIcon

                            anchors.centerIn: parent
                            animate: true
                            text: source.active ? "check" : "radio_button_unchecked"
                            color: source.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

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
