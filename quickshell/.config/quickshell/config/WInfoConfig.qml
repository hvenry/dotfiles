/**
 * Window Info configuration object
 *
 * WInfoConfig defines settings for the window information display module
 * (currently disabled).
 *
 * Used by: modules/windowinfo/ (disabled module)
 * Reads from: shell.json → winfo section
 * Provides: Config.winfo
 */
import Quickshell.Io

JsonObject {
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property real heightMult: 0.7
        property real detailsWidth: 500
    }
}
