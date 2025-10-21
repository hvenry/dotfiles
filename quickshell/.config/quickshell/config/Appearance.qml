/**
 * Appearance configuration shortcut singleton
 *
 * Key features:
 * - Shortcut aliases for rounding, spacing, padding, font, anim, transparency
 * - Allows `Appearance.spacing.large` instead of `Config.appearance.spacing.large`
 * - Read-only properties (aliases to Config.appearance)
 */
pragma Singleton

import Quickshell

Singleton {
    readonly property AppearanceConfig.Rounding rounding: Config.appearance.rounding
    readonly property AppearanceConfig.Spacing spacing: Config.appearance.spacing
    readonly property AppearanceConfig.Padding padding: Config.appearance.padding
    readonly property AppearanceConfig.FontStuff font: Config.appearance.font
    readonly property AppearanceConfig.Anim anim: Config.appearance.anim
    readonly property AppearanceConfig.Transparency transparency: Config.appearance.transparency
}
