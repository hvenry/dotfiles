pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.utils
import qs.config
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    property color colour: Colours.palette.m3secondary
    readonly property alias items: iconColumn

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.full

    clip: true
    implicitWidth: Config.bar.sizes.innerWidth
    implicitHeight: iconColumn.implicitHeight + Appearance.padding.normal * 2

    ColumnLayout {
        id: iconColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Appearance.padding.normal

        spacing: Appearance.spacing.smaller / 2

        // Audio icon
        WrappedLoader {
            name: "audio"
            active: Config.bar.status.showAudio

            sourceComponent: MaterialIcon {
                animate: true
                text: Icons.getVolumeIcon(Audio.volume, Audio.muted)
                color: root.colour
            }
        }

        // Microphone icon
        WrappedLoader {
            name: "audio"
            active: Config.bar.status.showMicrophone

            sourceComponent: MaterialIcon {
                animate: true
                text: Icons.getMicVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
                color: root.colour
            }
        }

        // Network icon
        WrappedLoader {
            name: "network"
            active: Config.bar.status.showNetwork

            sourceComponent: MaterialIcon {
                animate: true
                text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
                color: root.colour
            }
        }

        // Bluetooth section
        WrappedLoader {
            Layout.preferredHeight: implicitHeight

            name: "bluetooth"
            active: Config.bar.status.showBluetooth

            sourceComponent: ColumnLayout {
                spacing: Appearance.spacing.smaller / 2

                // Bluetooth icon
                MaterialIcon {
                    animate: true
                    text: {
                        if (!Bluetooth.defaultAdapter?.enabled)
                            return "bluetooth_disabled";
                        if (Bluetooth.devices.values.some(d => d.connected))
                            return "bluetooth_connected";
                        return "bluetooth";
                    }
                    color: root.colour
                }

                // Connected bluetooth devices
                Repeater {
                    model: ScriptModel {
                        values: Bluetooth.devices.values.filter(d => d.state !== BluetoothDeviceState.Disconnected)
                    }

                    MaterialIcon {
                        id: device

                        required property BluetoothDevice modelData

                        animate: true
                        text: Icons.getBluetoothIcon(modelData?.icon)
                        color: root.colour
                        fill: 1

                        SequentialAnimation on opacity {
                            running: device.modelData?.state !== BluetoothDeviceState.Connected
                            alwaysRunToEnd: true
                            loops: Animation.Infinite

                            Anim {
                                from: 1
                                to: 0
                                duration: Appearance.anim.durations.large
                                easing.bezierCurve: Appearance.anim.curves.standardAccel
                            }
                            Anim {
                                from: 0
                                to: 1
                                duration: Appearance.anim.durations.large
                                easing.bezierCurve: Appearance.anim.curves.standardDecel
                            }
                        }
                    }
                }
            }

            Behavior on Layout.preferredHeight {
                Anim {}
            }
        }

        // Battery icon
        WrappedLoader {
            name: "battery"
            active: Config.bar.status.showBattery

            sourceComponent: MaterialIcon {
                animate: true
                text: {
                    if (!UPower.displayDevice.isLaptopBattery) {
                        if (PowerProfiles.profile === PowerProfile.PowerSaver)
                            return "energy_savings_leaf";
                        if (PowerProfiles.profile === PowerProfile.Performance)
                            return "rocket_launch";
                        return "balance";
                    }

                    const perc = UPower.displayDevice.percentage;
                    const charging = !UPower.onBattery;
                    if (perc === 1)
                        return charging ? "battery_charging_full" : "battery_full";
                    let level = Math.floor(perc * 7);
                    if (charging && (level === 4 || level === 1))
                        level--;
                    return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
                }
                color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? root.colour : Colours.palette.m3error
                fill: 1
            }
        }
    }

    component WrappedLoader: Loader {
        required property string name

        Layout.alignment: Qt.AlignHCenter
        asynchronous: true
        visible: active
    }
}
