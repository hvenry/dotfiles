pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.config
import qs.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects

StyledWindow {
    id: root

    required property ShellScreen screen
    required property var visibilities

    screen: root.screen
    name: "notch"
    WlrLayershell.layer: WlrLayer.Top

    // Always reserve space, even when notch is hidden (prevents window resize flicker)
    exclusiveZone: Config.notch.enabled ? Config.notch.sizes.height : 0

    mask: Region {
        // Define clickable area for the notch (shrinks to 0 when dashboard is open)
        x: root.visibilities.dashboard ? 0 : wrapper.notchX
        y: 0
        width: root.visibilities.dashboard ? 0 : wrapper.notchWidth
        height: root.visibilities.dashboard ? 0 : wrapper.notchHeight
    }

    anchors.top: true
    anchors.left: true
    anchors.right: true

    // Fixed height - always reserve the space
    implicitHeight: Config.notch.enabled ? Config.notch.sizes.height : 0

    Item {
        id: notchContent

        anchors.fill: parent
        opacity: Colours.transparency.enabled ? Colours.transparency.base : 1
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: false
        }

        Wrapper {
            id: wrapper

            anchors.fill: parent
            visibilities: root.visibilities
            // Hide visually when dashboard is open, but keep space reserved
            opacity: root.visibilities.dashboard ? 0 : 1

            Behavior on opacity {
                Anim {
                    duration: Appearance.anim.durations.normal
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }
        }
    }
}
