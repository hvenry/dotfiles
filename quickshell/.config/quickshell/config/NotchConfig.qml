import Quickshell.Io

JsonObject {
    property bool enabled: true
    property Sizes sizes: Sizes {}

    component Sizes: JsonObject {
        property int width: 200
        property int height: 35
        property int padding: 20
        property int rounding: 15
    }
}
