/**
 * ControlCenterConfig defines settings for the control center UI
 * (alternative to sidebar, currently disabled).
 */
import Quickshell.Io

JsonObject {
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property real heightMult: 0.5
        property real ratio: 16 / 9
    }
}
