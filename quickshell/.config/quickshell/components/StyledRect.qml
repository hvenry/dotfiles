/**
 * Base themed rectangle with color animation
 *
 * StyledRect is the foundational rectangle component used throughout the UI.
 * It provides a transparent default color with smooth color transition animations.
 *
 * Key features:
 * - Automatic color animation via CAnim behavior
 * - Transparent default color
 * - Foundation for all styled rectangle-based components
 *
 * Used by: All components that need themed rectangular backgrounds
 * Reads from: None (base component)
 * Provides: Basic rectangle with animated color transitions
 */
import QtQuick

Rectangle {
    id: root

    color: "transparent"

    Behavior on color {
        CAnim {}
    }
}
