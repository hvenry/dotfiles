pragma Singleton

import qs.config
import qs.utils
import Caelestia.Models
import Quickshell
import Quickshell.Io
import QtQuick

Searcher {
    id: root

    readonly property string currentNamePath: `${Paths.state}/wallpaper/path.txt`
    readonly property list<string> smartArg: Config.services.smartScheme ? [] : ["--no-smart"]

    property bool showPreview: false
    readonly property string current: showPreview ? previewPath : actualCurrent
    property string previewPath
    property string actualCurrent
    property bool previewColourLock

    function setWallpaper(path: string): void {
        actualCurrent = path;
        // Use hyprpaper to set wallpaper
        // First preload the image
        Quickshell.execDetached(["hyprctl", "hyprpaper", "preload", path]);
        // Then set it on all monitors (,* sets on all)
        Quickshell.execDetached(["hyprctl", "hyprpaper", "wallpaper", `,${path}`]);
        // Write to state file
        Quickshell.execDetached(["sh", "-c", `echo "${path}" > ${currentNamePath}`]);
    }

    function preview(path: string): void {
        previewPath = path;
        showPreview = true;

        // Preview disabled without CLI (no dynamic color extraction)
        // if (Colours.scheme === "dynamic")
        //     getPreviewColoursProc.running = true;
    }

    function stopPreview(): void {
        showPreview = false;
        if (!previewColourLock)
            Colours.showPreview = false;
    }

    list: wallpapers.entries
    key: "relativePath"
    useFuzzy: Config.launcher.useFuzzy.wallpapers
    extraOpts: useFuzzy ? ({}) : ({
            forward: false
        })

    IpcHandler {
        target: "wallpaper"

        function get(): string {
            return root.actualCurrent;
        }

        function set(path: string): void {
            root.setWallpaper(path);
        }

        function list(): string {
            return root.list.map(w => w.path).join("\n");
        }
    }

    FileView {
        path: root.currentNamePath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            root.actualCurrent = text().trim();
            root.previewColourLock = false;
        }
    }

    FileSystemModel {
        id: wallpapers

        recursive: true
        path: Paths.wallsdir
        filter: FileSystemModel.Images
    }

    // Disabled: requires caelestia CLI for color extraction
    // Process {
    //     id: getPreviewColoursProc
    //
    //     command: ["caelestia", "wallpaper", "-p", root.previewPath, ...root.smartArg]
    //     stdout: StdioCollector {
    //         onStreamFinished: {
    //             Colours.load(text, true);
    //             Colours.showPreview = true;
    //         }
    //     }
    // }
}
