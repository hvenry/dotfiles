/**
 * Material Design icon font renderer
 *
 * MaterialIcon displays icons from the Material Design icon font using
 * variable font axes for customization (fill, grade, optical size, weight).
 *
 * Key features:
 * - Material Design icon font rendering
 * - Variable font axes support (FILL, GRAD, opsz, wght)
 * - Automatic grade adjustment based on theme (light/dark)
 * - Font size from Appearance.font.size.larger
 *
 * Used by: All components displaying Material Design icons
 * Reads from: Colours (light/dark mode), Appearance (fonts)
 * Provides: Icon rendering with text property as icon name
 */
import qs.services
import qs.config

StyledText {
    property real fill
    property int grade: Colours.light ? 0 : -25

    font.family: Appearance.font.family.material
    font.pointSize: Appearance.font.size.larger
    font.variableAxes: ({
            FILL: fill.toFixed(1),
            GRAD: grade,
            opsz: fontInfo.pixelSize,
            wght: fontInfo.weight
        })
}
