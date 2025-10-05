/**
 * Media player control service singleton (MPRIS2)
 *
 * Players provides control for media players via MPRIS2 protocol.
 *
 * Used by: modules/dashboard/dash/Media.qml, modules/bar/
 * Reads from: MPRIS2 via Quickshell plugin, Config.services (player aliases)
 * Provides: active player, play/pause/next/previous controls
 */
pragma Singleton

import qs.components.misc
import qs.config
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property list<MprisPlayer> list: Mpris.players.values
    readonly property MprisPlayer active: props.manualActive ?? list.find(p => getIdentity(p) === Config.services.defaultPlayer) ?? list[0] ?? null
    property alias manualActive: props.manualActive

    function getIdentity(player: MprisPlayer): string {
        const alias = Config.services.playerAliases.find(a => a.from === player.identity);
        return alias?.to ?? player.identity;
    }

    PersistentProperties {
        id: props

        property MprisPlayer manualActive

        reloadableId: "players"
    }
}
