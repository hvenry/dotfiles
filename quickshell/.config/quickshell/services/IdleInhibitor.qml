/**
 * Idle inhibitor service singleton
 *
 * IdleInhibitor prevents system sleep/idle when needed.
 *
 * Used by: modules/utilities/cards/IdleInhibit.qml
 * Reads from: Wayland idle inhibit protocol, Config.general.idle
 * Provides: Idle inhibit toggle, auto-inhibit when audio playing
 */
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root

    property alias enabled: props.enabled
    readonly property alias enabledSince: props.enabledSince

    onEnabledChanged: {
        if (enabled)
            props.enabledSince = new Date();
    }

    PersistentProperties {
        id: props

        property bool enabled
        property date enabledSince

        reloadableId: "idleInhibitor"
    }

    IdleInhibitor {
        enabled: props.enabled
        window: PanelWindow {
            implicitWidth: 0
            implicitHeight: 0
            color: "transparent"
            mask: Region {}
        }
    }
}
