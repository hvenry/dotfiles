/**
 * Notch configuration object
 *
 * NotchConfig defines settings for MacBook-style notch display area
 * (feature module configuration).
 *
 * Used by: Notch module (if enabled)
 * Reads from: shell.json → notch section
 * Provides: Config.notch
 */
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property int width: 200
        property int height: 35
        property int padding: 20
        property int rounding: 15
    }
}
