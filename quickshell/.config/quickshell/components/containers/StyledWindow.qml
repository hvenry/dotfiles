/**
 * Base themed window for Wayland panels
 *
 * StyledWindow provides a transparent PanelWindow with Wayland layershell support.
 * Used as the foundation for all shell windows (bar, panels, overlays).
 *
 * Key features:
 * - Wayland layershell namespace based on window name
 * - Transparent background (children handle drawing)
 * - Integration with Wayland compositor (Hyprland)
 *
 * Used by: All module wrappers (bar, dashboard, sidebar, etc.)
 * Reads from: None (base window component)
 * Provides: Wayland panel window with unique namespace
 */
import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property string name

    WlrLayershell.namespace: `quickshell-${name}`
    color: "transparent"
}
