/**
 * WInfoConfig defines settings for the window information display module
 * (currently disabled).
 */
import Quickshell.Io

JsonObject {
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property real heightMult: 0.7
        property real detailsWidth: 500
    }
}
