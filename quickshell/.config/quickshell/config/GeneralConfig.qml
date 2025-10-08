/**
 * General configuration object - defines system behavior
 *
 * GeneralConfig defines general system settings
 * and battery warning levels.
 *
 * Key features:
 * - Battery warning levels with custom messages and icons
 * - Critical battery level threshold
 *
 * Used by: modules/utilities/, modules/BatteryMonitor.qml
 * Reads from: shell.json → general section
 */
import Quickshell.Io

JsonObject {
    property Battery battery: Battery {}

    component Battery: JsonObject {
        property list<var> warnLevels: [
            {
                level: 20,
                title: qsTr("Low battery"),
                message: qsTr("You might want to plug in a charger"),
                icon: "battery_android_frame_2"
            },
            {
                level: 10,
                title: qsTr("Did you see the previous message?"),
                message: qsTr("You should probably plug in a charger <b>now</b>"),
                icon: "battery_android_frame_1"
            },
            {
                level: 5,
                title: qsTr("Critical battery level"),
                message: qsTr("PLUG THE CHARGER RIGHT NOW!!"),
                icon: "battery_android_alert",
                critical: true
            },
        ]
        property int criticalLevel: 3
    }
}
