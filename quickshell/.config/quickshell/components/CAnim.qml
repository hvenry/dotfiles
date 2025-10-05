/**
 * Standard color animation with theme timing
 *
 * CAnim provides a pre-configured ColorAnimation using duration and easing
 * curves from the Appearance configuration. Used for smooth color transitions.
 *
 * Key features:
 * - Duration from Appearance.anim.durations.normal
 * - Easing curve from Appearance.anim.curves.standard (Bezier spline)
 * - Consistent color animation timing across the UI
 *
 * Used by: All components with animated color properties
 * Reads from: Appearance (animation configuration)
 * Provides: Themed color animation
 */
import qs.config
import QtQuick

ColorAnimation {
    duration: Appearance.anim.durations.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Appearance.anim.curves.standard
}
