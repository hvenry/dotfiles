/**
 * DashboardConfig defines settings for the top pulldown dashboard including
 * drag thresholds, hover behavior, media update intervals, and widget sizes.
 *
 * Key features:
 * - Enable/disable dashboard
 * - Show on hover configuration
 * - Media player update interval (milliseconds)
 * - Drag threshold for pulldown activation
 * - Widget size settings (date/time, media, resources, weather, etc.)
 * - Progress indicator sizing (media, resources)
 */
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property bool showOnHover: true
    property int mediaUpdateInterval: 500
    property int dragThreshold: 50
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        readonly property int tabIndicatorHeight: 3
        readonly property int tabIndicatorSpacing: 4
        readonly property int infoWidth: 200
        readonly property int infoIconSize: 25
        readonly property int dateTimeWidth: 180
        readonly property int calendarMinWidth: 500
        readonly property int resourceProgessThickness: 10
        readonly property int weatherWidth: 250
        readonly property int mediaCoverArtSize: 150
        readonly property int mediaVisualiserSize: 80
        readonly property int resourceSize: 200
    }
}
