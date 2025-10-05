/**
 * Rectangle with clipping support for rounded corners
 *
 * StyledClippingRect extends Quickshell's ClippingRectangle with color animation.
 * Used when content needs to be clipped to rounded corner boundaries.
 *
 * Key features:
 * - Automatic clipping of child content to rounded corners
 * - Smooth color transition animations
 * - Transparent default color
 *
 * Used by: Components requiring content clipping (StateLayer, etc.)
 * Reads from: None (base component)
 * Provides: Clipping rectangle with animated colors
 */
import Quickshell.Widgets
import QtQuick

ClippingRectangle {
    id: root

    color: "transparent"

    Behavior on color {
        CAnim {}
    }
}
