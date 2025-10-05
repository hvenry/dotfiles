/**
 * Sidebar (notification center) configuration object
 *
 * SidebarConfig defines settings for the right sidebar notification center
 * including enable/disable and show-on-hover behavior.
 *
 * Used by: modules/sidebar/
 * Reads from: shell.json → sidebar section
 * Provides: Config.sidebar
 */
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property bool showOnHover: false
    property int dragThreshold: 80
    property int hotCornerSize: 50
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property int width: 430
    }
}
