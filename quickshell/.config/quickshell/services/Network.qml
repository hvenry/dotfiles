pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

/**
 * Network Service - WiFi Network Management
 *
 * This service provides robust WiFi network connection management using NetworkManager (nmcli).
 * It implements a multi-step connection state machine to ensure reliable connections and
 * prevent race conditions when switching networks.
 *
 * CONNECTION FLOW:
 * ================
 * 1. connectToNetwork() called with SSID, password, and optionally BSSID
 * 2. If currently connected to another network:
 *    a. Disconnect from current network (1 second delay after completion)
 * 3. Delete any existing saved connection for the target SSID
 *    - Prevents stale credentials from causing connection failures
 *    - 500ms delay after deletion to ensure NetworkManager processes it
 * 4. Execute fresh connection with provided credentials
 *    - Uses SSID as primary identifier (for security type auto-detection)
 *    - BSSID used as constraint to identify specific access point
 * 5. Monitor network list for active connection to target SSID
 *    - Connection confirmed when target appears as active
 *    - 30-second timeout if connection hangs
 *
 * FEATURES:
 * =========
 * - Automatic disconnection before connecting to new networks
 * - Stale credential cleanup to prevent authentication issues
 * - Connection state tracking (isConnecting, isDisconnecting, connectingToSsid)
 * - Error reporting via lastError property
 * - Timeout protection for hung connections
 * - Prevents concurrent connection attempts
 * - Comprehensive logging for debugging
 *
 * USAGE:
 * ======
 * Network.connectToNetwork("MyNetwork", "password123", "AA:BB:CC:DD:EE:FF")
 * Network.disconnectFromNetwork()
 * Network.rescanWifi()
 */
