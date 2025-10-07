/**
 * Path management utilities singleton
 *
 * Paths provides centralized path management following XDG Base Directory specification.
 *
 * Key features:
 * - XDG directory paths: config, state, cache, data
 * - User directories: home, pictures, videos
 * - Quickshell-specific paths: imagecache, recsdir, libdir
 * - Path utility functions: absolutePath(), toLocalFile(), shortenHome()
 * - Environment variable support with fallbacks
 *
 * Used by: All modules and services requiring file paths
 * Reads from: Environment variables (XDG_*, HOME, etc.)
 * Provides: Directory paths and path conversion functions
 */
pragma Singleton

import qs.config
import Utils
import Quickshell

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string pictures: Quickshell.env("XDG_PICTURES_DIR") || `${home}/Pictures`
    readonly property string videos: Quickshell.env("XDG_VIDEOS_DIR") || `${home}/Videos`

    readonly property string data: `${Quickshell.env("XDG_DATA_HOME") || `${home}/.local/share`}/quickshell`
    readonly property string state: `${Quickshell.env("XDG_STATE_HOME") || `${home}/.local/state`}/quickshell`
    readonly property string cache: `${Quickshell.env("XDG_CACHE_HOME") || `${home}/.cache`}/quickshell`
    readonly property string config: `${Quickshell.env("XDG_CONFIG_HOME") || `${home}/.config`}/quickshell`

    readonly property string imagecache: `${cache}/imagecache`
    readonly property string notifimagecache: `${imagecache}/notifs`
    readonly property string recsdir: Quickshell.env("QUICKSHELL_RECORDINGS_DIR") || `${videos}/Recordings`
    readonly property string libdir: Quickshell.env("QUICKSHELL_LIB_DIR") || "/usr/lib/quickshell"

    function toLocalFile(path: url): string {
        path = Qt.resolvedUrl(path);
        return path.toString() ? CUtils.toLocalFile(path) : "";
    }

    function absolutePath(path: string): string {
        return toLocalFile(path.replace("~", home));
    }

    function shortenHome(path: string): string {
        return path.replace(home, "~");
    }
}
