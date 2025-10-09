/**
 * Color scheme management service singleton
 *
 * Colours provides the complete Material Design 3 color palette for the UI,
 * managing theme colors, transparency, and color utilities.
 *
 * Key features:
 * - Material Design 3 color tokens (100+ colors)
 * - Pure monochrome scheme (black/white/grey gradients)
 * - Light/dark mode support
 * - Transparency layer system for glass effects
 * - Color utility functions (luminance, contrast, layer blending)
 * - Separate palettes: palette (base) and tPalette (transparent variants)
 * - Terminal color scheme (term0-term15)
 *
 * Used by: All components for color theming
 * Reads from: Appearance (transparency settings)
 * Provides: palette, tPalette, light, getLuminance(), layer(), on()
 */
pragma Singleton
pragma ComponentBehavior: Bound

import qs.config
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string scheme: "monochrome"
    readonly property string flavour: "dark"
    readonly property bool light: false
    readonly property M3Palette palette: M3Palette {}
    readonly property M3TPalette tPalette: M3TPalette {}
    readonly property Transparency transparency: Transparency {}
    readonly property real wallLuminance: 0

    function getLuminance(c: color): real {
        if (c.r == 0 && c.g == 0 && c.b == 0)
            return 0;
        return Math.sqrt(0.299 * (c.r ** 2) + 0.587 * (c.g ** 2) + 0.114 * (c.b ** 2));
    }

    function alterColour(c: color, a: real, layer: int): color {
        const luminance = getLuminance(c);

        const offset = (!light || layer == 1 ? 1 : -layer / 2) * (light ? 0.2 : 0.3) * (1 - transparency.base) * (1 + wallLuminance * (light ? (layer == 1 ? 3 : 1) : 2.5));
        const scale = (luminance + offset) / luminance;
        const r = Math.max(0, Math.min(1, c.r * scale));
        const g = Math.max(0, Math.min(1, c.g * scale));
        const b = Math.max(0, Math.min(1, c.b * scale));

        return Qt.rgba(r, g, b, a);
    }

    function layer(c: color, layer: var): color {
        if (!transparency.enabled)
            return c;

        return layer === 0 ? Qt.alpha(c, transparency.base) : alterColour(c, transparency.layers, layer ?? 1);
    }

    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.9, 1);
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.1, 1);
    }


    component Transparency: QtObject {
        readonly property bool enabled: Appearance.transparency.enabled
        readonly property real base: Appearance.transparency.base - (root.light ? 0.1 : 0)
        readonly property real layers: Appearance.transparency.layers
    }

    component M3TPalette: QtObject {
        readonly property color m3primary_paletteKeyColor: root.layer(root.palette.m3primary_paletteKeyColor)
        readonly property color m3secondary_paletteKeyColor: root.layer(root.palette.m3secondary_paletteKeyColor)
        readonly property color m3tertiary_paletteKeyColor: root.layer(root.palette.m3tertiary_paletteKeyColor)
        readonly property color m3neutral_paletteKeyColor: root.layer(root.palette.m3neutral_paletteKeyColor)
        readonly property color m3neutral_variant_paletteKeyColor: root.layer(root.palette.m3neutral_variant_paletteKeyColor)
        readonly property color m3background: root.layer(root.palette.m3background, 0)
        readonly property color m3onBackground: root.layer(root.palette.m3onBackground)
        readonly property color m3surface: root.layer(root.palette.m3surface, 0)
        readonly property color m3surfaceDim: root.layer(root.palette.m3surfaceDim, 0)
        readonly property color m3surfaceBright: root.layer(root.palette.m3surfaceBright, 0)
        readonly property color m3surfaceContainerLowest: root.layer(root.palette.m3surfaceContainerLowest, 0)
        readonly property color m3surfaceContainerLow: root.layer(root.palette.m3surfaceContainerLow, 0)
        readonly property color m3surfaceContainer: root.layer(root.palette.m3surfaceContainer, 0)
        readonly property color m3surfaceContainerHigh: root.layer(root.palette.m3surfaceContainerHigh, 0)
        readonly property color m3surfaceContainerHighest: root.layer(root.palette.m3surfaceContainerHighest, 0)
        readonly property color m3onSurface: root.layer(root.palette.m3onSurface)
        readonly property color m3surfaceVariant: root.layer(root.palette.m3surfaceVariant, 0)
        readonly property color m3onSurfaceVariant: root.layer(root.palette.m3onSurfaceVariant)
        readonly property color m3inverseSurface: root.layer(root.palette.m3inverseSurface, 0)
        readonly property color m3inverseOnSurface: root.layer(root.palette.m3inverseOnSurface)
        readonly property color m3outline: root.layer(root.palette.m3outline)
        readonly property color m3outlineVariant: root.layer(root.palette.m3outlineVariant)
        readonly property color m3shadow: root.layer(root.palette.m3shadow)
        readonly property color m3scrim: root.layer(root.palette.m3scrim)
        readonly property color m3surfaceTint: root.layer(root.palette.m3surfaceTint)
        readonly property color m3primary: root.layer(root.palette.m3primary)
        readonly property color m3onPrimary: root.layer(root.palette.m3onPrimary)
        readonly property color m3primaryContainer: root.layer(root.palette.m3primaryContainer)
        readonly property color m3onPrimaryContainer: root.layer(root.palette.m3onPrimaryContainer)
        readonly property color m3inversePrimary: root.layer(root.palette.m3inversePrimary)
        readonly property color m3secondary: root.layer(root.palette.m3secondary)
        readonly property color m3onSecondary: root.layer(root.palette.m3onSecondary)
        readonly property color m3secondaryContainer: root.layer(root.palette.m3secondaryContainer)
        readonly property color m3onSecondaryContainer: root.layer(root.palette.m3onSecondaryContainer)
        readonly property color m3tertiary: root.layer(root.palette.m3tertiary)
        readonly property color m3onTertiary: root.layer(root.palette.m3onTertiary)
        readonly property color m3tertiaryContainer: root.layer(root.palette.m3tertiaryContainer)
        readonly property color m3onTertiaryContainer: root.layer(root.palette.m3onTertiaryContainer)
        readonly property color m3error: root.layer(root.palette.m3error)
        readonly property color m3onError: root.layer(root.palette.m3onError)
        readonly property color m3errorContainer: root.layer(root.palette.m3errorContainer)
        readonly property color m3onErrorContainer: root.layer(root.palette.m3onErrorContainer)
        readonly property color m3success: root.layer(root.palette.m3success)
        readonly property color m3onSuccess: root.layer(root.palette.m3onSuccess)
        readonly property color m3successContainer: root.layer(root.palette.m3successContainer)
        readonly property color m3onSuccessContainer: root.layer(root.palette.m3onSuccessContainer)
        readonly property color m3primaryFixed: root.layer(root.palette.m3primaryFixed)
        readonly property color m3primaryFixedDim: root.layer(root.palette.m3primaryFixedDim)
        readonly property color m3onPrimaryFixed: root.layer(root.palette.m3onPrimaryFixed)
        readonly property color m3onPrimaryFixedVariant: root.layer(root.palette.m3onPrimaryFixedVariant)
        readonly property color m3secondaryFixed: root.layer(root.palette.m3secondaryFixed)
        readonly property color m3secondaryFixedDim: root.layer(root.palette.m3secondaryFixedDim)
        readonly property color m3onSecondaryFixed: root.layer(root.palette.m3onSecondaryFixed)
        readonly property color m3onSecondaryFixedVariant: root.layer(root.palette.m3onSecondaryFixedVariant)
        readonly property color m3tertiaryFixed: root.layer(root.palette.m3tertiaryFixed)
        readonly property color m3tertiaryFixedDim: root.layer(root.palette.m3tertiaryFixedDim)
        readonly property color m3onTertiaryFixed: root.layer(root.palette.m3onTertiaryFixed)
        readonly property color m3onTertiaryFixedVariant: root.layer(root.palette.m3onTertiaryFixedVariant)
    }

    component M3Palette: QtObject {
        property color m3primary_paletteKeyColor: "#ffffff"
        property color m3secondary_paletteKeyColor: "#b0b0b0"
        property color m3tertiary_paletteKeyColor: "#808080"
        property color m3neutral_paletteKeyColor: "#5a5a5a"
        property color m3neutral_variant_paletteKeyColor: "#5a5a5a"
        property color m3background: "#0a0a0a"
        property color m3onBackground: "#e8e8e8"
        property color m3surface: "#0a0a0a"
        property color m3surfaceDim: "#0a0a0a"
        property color m3surfaceBright: "#2e2e2e"
        property color m3surfaceContainerLowest: "#050505"
        property color m3surfaceContainerLow: "#121212"
        property color m3surfaceContainer: "#0f0f0f"
        property color m3surfaceContainerHigh: "#232323"
        property color m3surfaceContainerHighest: "#2e2e2e"
        property color m3onSurface: "#e8e8e8"
        property color m3surfaceVariant: "#404040"
        property color m3onSurfaceVariant: "#c0c0c0"
        property color m3inverseSurface: "#e8e8e8"
        property color m3inverseOnSurface: "#2a2a2a"
        property color m3outline: "#8a8a8a"
        property color m3outlineVariant: "#404040"
        property color m3shadow: "#000000"
        property color m3scrim: "#000000"
        property color m3surfaceTint: "#ffffff"
        property color m3primary: "#ffffff"
        property color m3onPrimary: "#1a1a1a"
        property color m3primaryContainer: "#b0b0b0"
        property color m3onPrimaryContainer: "#000000"
        property color m3inversePrimary: "#5a5a5a"
        property color m3secondary: "#c0c0c0"
        property color m3onSecondary: "#2a2a2a"
        property color m3secondaryContainer: "#404040"
        property color m3onSecondaryContainer: "#b0b0b0"
        property color m3tertiary: "#b0b0b0"
        property color m3onTertiary: "#1a1a1a"
        property color m3tertiaryContainer: "#808080"
        property color m3onTertiaryContainer: "#000000"
        property color m3error: "#ff6b6b"
        property color m3onError: "#690005"
        property color m3errorContainer: "#93000a"
        property color m3onErrorContainer: "#ffdad6"
        property color m3success: "#a0a0a0"
        property color m3onSuccess: "#1a1a1a"
        property color m3successContainer: "#505050"
        property color m3onSuccessContainer: "#d0d0d0"
        property color m3primaryFixed: "#e8e8e8"
        property color m3primaryFixedDim: "#c0c0c0"
        property color m3onPrimaryFixed: "#0a0a0a"
        property color m3onPrimaryFixedVariant: "#404040"
        property color m3secondaryFixed: "#d0d0d0"
        property color m3secondaryFixedDim: "#b0b0b0"
        property color m3onSecondaryFixed: "#0a0a0a"
        property color m3onSecondaryFixedVariant: "#404040"
        property color m3tertiaryFixed: "#d0d0d0"
        property color m3tertiaryFixedDim: "#b0b0b0"
        property color m3onTertiaryFixed: "#0a0a0a"
        property color m3onTertiaryFixedVariant: "#404040"
        property color term0: "#0a0a0a"
        property color term1: "#808080"
        property color term2: "#a0a0a0"
        property color term3: "#b0b0b0"
        property color term4: "#c0c0c0"
        property color term5: "#d0d0d0"
        property color term6: "#e0e0e0"
        property color term7: "#e8e8e8"
        property color term8: "#5a5a5a"
        property color term9: "#909090"
        property color term10: "#b0b0b0"
        property color term11: "#c0c0c0"
        property color term12: "#d0d0d0"
        property color term13: "#e0e0e0"
        property color term14: "#f0f0f0"
        property color term15: "#ffffff"
    }
}
