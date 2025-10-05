/**
 * Game mode service singleton
 *
 * GameMode manages gaming-specific system optimizations.
 *
 * Used by: modules/utilities/ (if enabled)
 * Reads from: GameMode daemon
 * Provides: Game mode toggle and status
 */
pragma Singleton

import qs.services
import qs.config
import QShell
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property alias enabled: props.enabled

    function setDynamicConfs(): void {
        Hypr.extras.applyOptions({
            "animations:enabled": 0,
            "decoration:shadow:enabled": 0,
            "decoration:blur:enabled": 0,
            "general:gaps_in": 0,
            "general:gaps_out": 0,
            "general:border_size": 1,
            "decoration:rounding": 0,
            "general:allow_tearing": 1
        });
    }

    onEnabledChanged: {
        if (enabled) {
            setDynamicConfs();
            if (Config.utilities.toasts.gameModeChanged)
                Toaster.toast(qsTr("Game mode enabled"), qsTr("Disabled Hyprland animations, blur, gaps and shadows"), "gamepad");
        } else {
            Hypr.extras.message("reload");
            if (Config.utilities.toasts.gameModeChanged)
                Toaster.toast(qsTr("Game mode disabled"), qsTr("Hyprland settings restored"), "gamepad");
        }
    }

    PersistentProperties {
        id: props

        property bool enabled: Hypr.options["animations:enabled"] === 0

        reloadableId: "gameMode"
    }

    Connections {
        target: Hypr

        function onConfigReloaded(): void {
            if (props.enabled)
                root.setDynamicConfs();
        }
    }
}
