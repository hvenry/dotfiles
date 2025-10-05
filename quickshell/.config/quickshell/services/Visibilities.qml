/**
 * Panel visibility state management service singleton
 *
 * Visibilities tracks which panels are currently visible per screen.
 *
 * Used by: modules/drawers/, all panel modules
 * Reads from: Panel visibility events
 * Provides: Per-screen visibility state tracking
 */
pragma Singleton

import Quickshell

Singleton {
    property var screens: new Map()
    property var bars: new Map()

    function load(screen: ShellScreen, visibilities: var): void {
        screens.set(Hypr.monitorFor(screen), visibilities);
    }

    function getForActive(): PersistentProperties {
        return screens.get(Hypr.focusedMonitor);
    }
}
