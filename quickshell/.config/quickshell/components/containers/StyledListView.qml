/**
 * Scrollable list container with themed animations
 *
 * StyledListView extends Qt's ListView with custom flick velocity and
 * rebound animations using the theme's animation curves.
 *
 * Key features:
 * - Limited maximum flick velocity (3000) for controlled scrolling
 * - Themed rebound animation using Anim
 * - Smooth list scrolling behavior
 *
 * Used by: All list-based UI elements (notification lists, app launchers, etc.)
 * Reads from: Anim (for animation timing)
 * Provides: Themed list container
 */
import ".."
import QtQuick

ListView {
    id: root

    maximumFlickVelocity: 3000

    rebound: Transition {
        Anim {
            properties: "x,y"
        }
    }
}
