import qs.components
import qs.services
import qs.config
import "dash"
import Quickshell
import QtQuick.Layouts

GridLayout {
    id: root

    required property PersistentProperties visibilities
    required property PersistentProperties state

    rowSpacing: Appearance.spacing.normal
    columnSpacing: Appearance.spacing.normal
    rows: 2
    columns: 3

    // Left column - Weather (top)
    Rect {
        Layout.row: 0
        Layout.column: 0
        Layout.fillHeight: true
        Layout.preferredWidth: Config.dashboard.sizes.weatherWidth

        Weather {}
    }

    // Left column - DateTime (bottom)
    Rect {
        Layout.row: 1
        Layout.column: 0
        Layout.fillHeight: true
        Layout.preferredWidth: Config.dashboard.sizes.weatherWidth

        DateTime {
            id: dateTime
        }
    }

    // Calendar - spans 2 rows
    Rect {
        Layout.row: 0
        Layout.column: 1
        Layout.rowSpan: 2
        Layout.fillWidth: true
        Layout.minimumWidth: Config.dashboard.sizes.calendarMinWidth
        Layout.preferredHeight: calendar.implicitHeight

        Calendar {
            id: calendar

            state: root.state
        }
    }

    // Resources
    Rect {
        Layout.row: 0
        Layout.column: 2
        Layout.rowSpan: 2
        Layout.preferredWidth: resources.implicitWidth
        Layout.fillHeight: true

        Resources {
            id: resources
        }
    }

    component Rect: StyledRect {
        radius: Appearance.rounding.small
        color: Colours.tPalette.m3surfaceContainer
    }
}
