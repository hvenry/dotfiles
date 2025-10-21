/**
 * Notch configuration object
 *
 * NotchConfig defines settings for MacBook-style notch display area.
 *
 */
import Quickshell.Io
import QtQml

JsonObject {
    property bool enabled: true
    property QtObject sizes: QtObject {
        readonly property int width: 200
        readonly property int height: 35
        readonly property int padding: 20
        readonly property int rounding: 15
        readonly property int gap: 8
    }
}
