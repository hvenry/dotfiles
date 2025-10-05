/**
 * Standard number animation with theme timing
 *
 * Anim provides a pre-configured NumberAnimation using duration and easing
 * curves from the Appearance configuration. Used for smooth property transitions.
 *
 * Key features:
 * - Duration from Appearance.anim.durations.normal
 * - Easing curve from Appearance.anim.curves.standard (Bezier spline)
 * - Consistent animation timing across the UI
 *
 * Used by: Components needing numeric property animations
 * Reads from: Appearance (animation configuration)
 * Provides: Themed number animation
 */
import qs.config
import QtQuick

NumberAnimation {
    duration: Appearance.anim.durations.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Appearance.anim.curves.standard
}
