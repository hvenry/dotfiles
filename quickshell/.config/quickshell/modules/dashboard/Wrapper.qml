pragma ComponentBehavior: Bound

import qs.components
import qs.config
import qs.utils
import QShell
import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    readonly property PersistentProperties dashState: PersistentProperties {
        property int currentTab
        property date currentDate: new Date()

        reloadableId: "dashboardState"
    }
    readonly property QtObject facePicker: QtObject {
        property string tmpFile: `${Paths.cache}/yazi-selected-face.txt`

        function open(): void {
            // Launch yazi in floating terminal to pick profile picture
            Quickshell.execDetached(["rm", "-f", tmpFile]);

            const yaziCmd = `yazi --chooser-file="${tmpFile}" ~/Pictures`;

            Quickshell.execDetached([
                "ghostty",
                "--class=yazi-picker",
                "--window-width=1200",
                "--window-height=800",
                "-e", "sh", "-c", yaziCmd
            ]);

            // Watch for the selected file
            fileWatcherView.path = tmpFile;
            fileWatcherView.watchChanges = true;
        }
    }

    FileView {
        id: fileWatcherView
        watchChanges: false

        onLoaded: {
            const selectedPath = text().trim();
            watchChanges = false;

            // Clean up temp file
            Quickshell.execDetached(["rm", "-f", path]);

            if (selectedPath) {
                if (CUtils.copyFile(Qt.resolvedUrl(selectedPath), Qt.resolvedUrl(`${Paths.home}/.face`))) {
                    Quickshell.execDetached(["notify-send", "-a", "quickshell", "-u", "low", "Profile picture changed", `Profile picture changed to ${Paths.shortenHome(selectedPath)}`]);
                } else {
                    Quickshell.execDetached(["notify-send", "-a", "quickshell", "-u", "critical", "Unable to change profile picture", `Failed to change profile picture to ${Paths.shortenHome(selectedPath)}`]);
                }
            }
        }

        onLoadFailed: {
            // Silently ignore - file doesn't exist yet
        }
    }

    readonly property real nonAnimHeight: state === "visible" ? (content.item?.nonAnimHeight ?? 0) : 0

    visible: height > 0
    implicitHeight: 0
    implicitWidth: content.implicitWidth

    onStateChanged: {
        if (state === "visible" && timer.running) {
            timer.triggered();
            timer.stop();
        }
    }

    states: State {
        name: "visible"
        when: root.visibilities.dashboard && Config.dashboard.enabled

        PropertyChanges {
            root.implicitHeight: content.implicitHeight
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            Anim {
                target: root
                property: "implicitHeight"
                duration: Appearance.anim.durations.expressiveDefaultSpatial
                easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
            }
        },
        Transition {
            from: "visible"
            to: ""

            Anim {
                target: root
                property: "implicitHeight"
                easing.bezierCurve: Appearance.anim.curves.emphasized
            }
        }
    ]

    Timer {
        id: timer

        running: true
        interval: Appearance.anim.durations.extraLarge
        onTriggered: {
            content.active = Qt.binding(() => (root.visibilities.dashboard && Config.dashboard.enabled) || root.visible);
            content.visible = true;
        }
    }

    Loader {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        visible: false
        active: true

        sourceComponent: Content {
            visibilities: root.visibilities
            state: root.dashState
            facePicker: root.facePicker
        }
    }
}
