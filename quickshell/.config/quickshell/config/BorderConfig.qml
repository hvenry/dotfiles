/**
 * Screen border configuration object
 *
 * BorderConfig defines visual settings for screen border decoration
 * including thickness and rounding.
 *
 * Used by: modules/drawers/Border.qml
 * Reads from: shell.json → border section
 * Provides: Config.border
 */
import Quickshell.Io

JsonObject {
    property int thickness: Appearance.padding.normal
    property int rounding: Appearance.rounding.large
}
