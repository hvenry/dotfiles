/**
 * Time and date utilities service singleton
 *
 * Time provides formatted time strings and date calculations.
 *
 * Used by: modules/bar/components/Clock.qml, modules/dashboard/dash/DateTime.qml
 * Reads from: System clock
 * Provides: Formatted time/date strings, date calculations
 */
pragma Singleton

import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
