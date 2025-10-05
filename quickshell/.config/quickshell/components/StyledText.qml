/**
 * Themed text component with color animation
 *
 * StyledText extends Qt's Text component with automatic theming from the Colours
 * and Appearance services. Supports optional text change animations.
 *
 * Key features:
 * - Automatic color binding to Colours.palette.m3onSurface
 * - Font family and size from Appearance config
 * - Optional text change animation (scale/fade effects)
 * - Smooth color transitions
 *
 * Used by: All UI components that display text
 * Reads from: Colours (palette), Appearance (fonts, animations)
 * Provides: Consistently themed text rendering
 */
pragma ComponentBehavior: Bound

import qs.services
import qs.config
import QtQuick

Text {
    id: root

    property bool animate: false
    property string animateProp: "scale"
    property real animateFrom: 0
    property real animateTo: 1
    property int animateDuration: Appearance.anim.durations.normal

    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    color: Colours.palette.m3onSurface
    font.family: Appearance.font.family.sans
    font.pointSize: Appearance.font.size.smaller

    Behavior on color {
        CAnim {}
    }

    Behavior on text {
        enabled: root.animate

        SequentialAnimation {
            Anim {
                to: root.animateFrom
                easing.bezierCurve: Appearance.anim.curves.standardAccel
            }
            PropertyAction {}
            Anim {
                to: root.animateTo
                easing.bezierCurve: Appearance.anim.curves.standardDecel
            }
        }
    }

    component Anim: NumberAnimation {
        target: root
        property: root.animateProp
        duration: root.animateDuration / 2
        easing.type: Easing.BezierSpline
    }
}