Singleton {
    id: root

    // ========================================================================
    // PROPERTIES
    // ========================================================================

    /** List of all discovered WiFi access points */
    readonly property list<AccessPoint> networks: []

    /** Currently connected access point (null if not connected) */
    readonly property AccessPoint active: networks.find(n => n.active) ?? null

    /** Whether WiFi radio is enabled */
    property bool wifiEnabled: true

    /** Whether a WiFi scan is currently in progress */
    readonly property bool scanning: rescanProc.running

    // Connection State Tracking
    /** SSID of the network we're currently trying to connect to */
    property string connectingToSsid: ""

    /** Whether a connection attempt is in progress */
    property bool isConnecting: connectingToSsid.length > 0

    /** Whether a disconnection is in progress */
    property bool isDisconnecting: false

    /** Last error message from connection/disconnection attempts */
    property string lastError: ""

    // ========================================================================
    // PUBLIC API FUNCTIONS
    // ========================================================================

    /**
     * Enable or disable the WiFi radio
     * @param enabled - true to enable WiFi, false to disable
     */
    function enableWifi(enabled: bool): void {
        const cmd = enabled ? "on" : "off";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    /**
     * Toggle WiFi radio on/off
     */
    function toggleWifi(): void {
        const cmd = wifiEnabled ? "off" : "on";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    /**
     * Trigger a WiFi network scan
     * Sets scanning property to true until scan completes
     */
    function rescanWifi(): void {
        rescanProc.running = true;
    }

    /**
     * Connect to a WiFi network
     *
     * This is the main entry point for connecting to networks. It implements
     * a multi-step state machine to ensure reliable connections.
     *
     * @param ssid - Network name (required)
     * @param password - Network password (empty string for open networks)
     * @param bssid - MAC address of specific access point (optional, helps with hotspots)
     *
     * FLOW:
     * 1. Check if already connecting/disconnecting (reject if true)
     * 2. If connected to another network, disconnect first
     * 3. Delete old saved connection to prevent stale credentials
     * 4. Perform fresh connection with new credentials
     * 5. Monitor for successful connection or timeout
     */
    function connectToNetwork(ssid: string, password: string, bssid = ""): void {
        // Prevent concurrent operations
        if (isConnecting || isDisconnecting) {
            console.warn("Network: Already performing network operation, please wait");
            return;
        }

        root.lastError = "";
        root.connectingToSsid = ssid;

        // Step 1: Disconnect from current network if connected
        // This prevents NetworkManager race conditions when switching networks
        if (active) {
            console.log("Network: Disconnecting from", active.ssid, "before connecting to", ssid);
            isDisconnecting = true;
            disconnectProc.exec(["nmcli", "connection", "down", "id", active.ssid]);

            // Store connection info to resume after disconnect completes
            disconnectProc.pendingSsid = ssid;
            disconnectProc.pendingPassword = password;
            disconnectProc.pendingBssid = bssid;
        } else {
            // No active connection, proceed directly to connection attempt
            attemptConnection(ssid, password, bssid);
        }
    }

    /**
     * Disconnect from the currently active network
     * Sets isDisconnecting state until operation completes
     */
    function disconnectFromNetwork(): void {
        if (!active) {
            console.warn("Network: No active connection to disconnect from");
            return;
        }

        if (isDisconnecting) {
            console.warn("Network: Already disconnecting");
            return;
        }

        console.log("Network: Disconnecting from", active.ssid);
        root.lastError = "";
        isDisconnecting = true;
        disconnectProc.exec(["nmcli", "connection", "down", "id", active.ssid]);
    }

    // ========================================================================
    // INTERNAL STATE MACHINE FUNCTIONS
    // ========================================================================

    /**
     * Step 2 of connection flow: Delete old saved connection
     *
     * Deletes any existing saved connection for the target SSID.
     * This prevents stale credentials from causing authentication failures.
     * Called after successful disconnection or directly if no network is active.
     *
     * @param ssid - Network name
     * @param password - Network password
     * @param bssid - Access point MAC address
     */
    function attemptConnection(ssid: string, password: string, bssid: string): void {
        console.log("Network: Attempting connection to", ssid);

        // Delete any existing saved connection to avoid stale credentials
        deleteConnectionProc.exec(["nmcli", "connection", "delete", "id", ssid]);

        // Store connection info to resume after deletion completes
        deleteConnectionProc.pendingSsid = ssid;
        deleteConnectionProc.pendingPassword = password;
        deleteConnectionProc.pendingBssid = bssid;
    }

    /**
     * Step 3 of connection flow: Execute the actual connection
     *
     * Performs the nmcli connection command with fresh credentials.
     * Called after old connection deletion completes.
     *
     * @param ssid - Network name (used for security type auto-detection)
     * @param password - Network password (omitted for open networks)
     * @param bssid - Access point MAC address (optional constraint)
     */
    function performConnection(ssid: string, password: string, bssid: string): void {
        const cmd = ["nmcli", "dev", "wifi", "connect", ssid];

        // Add password if provided (omit for open networks)
        if (password && password.length > 0) {
            cmd.push("password", password);
        }

        // Add BSSID constraint if provided (useful for hotspots with same SSID)
        if (bssid && bssid.length > 0) {
            cmd.push("bssid", bssid);
        }

        console.log("Network: Executing connection:", cmd.join(" "));
        connectProc.exec(cmd);

        // Start timeout timer to prevent hanging on failed connections
        connectionTimeout.restart();
    }

    /**
     * Reset all connection state variables
     *
     * Clears all pending operations and state flags.
     * Called after successful connection, timeout, or error.
     */
    function resetConnectionState(): void {
        root.connectingToSsid = "";
        root.isDisconnecting = false;
        disconnectProc.pendingSsid = "";
        disconnectProc.pendingPassword = "";
        disconnectProc.pendingBssid = "";
        deleteConnectionProc.pendingSsid = "";
        deleteConnectionProc.pendingPassword = "";
        deleteConnectionProc.pendingBssid = "";
        connectionTimeout.stop();
    }

    /**
     * Refresh WiFi enabled/disabled status
     * Triggers wifiStatusProc to check current radio state
     */
    function getWifiStatus(): void {
        wifiStatusProc.running = true;
    }

    // ========================================================================
    // TIMERS
    // ========================================================================

    /**
     * Connection Timeout Timer
     *
     * Prevents the connection state from hanging indefinitely if nmcli fails
     * or the network is unreachable. Triggers after 30 seconds of attempting
     * to connect, automatically resetting state and refreshing network list.
     */
    Timer {
        id: connectionTimeout
        interval: 30000 // 30 second timeout
        repeat: false

        onTriggered: {
            if (root.isConnecting) {
                console.warn("Network: Connection timeout for", root.connectingToSsid);
                root.lastError = "Connection timeout";
                resetConnectionState();
                getNetworks.running = true;
            }
        }
    }

    // ========================================================================
    // NETWORKMANAGER MONITORING PROCESSES
    // ========================================================================

    /**
     * NetworkManager Monitor Process
     *
     * Watches NetworkManager for state changes and triggers network list refresh.
     * Runs continuously in the background.
     */
    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }

    /**
     * WiFi Status Check Process
     *
     * Queries current WiFi radio state (enabled/disabled).
     * Updates wifiEnabled property when result is received.
     */
    Process {
        id: wifiStatusProc

        running: true
        command: ["nmcli", "radio", "wifi"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled";
            }
        }
    }

    /**
     * WiFi Enable/Disable Process
     *
     * Executes nmcli commands to turn WiFi radio on or off.
     * Refreshes WiFi status and network list after completion.
     */
    Process {
        id: enableWifiProc

        onExited: {
            root.getWifiStatus();
            getNetworks.running = true;
        }
    }

    /**
     * WiFi Scan Process
     *
     * Triggers an active WiFi scan for nearby networks.
     * Refreshes network list when scan completes.
     */
    Process {
        id: rescanProc

        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: {
            getNetworks.running = true;
        }
    }

    // ========================================================================
    // CONNECTION STATE MACHINE PROCESSES
    // ========================================================================

    /**
     * Delete Connection Process
     *
     * ROLE: Step 2 of connection flow
     * Deletes existing saved connection for the target SSID to prevent
     * stale credential issues. Stores pending connection details and
     * triggers a 500ms delay before proceeding to actual connection.
     *
     * PROPERTIES:
     * - pendingSsid/pendingPassword/pendingBssid: Connection info to resume after deletion
     *
     * NEXT STEP: deleteDelayTimer → performConnection()
     */
    Process {
        id: deleteConnectionProc

        property string pendingSsid: ""
        property string pendingPassword: ""
        property string pendingBssid: ""

        onExited: {
            // Deletion complete (or failed if connection didn't exist)
            // Either way, proceed with fresh connection
            if (pendingSsid.length > 0) {
                const ssid = pendingSsid;
                const password = pendingPassword;
                const bssid = pendingBssid;

                // Clear pending state before triggering timer
                pendingSsid = "";
                pendingPassword = "";
                pendingBssid = "";

                // 500ms delay to ensure NetworkManager fully processes the deletion
                deleteDelayTimer.ssid = ssid;
                deleteDelayTimer.password = password;
                deleteDelayTimer.bssid = bssid;
                deleteDelayTimer.restart();
            }
        }
    }

    /**
     * Delete Delay Timer
     *
     * Provides a 500ms delay after connection deletion to ensure
     * NetworkManager has fully processed the deletion before attempting
     * to create a new connection with the same SSID.
     */
    Timer {
        id: deleteDelayTimer
        interval: 500
        repeat: false

        property string ssid: ""
        property string password: ""
        property string bssid: ""

        onTriggered: {
            if (ssid.length > 0) {
                root.performConnection(ssid, password, bssid);
                ssid = "";
                password = "";
                bssid = "";
            }
        }
    }

    /**
     * Connection Execute Process
     *
     * ROLE: Step 3 of connection flow
     * Executes the actual nmcli connection command with credentials.
     * Stops the connection timeout timer when process completes.
     * Refreshes network list to check connection status.
     *
     * EXIT HANDLING:
     * - Exit code 0: Connection command completed (doesn't guarantee connection success)
     * - Non-zero: Connection failed (error captured in stderr)
     *
     * NEXT STEP: Network list refresh will detect active connection and call resetConnectionState()
     */
    Process {
        id: connectProc

        onExited: {
            connectionTimeout.stop();

            if (exitCode === 0) {
                console.log("Network: Successfully connected to", root.connectingToSsid);
                root.lastError = "";
            } else {
                console.warn("Network: Connection failed with exit code", exitCode);
            }

            // Always refresh network list to detect actual connection state
            getNetworks.running = true;
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.log("Network: Connection output:", text.trim());
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    root.lastError = text.trim();
                    console.warn("Network: Connection error:", text);
                }
            }
        }
    }

    /**
     * Disconnection Process
     *
     * ROLE: Step 1 of connection flow (when switching networks) or standalone disconnect
     * Disconnects from currently active network connection.
     *
     * TWO MODES:
     * 1. With pending connection (switching networks):
     *    - Stores pendingSsid/password/bssid
     *    - Triggers 1 second delay then proceeds to attemptConnection()
     * 2. Manual disconnect (no pending connection):
     *    - Resets all state
     *    - Refreshes network list
     *
     * PROPERTIES:
     * - pendingSsid/pendingPassword/pendingBssid: Next network to connect to (if switching)
     *
     * NEXT STEP:
     * - If switching: disconnectDelayTimer → attemptConnection()
     * - If manual: resetConnectionState()
     */
    Process {
        id: disconnectProc

        property string pendingSsid: ""
        property string pendingPassword: ""
        property string pendingBssid: ""

        onExited: {
            console.log("Network: Disconnect completed");
            root.isDisconnecting = false;

            // Check if we're switching to another network
            if (pendingSsid.length > 0) {
                const ssid = pendingSsid;
                const password = pendingPassword;
                const bssid = pendingBssid;

                pendingSsid = "";
                pendingPassword = "";
                pendingBssid = "";

                // 1 second delay to ensure network is fully disconnected
                disconnectDelayTimer.ssid = ssid;
                disconnectDelayTimer.password = password;
                disconnectDelayTimer.bssid = bssid;
                disconnectDelayTimer.restart();
            } else {
                // Manual disconnect - no pending connection
                root.resetConnectionState();
                getNetworks.running = true;
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.log("Network: Disconnect output:", text.trim());
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.log("Network: Disconnect stderr:", text.trim());
                }
            }
        }
    }

    /**
     * Disconnect Delay Timer
     *
     * Provides a 1 second delay after disconnection to ensure the network
     * interface is fully down before attempting to connect to a new network.
     * This prevents NetworkManager race conditions when switching networks.
     */
    Timer {
        id: disconnectDelayTimer
        interval: 1000
        repeat: false

        property string ssid: ""
        property string password: ""
        property string bssid: ""

        onTriggered: {
            if (ssid.length > 0) {
                root.attemptConnection(ssid, password, bssid);
                ssid = "";
                password = "";
                bssid = "";
            }
        }
    }

    // ========================================================================
    // NETWORK DISCOVERY AND MONITORING
    // ========================================================================

    /**
     * Network List Scanner Process
     *
     * Continuously queries NetworkManager for available WiFi networks.
     * Runs whenever triggered by NetworkManager state changes or manual refresh.
     *
     * OUTPUT FORMAT (from nmcli):
     * - ACTIVE: "yes" if connected, "" otherwise
     * - SIGNAL: Signal strength 0-100
     * - FREQ: Frequency in MHz (2.4GHz or 5GHz)
     * - SSID: Network name (may contain colons, hence the escape handling)
     * - BSSID: Access point MAC address
     * - SECURITY: Security type (WPA2, WPA3, etc.)
     *
     * PROCESSING:
     * 1. Parse colon-separated nmcli output (handling escaped colons in SSIDs)
     * 2. Group networks by SSID, keeping strongest signal or active connection
     * 3. Update networks list, creating/destroying AccessPoint objects as needed
     * 4. Check for successful connection to target network (if connecting)
     */
    Process {
        id: getNetworks

        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                // Colon escape handling: Replace escaped colons with placeholder
                // since nmcli uses ":" as delimiter but SSIDs can contain ":"
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                // Parse each line into network object
                const allNetworks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]),
                        frequency: parseInt(net[2]),
                        ssid: net[3]?.replace(rep2, ":") ?? "",
                        bssid: net[4]?.replace(rep2, ":") ?? "",
                        security: net[5] ?? ""
                    };
                }).filter(n => n.ssid && n.ssid.length > 0);

                // Deduplicate networks by SSID
                // Prioritize: active connection > strongest signal
                const networkMap = new Map();
                for (const network of allNetworks) {
                    const existing = networkMap.get(network.ssid);
                    if (!existing) {
                        networkMap.set(network.ssid, network);
                    } else {
                        // Prioritize active/connected networks
                        if (network.active && !existing.active) {
                            networkMap.set(network.ssid, network);
                        } else if (!network.active && !existing.active) {
                            // If both are inactive, keep the one with better signal
                            if (network.strength > existing.strength) {
                                networkMap.set(network.ssid, network);
                            }
                        }
                        // If existing is active and new is not, keep existing
                    }
                }

                const networks = Array.from(networkMap.values());
                const rNetworks = root.networks;

                // Remove AccessPoints that no longer exist
                const destroyed = rNetworks.filter(rn => !networks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                // Update existing or create new AccessPoints
                for (const network of networks) {
                    const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                    if (match) {
                        // Update existing AccessPoint
                        match.lastIpcObject = network;
                    } else {
                        // Create new AccessPoint
                        rNetworks.push(apComp.createObject(root, {
                            lastIpcObject: network
                        }));
                    }
                }

                // Connection state validation: Check if we successfully connected
                if (root.isConnecting && root.connectingToSsid.length > 0) {
                    const connected = networks.find(n => n.active && n.ssid === root.connectingToSsid);
                    if (connected) {
                        console.log("Network: Connection confirmed for", root.connectingToSsid);
                        root.resetConnectionState();
                    }
                }
            }
        }
    }

    // ========================================================================
    // ACCESS POINT DATA MODEL
    // ========================================================================

    /**
     * AccessPoint Component
     *
     * Represents a single WiFi access point with all its properties.
     * Created and managed by the network scanner process.
     *
     * PROPERTIES:
     * - ssid: Network name (e.g., "MyHomeNetwork")
     * - bssid: Access point MAC address (e.g., "AA:BB:CC:DD:EE:FF")
     * - strength: Signal strength 0-100
     * - frequency: WiFi frequency in MHz (2412-2484 for 2.4GHz, 5000+ for 5GHz)
     * - active: Whether this network is currently connected
     * - security: Security protocol (e.g., "WPA2", "WPA3", "" for open)
     * - isSecure: Computed property - true if network requires password
     *
     * LIFECYCLE:
     * - Created when network first appears in scan
     * - Updated when network properties change (signal strength, active state)
     * - Destroyed when network disappears from scan results
     */
    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string security: lastIpcObject.security
        readonly property bool isSecure: security.length > 0
    }

    /**
     * AccessPoint Factory Component
     * Used by network scanner to instantiate new AccessPoint objects
     */
    Component {
        id: apComp

        AccessPoint {}
    }
}
