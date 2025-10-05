/**
 * Scrollable area with themed animations
 *
 * StyledFlickable extends Qt's Flickable with custom flick velocity and
 * rebound animations using the theme's animation curves.
 *
 * Key features:
 * - Limited maximum flick velocity (3000) for controlled scrolling
 * - Themed rebound animation using Anim
 * - Smooth scrolling behavior
 *
 * Used by: Scrollable content areas throughout the UI
 * Reads from: Anim (for animation timing)
 * Provides: Themed scrollable container
 */
import ".."
import QtQuick

Flickable {
    id: root

    maximumFlickVelocity: 3000

    rebound: Transition {
        Anim {
            properties: "x,y"
        }
    }
}
