pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.services
import qs.config
import qs.modules.bar
import qs.modules.notch as Notch
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        PersistentProperties {
            id: visibilities

            property bool bar
            property bool osd
            property bool session
            property bool dashboard
            property bool utilities
            property bool sidebar

            Component.onCompleted: Visibilities.load(scope.modelData, this)
        }

        Exclusions {
            screen: scope.modelData
            bar: bar
        }

        StyledWindow {
            id: win

            readonly property bool hasFullscreen: Hypr.monitorFor(screen)?.activeWorkspace?.toplevels.values.some(t => t.lastIpcObject.fullscreen === 2) ?? false
            readonly property int dragMaskPadding: {
                if (focusGrab.active || panels.popouts.isDetached)
                    return 0;

                const mon = Hypr.monitorFor(screen);
                if (mon?.activeWorkspace?.lastIpcObject.windows > 0)
                    return 0;

                const thresholds = [];
                for (const panel of ["dashboard", "session", "sidebar"])
                    if (Config[panel].enabled)
                        thresholds.push(Config[panel].dragThreshold);
                return Math.max(...thresholds);
            }

            onHasFullscreenChanged: {
                visibilities.session = false;
                visibilities.dashboard = false;
            }

            screen: scope.modelData
            name: "drawers"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: visibilities.session || panels.popouts.hasCurrent ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            mask: Region {
                x: bar.implicitWidth + win.dragMaskPadding
                y: Config.border.thickness + win.dragMaskPadding
                width: win.width - bar.implicitWidth - Config.border.thickness - win.dragMaskPadding * 2
                height: win.height - Config.border.thickness * 2 - win.dragMaskPadding * 2
                intersection: Intersection.Xor

                regions: [notchRegion, ...regions.instances]
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Region {
                id: notchRegion

                x: Config.notch.enabled && !visibilities.dashboard ? notchWrapper.notchX + bar.implicitWidth : 0
                y: Config.notch.enabled && !visibilities.dashboard ? Config.border.thickness : 0
                width: Config.notch.enabled && !visibilities.dashboard ? notchWrapper.notchWidth : 0
                height: Config.notch.enabled && !visibilities.dashboard ? notchWrapper.notchHeight : 0
                intersection: Intersection.Subtract
            }

            Variants {
                id: regions

                model: panels.children

                Region {
                    required property Item modelData

                    x: modelData.x + bar.implicitWidth
                    y: modelData.y + Config.border.thickness
                    width: modelData.width
                    height: modelData.height
                    intersection: Intersection.Subtract
                }
            }

            HyprlandFocusGrab {
                id: focusGrab

                active: (visibilities.session && Config.session.enabled) || (visibilities.sidebar && Config.sidebar.enabled) || (!Config.dashboard.showOnHover && visibilities.dashboard && Config.dashboard.enabled) || (panels.popouts.currentName.startsWith("traymenu") && panels.popouts.current?.depth > 1)
                windows: [win]
                onCleared: {
                    visibilities.session = false;
                    visibilities.sidebar = false;
                    visibilities.dashboard = false;
                    panels.popouts.hasCurrent = false;
                    bar.closeTray();
                }
            }

            StyledRect {
                anchors.fill: parent
                opacity: visibilities.session && Config.session.enabled ? 0.5 : 0
                color: Colours.palette.m3scrim

                Behavior on opacity {
                    Anim {}
                }
            }

            Item {
                anchors.fill: parent
                opacity: Colours.transparency.enabled ? Colours.transparency.base : 1
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: false
                }

                Border {
                    bar: bar
                }

                Backgrounds {
                    panels: panels
                    bar: bar
                }
            }

            Interactions {
                screen: scope.modelData
                popouts: panels.popouts
                visibilities: visibilities
                panels: panels
                bar: bar

                Panels {
                    id: panels

                    screen: scope.modelData
                    visibilities: visibilities
                    bar: bar
                }

                BarWrapper {
                    id: bar

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    screen: scope.modelData
                    visibilities: visibilities
                    popouts: panels.popouts

                    Component.onCompleted: Visibilities.bars.set(scope.modelData, this)
                }
            }

            Notch.Wrapper {
                id: notchWrapper

                anchors.fill: parent
                anchors.margins: Config.border.thickness
                anchors.leftMargin: bar.implicitWidth

                visibilities: visibilities
                enabled: !visibilities.dashboard
                opacity: visibilities.dashboard ? 0 : 1

                Behavior on opacity {
                    Anim {
                        duration: Appearance.anim.durations.normal
                        easing.bezierCurve: Appearance.anim.curves.emphasized
                    }
                }
            }
        }
    }
}
