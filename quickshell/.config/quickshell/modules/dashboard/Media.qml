pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.components.controls
import qs.services
import qs.utils
import qs.config
import QShell.Audio
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties visibilities

    property real playerProgress: {
        const active = Players.active;
        return active?.length ? active.position / active.length : 0;
    }

    function lengthStr(length: int): string {
        if (length < 0)
            return "-1:-1";

        const hours = Math.floor(length / 3600);
        const mins = Math.floor((length % 3600) / 60);
        const secs = Math.floor(length % 60).toString().padStart(2, "0");

        if (hours > 0)
            return `${hours}:${mins.toString().padStart(2, "0")}:${secs}`;
        return `${mins}:${secs}`;
    }

    implicitWidth: 600
    implicitHeight: mainLayout.implicitHeight + Appearance.padding.large * 2

    Timer {
        running: Players.active?.isPlaying ?? false
        interval: Config.dashboard.mediaUpdateInterval
        triggeredOnStart: true
        repeat: true
        onTriggered: Players.active?.positionChanged()
    }

    ServiceRef {
        service: Audio.cava
    }

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        // Top section: Album cover + Song info + Audio visualizer
        RowLayout {
            id: topSection

            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            // Album cover (square, left side)
            StyledClippingRect {
                id: cover

                Layout.preferredWidth: 175
                Layout.preferredHeight: 175
                Layout.alignment: Qt.AlignTop

                color: Colours.tPalette.m3surfaceContainerHigh
                radius: 0

                MaterialIcon {
                    anchors.centerIn: parent

                    grade: 200
                    text: "art_track"
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: (parent.width * 0.4) || 1
                }

                Image {
                    id: image

                    anchors.fill: parent

                    source: Players.active?.trackArtUrl ?? ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: width
                    sourceSize.height: height
                }
            }

            // Song info + visualizer (right of album cover)
            ColumnLayout {
                id: rightSection

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                spacing: Appearance.spacing.small

                // Song info
                ColumnLayout {
                    id: songInfo

                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small

                    StyledText {
                        id: title

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft

                        animate: false
                        horizontalAlignment: Text.AlignLeft
                        text: (Players.active?.trackTitle ?? qsTr("No media")) || qsTr("Unknown title")
                        color: Players.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.large
                        font.weight: 600
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }

                    StyledText {
                        id: album

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft

                        animate: false
                        horizontalAlignment: Text.AlignLeft
                        visible: !!Players.active
                        text: Players.active?.trackAlbum || qsTr("Unknown album")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.normal
                        elide: Text.ElideRight
                    }

                    StyledText {
                        id: artist

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignLeft

                        animate: false
                        horizontalAlignment: Text.AlignLeft
                        text: (Players.active?.trackArtist ?? qsTr("Play some music for stuff to show up here!")) || qsTr("Unknown artist")
                        color: Players.active ? Colours.palette.m3secondary : Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.normal
                        elide: Text.ElideRight
                        wrapMode: Players.active ? Text.NoWrap : Text.WordWrap
                    }
                }

                // Audio visualizer (below song info, aligned with album cover height)
                Row {
                    id: visualizerContainer

                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    Layout.topMargin: Appearance.spacing.smaller

                    spacing: 2
                    clip: true

                    Repeater {
                        model: Math.max(0, Math.floor((visualizerContainer.width - (visualizerContainer.spacing * 63)) / 4))

                        Rectangle {
                            required property int index

                            readonly property int barIndex: Math.floor(index * Audio.cava.values.length / visualizerContainer.children.length)
                            readonly property real value: Audio.cava.values[barIndex] ?? 0

                            width: 4
                            height: Math.max(4, value * visualizerContainer.Layout.preferredHeight)
                            anchors.bottom: parent ? parent.bottom : undefined

                            color: Players.active?.isPlaying ? Colours.palette.m3secondary : Colours.palette.m3outlineVariant
                            radius: width / 2

                            Behavior on height {
                                enabled: Players.active?.isPlaying ?? false
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on color {
                                CAnim {}
                            }
                        }
                    }
                }
            }
        }

        // Progress bar section with timers
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.spacing.small
            spacing: Appearance.spacing.smaller

            // Progress bar (thin rectangle)
            Rectangle {
                id: progressBarBackground

                Layout.fillWidth: true
                Layout.preferredHeight: 4

                color: Colours.palette.m3surfaceContainerHigh

                Rectangle {
                    id: progressBarFill

                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    width: parent.width * root.playerProgress
                    color: Colours.palette.m3onSurface

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        const active = Players.active;
                        if (active?.canSeek && active?.positionSupported) {
                            const clickProgress = mouse.x / width;
                            active.position = clickProgress * active.length;
                            root.playerProgress = clickProgress;
                        }
                    }
                }
            }

            // Time display (elapsed / total)
            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    id: elapsedTime

                    Layout.alignment: Qt.AlignLeft

                    text: root.lengthStr(Players.active?.position ?? 0)
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    id: totalTime

                    Layout.alignment: Qt.AlignRight

                    text: root.lengthStr(Players.active?.length ?? 0)
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }
            }
        }

        // Media controls (centered)
        RowLayout {
            id: controls

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 0
            Layout.bottomMargin: 0
            spacing: Appearance.spacing.smaller

            PlayerControl {
                type: IconButton.Text
                icon: Players.active?.shuffleState === MprisPlayer.On ? "shuffle_on" : "shuffle"
                inactiveOnColour: Players.active?.shuffleState === MprisPlayer.On ? Colours.palette.m3primary : Colours.palette.m3onSurface
                padding: 0
                font.pointSize: Appearance.font.size.large
                disabled: !Players.active
                onClicked: {
                    if (Players.active)
                        Players.active.shuffleState = Players.active.shuffleState === MprisPlayer.On ? MprisPlayer.Off : MprisPlayer.On;
                }
            }

            PlayerControl {
                type: IconButton.Text
                icon: "skip_previous"
                padding: 0
                font.pointSize: Math.round(Appearance.font.size.large * 1.5)
                disabled: !Players.active?.canGoPrevious
                onClicked: Players.active?.previous()
            }

            PlayerControl {
                type: IconButton.Text
                icon: Players.active?.isPlaying ? "pause" : "play_arrow"
                label.animate: true
                padding: 0
                font.pointSize: Math.round(Appearance.font.size.extraLarge * 1.2)
                disabled: !Players.active?.canTogglePlaying
                onClicked: Players.active?.togglePlaying()
            }

            PlayerControl {
                type: IconButton.Text
                icon: "skip_next"
                padding: 0
                font.pointSize: Math.round(Appearance.font.size.large * 1.5)
                disabled: !Players.active?.canGoNext
                onClicked: Players.active?.next()
            }

            PlayerControl {
                type: IconButton.Text
                icon: "favorite"
                inactiveOnColour: Colours.palette.m3error
                padding: 0
                font.pointSize: Appearance.font.size.large
                disabled: !Players.active
                onClicked:
                // Like functionality - placeholder for now
                {}
            }
        }
    }

    component PlayerControl: IconButton {
        radius: 0
    }
}
