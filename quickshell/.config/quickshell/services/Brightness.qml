pragma Singleton
pragma ComponentBehavior: Bound

import qs.components.misc
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property list<var> ddcMonitors: []
    readonly property list<Monitor> monitors: variants.instances
    property bool appleDisplayPresent: false

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.modelData === screen);
    }

    function getMonitor(query: string): var {
        if (query === "active") {
            return monitors.find(m => Hypr.monitorFor(m.modelData)?.focused);
        }

        if (query.startsWith("model:")) {
            const model = query.slice(6);
            return monitors.find(m => m.modelData.model === model);
        }

        if (query.startsWith("serial:")) {
            const serial = query.slice(7);
            return monitors.find(m => m.modelData.serialNumber === serial);
        }

        if (query.startsWith("id:")) {
            const id = parseInt(query.slice(3), 10);
            return monitors.find(m => Hypr.monitorFor(m.modelData)?.id === id);
        }

        return monitors.find(m => m.modelData.name === query);
    }

    function increaseBrightness(): void {
        const monitor = getMonitor("active");
        if (monitor)
            monitor.setBrightness(monitor.brightness + 0.1);
    }

    function decreaseBrightness(): void {
        const monitor = getMonitor("active");
        if (monitor)
            monitor.setBrightness(monitor.brightness - 0.1);
    }

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    Variants {
        id: variants

        model: Quickshell.screens

        Monitor {}
    }

    Process {
        running: true
        command: ["sh", "-c", "asdbctl get"] // To avoid warnings if asdbctl is not installed
        stdout: StdioCollector {
            onStreamFinished: root.appleDisplayPresent = text.trim().length > 0
        }
    }

    Process {
        id: ddcProc

        command: ["ddcutil", "--sleep-multiplier", "0.5", "detect", "--brief"]
        stdout: StdioCollector {
            onStreamFinished: root.ddcMonitors = text.trim().split("\n\n").filter(d => d.startsWith("Display ")).map(d => {
                const busMatch = d.match(/I2C bus:[ ]*\/dev\/i2c-([0-9]+)/);
                // Handle both "DRM connector:" and "DRM_connector:", and missing connector
                const connectorMatch = d.match(/DRM[_ ]connector:\s+(.*)/);
                return {
                    busNum: busMatch ? busMatch[1] : null,
                    connector: connectorMatch ? connectorMatch[1].replace(/^card\d+-/, "") : "unknown"
                };
            }).filter(d => d.busNum !== null)
        }
    }

    CustomShortcut {
        name: "brightnessUp"
        description: "Increase brightness"
        onPressed: root.increaseBrightness()
    }

    CustomShortcut {
        name: "brightnessDown"
        description: "Decrease brightness"
        onPressed: root.decreaseBrightness()
    }

    IpcHandler {
        target: "brightness"

        function get(): real {
            return getFor("active");
        }

        // Allows searching by active/model/serial/id/name
        function getFor(query: string): real {
            return root.getMonitor(query)?.brightness ?? -1;
        }

        function set(value: string): string {
            return setFor("active", value);
        }

        // Handles brightness value like brightnessctl: 0.1, +0.1, 0.1-, 10%, +10%, 10%-
        function setFor(query: string, value: string): string {
            const monitor = root.getMonitor(query);
            if (!monitor)
                return "Invalid monitor: " + query;

            let targetBrightness;
            if (value.endsWith("%-")) {
                const percent = parseFloat(value.slice(0, -2));
                targetBrightness = monitor.brightness - (percent / 100);
            } else if (value.startsWith("+") && value.endsWith("%")) {
                const percent = parseFloat(value.slice(1, -1));
                targetBrightness = monitor.brightness + (percent / 100);
            } else if (value.endsWith("%")) {
                const percent = parseFloat(value.slice(0, -1));
                targetBrightness = percent / 100;
            } else if (value.startsWith("+")) {
                const increment = parseFloat(value.slice(1));
                targetBrightness = monitor.brightness + increment;
            } else if (value.endsWith("-")) {
                const decrement = parseFloat(value.slice(0, -1));
                targetBrightness = monitor.brightness - decrement;
            } else if (value.includes("%") || value.includes("-") || value.includes("+")) {
                return `Invalid brightness format: ${value}\nExpected: 0.1, +0.1, 0.1-, 10%, +10%, 10%-`;
            } else {
                targetBrightness = parseFloat(value);
            }

            if (isNaN(targetBrightness))
                return `Failed to parse value: ${value}\nExpected: 0.1, +0.1, 0.1-, 10%, +10%, 10%-`;

            monitor.setBrightness(targetBrightness);

            return `Set monitor ${monitor.modelData.name} brightness to ${+monitor.brightness.toFixed(2)}`;
        }
    }

    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData
        readonly property bool isDdc: root.ddcMonitors.some(m => m.connector === modelData.name)
        readonly property string busNum: root.ddcMonitors.find(m => m.connector === modelData.name)?.busNum ?? ""
        readonly property bool isAppleDisplay: root.appleDisplayPresent && modelData.model.startsWith("StudioDisplay")
        property real brightness
        property real queuedBrightness: NaN
    // Track the last value actually applied to hardware to avoid
    // suppressing a needed hardware write when UI updated early
    property real appliedBrightness: NaN
    // Track the last value we attempted to write via the worker process
    property real lastWritten: NaN

        readonly property Process initProc: Process {
            stdout: StdioCollector {
                onStreamFinished: {
                    if (monitor.isAppleDisplay) {
                        const val = parseInt(text.trim());
                        monitor.brightness = val / 101;
                    } else {
                        const [, , , cur, max] = text.split(" ");
                        monitor.brightness = parseInt(cur) / parseInt(max);
                    }
                    monitor.appliedBrightness = monitor.brightness;
                }
            }
        }

        // Dedicated worker process to serialize writes and avoid command spam.
        // We only update appliedBrightness after the process finishes, keeping
        // UI and hardware state in sync and avoiding "bounce".
        readonly property Process writeProc: Process {
            stdout: StdioCollector {}
            stderr: StdioCollector {}
            onRunningChanged: {
                if (running)
                    return;
                // Process finished: assume write completed; sync applied state
                if (!isNaN(monitor.lastWritten))
                    monitor.appliedBrightness = monitor.lastWritten;

                const q = monitor.queuedBrightness;
                monitor.queuedBrightness = NaN;
                if (!isNaN(q)) {
                    // Drop if equivalent to what's already applied
                    if (isNaN(monitor.appliedBrightness) || Math.round(monitor.appliedBrightness * 100) !== Math.round(q * 100))
                        monitor.performHardwareWrite(q);
                } else {
                    // No pending writes; read back actual hardware level to
                    // ensure the slider reflects device state precisely.
                    monitor.initBrightness();
                }
            }
        }

        function performHardwareWrite(value: real): void {
            const rounded = Math.round(value * 100);
            lastWritten = value;
            if (isAppleDisplay) {
                writeProc.command = ["asdbctl", "set", rounded];
            } else if (isDdc) {
                // Speed up ddcutil a bit, at the risk of occasional flakiness on some monitors
                writeProc.command = ["ddcutil", "--noverify", "--sleep-multiplier", "0.2", "-b", busNum, "setvcp", "10", rounded];
            } else {
                writeProc.command = ["brightnessctl", "s", `${rounded}%`];
            }
            writeProc.running = true;
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            const rounded = Math.round(value * 100);
            // Always update UI immediately
            brightness = value;

            if (!isDdc) {
                if (!isNaN(appliedBrightness) && Math.round(appliedBrightness * 100) === rounded)
                    return;
                // Serialize even for non-DDC to keep state synchronized
                if (writeProc.running)
                    queuedBrightness = value;
                else
                    performHardwareWrite(value);
                return;
            }

            // DDC path: queue if a write is in progress; otherwise write now
            if (writeProc.running) {
                queuedBrightness = value;
            } else {
                if (!isNaN(appliedBrightness) && Math.round(appliedBrightness * 100) === rounded)
                    return;
                performHardwareWrite(value);
            }
        }

        function initBrightness(): void {
            if (isAppleDisplay)
                initProc.command = ["asdbctl", "get"];
            else if (isDdc)
                initProc.command = ["ddcutil", "--sleep-multiplier", "0.5", "-b", busNum, "getvcp", "10", "--brief"];
            else
                initProc.command = ["sh", "-c", "echo a b c $(brightnessctl g) $(brightnessctl m)"];

            initProc.running = true;
        }

        onBusNumChanged: initBrightness()
        Component.onCompleted: initBrightness()
    }
}
