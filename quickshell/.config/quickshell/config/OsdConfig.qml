/**
 * OSD (On-Screen Display) configuration object
 *
 * OsdConfig defines settings for OSD popups that show volume, brightness,
 * and media controls with visual feedback.
 *
 * Used by: modules/osd/
 * Reads from: shell.json → osd section
 * Provides: Config.osd
 */
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property int hideDelay: 2000
    property bool enableBrightness: true
    property bool enableMicrophone: false
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property int sliderWidth: 30
        property int sliderHeight: 150
    }
}
