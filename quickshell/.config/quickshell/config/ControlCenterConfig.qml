/**
 * Control Center configuration object
 *
 * ControlCenterConfig defines settings for the control center UI
 * (alternative to sidebar, currently disabled).
 *
 * Used by: modules/controlcenter/ (disabled module)
 * Reads from: shell.json → controlCenter section
 * Provides: Config.controlCenter
 */
import Quickshell.Io

JsonObject {
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property real heightMult: 0.5
        property real ratio: 16 / 9
    }
}
