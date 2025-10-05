import qs.components.controls
import qs.config
import qs.modules.bar.popouts as BarPopouts
import Quickshell
import QtQuick

CustomMouseArea {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts
    required property PersistentProperties visibilities
    required property Panels panels
    required property Item bar

    property point dragStart
    property bool dashboardPinnedOpen
    property bool osdPinnedOpen
    property bool utilitiesPinnedOpen
    property bool sidebarPinnedOpen

    function inTopRightCorner(x: real, y: real): bool {
        const cornerSize = Config.sidebar.hotCornerSize;
        return x >= width - cornerSize && y <= cornerSize;
    }

    function withinPanelHeight(panel: Item, x: real, y: real): bool {
        const panelY = Config.border.thickness + panel.y;
        return y >= panelY - Config.border.rounding && y <= panelY + panel.height + Config.border.rounding;
    }

    function withinPanelWidth(panel: Item, x: real, y: real): bool {
        const panelX = bar.implicitWidth + panel.x;
        return x >= panelX - Config.border.rounding && x <= panelX + panel.width + Config.border.rounding;
    }

    function inLeftPanel(panel: Item, x: real, y: real): bool {
        return x < bar.implicitWidth + panel.x + panel.width && withinPanelHeight(panel, x, y);
    }

    function inRightPanel(panel: Item, x: real, y: real): bool {
        return x > bar.implicitWidth + panel.x && withinPanelHeight(panel, x, y);
    }

    function inTopPanel(panel: Item, x: real, y: real): bool {
        return y < Config.border.thickness + panel.y + panel.height && withinPanelWidth(panel, x, y);
    }

    function inBottomPanel(panel: Item, x: real, y: real): bool {
        return y > root.height - Config.border.thickness - panel.height - Config.border.rounding && withinPanelWidth(panel, x, y);
    }

    function onWheel(event: WheelEvent): void {
        if (event.x < bar.implicitWidth) {
            bar.handleWheel(event.y, event.angleDelta);
        }
    }

    anchors.fill: parent
    hoverEnabled: true

    onPressed: event => dragStart = Qt.point(event.x, event.y)
    onContainsMouseChanged: {
        if (!containsMouse) {
            // Only hide if not pinned open (opened via keybind/click)
            if (!osdPinnedOpen) {
                visibilities.osd = false;
                root.panels.osd.hovered = false;
            }

            if (!dashboardPinnedOpen)
                visibilities.dashboard = false;

            if (!utilitiesPinnedOpen)
                visibilities.utilities = false;

            if (!sidebarPinnedOpen && Config.sidebar.showOnHover)
                visibilities.sidebar = false;

            if (!popouts.currentName.startsWith("traymenu") || (popouts.current?.depth ?? 0) <= 1) {
                popouts.hasCurrent = false;
                bar.closeTray();
            }

            if (Config.bar.showOnHover)
                bar.isHovered = false;
        }
    }

    onPositionChanged: event => {
        if (popouts.isDetached)
            return;

        const x = event.x;
        const y = event.y;
        const dragX = x - dragStart.x;
        const dragY = y - dragStart.y;

        // Show bar in non-exclusive mode on hover
        if (!visibilities.bar && Config.bar.showOnHover && x < bar.implicitWidth)
            bar.isHovered = true;

        // Show/hide bar on drag
        if (pressed && dragStart.x < bar.implicitWidth) {
            if (dragX > Config.bar.dragThreshold)
                visibilities.bar = true;
            else if (dragX < -Config.bar.dragThreshold)
                visibilities.bar = false;
        }

        if (panels.sidebar.width === 0) {
            // Show osd on hover
            const showOsd = inRightPanel(panels.osd, x, y);

            // Always update visibility based on hover if not pinned open
            if (!osdPinnedOpen) {
                visibilities.osd = showOsd;
                root.panels.osd.hovered = showOsd;
            } else if (showOsd) {
                // If hovering over OSD area while pinned, transition to hover control
                osdPinnedOpen = false;
                root.panels.osd.hovered = true;
            }

            const showSidebar = pressed && dragStart.x > bar.implicitWidth + panels.sidebar.x;

            // Show/hide session on drag
            if (pressed && inRightPanel(panels.session, dragStart.x, dragStart.y) && withinPanelHeight(panels.session, x, y)) {
                if (dragX < -Config.session.dragThreshold)
                    visibilities.session = true;
                else if (dragX > Config.session.dragThreshold)
                    visibilities.session = false;

                // Show sidebar on drag if in session area and session is nearly fully visible
                if (showSidebar && panels.session.width >= panels.session.nonAnimWidth && dragX < -Config.sidebar.dragThreshold)
                    visibilities.sidebar = true;
            } else if (showSidebar && dragX < -Config.sidebar.dragThreshold) {
                // Show sidebar on drag if not in session area
                visibilities.sidebar = true;
            }
        } else {
            const outOfSidebar = x < width - panels.sidebar.width;
            // Show osd on hover
            const showOsd = outOfSidebar && inRightPanel(panels.osd, x, y);

            // Always update visibility based on hover if not pinned open
            if (!osdPinnedOpen) {
                visibilities.osd = showOsd;
                root.panels.osd.hovered = showOsd;
            } else if (showOsd) {
                // If hovering over OSD area while pinned, transition to hover control
                osdPinnedOpen = false;
                root.panels.osd.hovered = true;
            }

            // Show/hide session on drag
            if (pressed && outOfSidebar && inRightPanel(panels.session, dragStart.x, dragStart.y) && withinPanelHeight(panels.session, x, y)) {
                if (dragX < -Config.session.dragThreshold)
                    visibilities.session = true;
                else if (dragX > Config.session.dragThreshold)
                    visibilities.session = false;
            }

            // Hide sidebar on drag
            if (pressed && inRightPanel(panels.sidebar, dragStart.x, 0) && dragX > Config.sidebar.dragThreshold)
                visibilities.sidebar = false;
        }

        // Show dashboard on hover
        const showDashboard = Config.dashboard.showOnHover && inTopPanel(panels.dashboard, x, y);

        // Always update visibility based on hover if not pinned open
        if (!dashboardPinnedOpen) {
            visibilities.dashboard = showDashboard;
        } else if (showDashboard) {
            // If hovering over dashboard area while pinned, transition to hover control
            dashboardPinnedOpen = false;
        }

        // Show/hide dashboard on drag (for touchscreen devices)
        if (pressed && inTopPanel(panels.dashboard, dragStart.x, dragStart.y) && withinPanelWidth(panels.dashboard, x, y)) {
            if (dragY > Config.dashboard.dragThreshold)
                visibilities.dashboard = true;
            else if (dragY < -Config.dashboard.dragThreshold)
                visibilities.dashboard = false;
        }

        // Show utilities on hover
        const showUtilities = inBottomPanel(panels.utilities, x, y);

        // Always update visibility based on hover if not pinned open
        if (!utilitiesPinnedOpen) {
            visibilities.utilities = showUtilities;
        } else if (showUtilities) {
            // If hovering over utilities area while pinned, transition to hover control
            utilitiesPinnedOpen = false;
        }

        // Show sidebar on top-right corner hover
        if (Config.sidebar.showOnHover && Config.sidebar.enabled) {
            const showSidebarHover = inTopRightCorner(x, y);

            // Always update visibility based on hover if not pinned open
            if (!sidebarPinnedOpen) {
                if (showSidebarHover && !visibilities.sidebar) {
                    visibilities.sidebar = true;
                }
            } else if (showSidebarHover) {
                // If hovering over hot corner while pinned, transition to hover control
                sidebarPinnedOpen = false;
            }
        }

        // Show popouts on hover
        if (x < bar.implicitWidth) {
            bar.checkPopout(y);
        } else if ((!popouts.currentName.startsWith("traymenu") || (popouts.current?.depth ?? 0) <= 1) && !inLeftPanel(panels.popouts, x, y)) {
            popouts.hasCurrent = false;
            bar.closeTray();
        }
    }

    // Monitor individual visibility changes to manage pinned state
    Connections {
        target: root.visibilities

        function onDashboardChanged() {
            if (root.visibilities.dashboard) {
                // Dashboard became visible, check if opened without hovering (keybind/click)
                const inDashboardArea = root.inTopPanel(root.panels.dashboard, root.mouseX, root.mouseY);
                if (!inDashboardArea) {
                    root.dashboardPinnedOpen = true;
                }
            } else {
                // Dashboard hidden, clear pinned state
                root.dashboardPinnedOpen = false;
            }
        }

        function onOsdChanged() {
            if (root.visibilities.osd) {
                // OSD became visible, check if opened without hovering (keybind/click)
                const inOsdArea = root.inRightPanel(root.panels.osd, root.mouseX, root.mouseY);
                if (!inOsdArea) {
                    root.osdPinnedOpen = true;
                }
            } else {
                // OSD hidden, clear pinned state
                root.osdPinnedOpen = false;
            }
        }

        function onUtilitiesChanged() {
            if (root.visibilities.utilities) {
                // Utilities became visible, check if opened without hovering (keybind/click)
                const inUtilitiesArea = root.inBottomPanel(root.panels.utilities, root.mouseX, root.mouseY);
                if (!inUtilitiesArea) {
                    root.utilitiesPinnedOpen = true;
                }
            } else {
                // Utilities hidden, clear pinned state
                root.utilitiesPinnedOpen = false;
            }
        }

        function onSidebarChanged() {
            if (root.visibilities.sidebar) {
                // Sidebar became visible, check if opened without hovering (keybind/click)
                const inHotCorner = root.inTopRightCorner(root.mouseX, root.mouseY);
                if (!inHotCorner) {
                    root.sidebarPinnedOpen = true;
                }
            } else {
                // Sidebar hidden, clear pinned state
                root.sidebarPinnedOpen = false;
            }
        }
    }
}
