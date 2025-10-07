pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import qs.utils
import Utils.Audio
import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

RowLayout {
    id: root

    spacing: Config.notch.sizes.padding

    // Activate audio visualization services
    ServiceRef {
        service: Audio.cava
    }

    // Time display (12-hour with seconds and date)
    StyledText {
        id: timeText

        Layout.alignment: Qt.AlignVCenter

        text: Time.format("MMM dd  hh:mm:ss A")
        color: Colours.palette.m3onSurface
        font.pointSize: Appearance.font.size.normal
        font.weight: 500
        font.family: Appearance.font.family.mono
    }

    // Separator
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 1
        Layout.preferredHeight: Config.notch.sizes.height * 0.5
        color: Colours.palette.m3outlineVariant
    }

    // Weather display
    RowLayout {
        id: weatherInfo

        Layout.alignment: Qt.AlignVCenter
        spacing: Appearance.spacing.smaller

        MaterialIcon {
            id: weatherIcon

            Layout.alignment: Qt.AlignVCenter

            animate: true
            text: Weather.icon
            color: Colours.palette.m3secondary
            font.pointSize: Appearance.font.size.large
        }

        StyledText {
            id: weatherTemp

            Layout.alignment: Qt.AlignVCenter

            animate: true
            text: Weather.temp
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.normal
            font.weight: 500
        }
    }

    // Separator (only visible when media exists)
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: Players.active ? 1 : 0
        Layout.preferredHeight: Config.notch.sizes.height * 0.5
        color: Colours.palette.m3outlineVariant
        visible: Layout.preferredWidth > 0

        Behavior on Layout.preferredWidth {
            Anim {
                duration: Appearance.anim.durations.normal
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    }

    // Media display (clickable)
    Item {
        id: mediaDisplay

        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: (Players.active && (Players.active.trackTitle || Players.active.trackArtist)) ? mediaContent.implicitWidth + Appearance.padding.small * 2 : 0
        Layout.preferredHeight: mediaContent.implicitHeight + Appearance.padding.small * 2

        visible: Layout.preferredWidth > 0
        clip: true

        Behavior on Layout.preferredWidth {
            Anim {
                duration: Appearance.anim.durations.normal
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }

        // Invisible clickable area (no hover/ripple effects)
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (Players.active?.canTogglePlaying)
                    Players.active.togglePlaying();
            }
        }

        // Media content
        RowLayout {
            id: mediaContent

            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            MaterialIcon {
                id: playIcon

                Layout.alignment: Qt.AlignVCenter

                text: Players.active?.isPlaying ? "pause_circle" : "play_circle"
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.normal
            }

            ColumnLayout {
                id: mediaText

                Layout.alignment: Qt.AlignVCenter
                spacing: 0

                StyledText {
                    id: trackTitle

                    Layout.alignment: Qt.AlignLeft

                    text: {
                        const title = Players.active?.trackTitle ?? "";
                        return title.length > 24 ? title.substring(0, 24) + "..." : title;
                    }
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.small
                    font.weight: 500
                }

                StyledText {
                    id: trackArtist

                    Layout.alignment: Qt.AlignLeft

                    text: {
                        const artist = Players.active?.trackArtist ?? "";
                        return artist.length > 24 ? artist.substring(0, 24) + "..." : artist;
                    }
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.smaller
                }
            }
        }
    }

    // Audio visualizer (horizontal bars)
    Row {
        id: visualizerContainer

        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: Players.active?.isPlaying ? 120 : 0
        Layout.preferredHeight: Config.notch.sizes.height - 8

        visible: Layout.preferredWidth > 0
        spacing: 2
        clip: true

        Behavior on Layout.preferredWidth {
            Anim {
                duration: Appearance.anim.durations.normal
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }

        Repeater {
            model: 24

            Rectangle {
                required property int index

                readonly property int barIndex: Math.floor(index * Audio.cava.values.length / 24)
                readonly property real value: Audio.cava.values[barIndex] ?? 0

                width: Math.max(1, (visualizerContainer.Layout.preferredWidth / 24) - 2)
                height: Math.max(2, value * visualizerContainer.Layout.preferredHeight)
                anchors.bottom: parent ? parent.bottom : undefined

                color: Colours.palette.m3secondary
                radius: width / 2

                Behavior on height {
                    enabled: visualizerContainer.Layout.preferredWidth > 100
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    // Initialize weather on startup
    Component.onCompleted: Weather.reload()
}
