import qs.components
import qs.services
import qs.config
import QtQuick

StyledRect {
    id: root

    required property real notchWidth
    required property real notchHeight

    width: notchWidth
    height: notchHeight

    radius: Config.notch.sizes.rounding
    color: Colours.tPalette.m3surface
}
