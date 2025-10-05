import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import QtQuick

QtObject {
    readonly property list<string> panes: ["network", "bluetooth", "audio"]

    required property var root
    property bool floating: false
    property string active: panes[0]
    property int activeIndex: 0
    property bool navExpanded: false

    readonly property Network network: Network {}
    readonly property Bt bt: Bt {}
    readonly property Audio audio: Audio {}

    onActiveChanged: activeIndex = panes.indexOf(active)
    onActiveIndexChanged: active = panes[activeIndex]

    component Network: QtObject {
        property var active
        property var connectingNetwork
        property bool showPasswordDialog: false
    }

    component Bt: QtObject {
        property BluetoothDevice active
        property BluetoothAdapter currentAdapter: Bluetooth.defaultAdapter
        property bool editingAdapterName
        property bool fabMenuOpen
        property bool editingDeviceName
    }

    component Audio: QtObject {
        property PwNode active
    }
}
