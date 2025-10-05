/**
 * Service-level configuration object
 *
 * ServiceConfig defines settings for system services including audio increment,
 * brightness step, weather location, and media player aliases.
 *
 * Used by: services/Audio, services/Brightness, services/Weather, services/Players
 * Reads from: shell.json → services section
 * Provides: Config.services
 */
import Quickshell.Io
import QtQuick

JsonObject {
    property string weatherLocation: "" // A lat,long pair or empty for autodetection, e.g. "37.8267,-122.4233"
    property bool useFahrenheit: [Locale.ImperialUSSystem, Locale.ImperialSystem].includes(Qt.locale().measurementSystem)
    property bool useTwelveHourClock: Qt.locale().timeFormat(Locale.ShortFormat).toLowerCase().includes("a")
    property string gpuType: ""
    property int visualiserBars: 45
    property real audioIncrement: 0.1
    property bool smartScheme: true
    property string defaultPlayer: "Spotify"
    property list<var> playerAliases: [
        {
            "from": "com.github.th_ch.youtube_music",
            "to": "YT Music"
        }
    ]
}
