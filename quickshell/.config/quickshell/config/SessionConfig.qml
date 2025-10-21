/**
 * SessionConfig defines settings for the session menu (logout, shutdown, etc.)
 * including keyboard navigation, vim keybinds, and system commands.
 *
 * Key features:
 * - Enable/disable session menu
 * - Drag threshold for dismissing menu
 * - Vim keybinds support (hjkl navigation)
 * - System commands: logout, shutdown, hibernate, reboot
 * - Button size configuration
 */
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property int dragThreshold: 30
    property bool vimKeybinds: false
    property Commands commands: Commands {}

    property Sizes sizes: Sizes {}

    component Commands: JsonObject {
        property list<string> logout: ["loginctl", "terminate-user", ""]
        property list<string> shutdown: ["systemctl", "poweroff"]
        property list<string> hibernate: ["systemctl", "hibernate"]
        property list<string> reboot: ["systemctl", "reboot"]
    }

    component Sizes: JsonObject {
        property int button: 80
    }
}
