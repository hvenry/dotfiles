/**
 * Image utilities singleton
 *
 * Images provides image validation and type checking utilities.
 *
 * Key features:
 * - Valid image type/extension lists (jpeg, png, webp, tiff, svg)
 * - Image file validation by name/extension
 *
 * Used by: Components loading images
 * Reads from: None (pure utilities)
 * Provides: Image validation functions
 */
pragma Singleton

import Quickshell

Singleton {
    readonly property list<string> validImageTypes: ["jpeg", "png", "webp", "tiff", "svg"]
    readonly property list<string> validImageExtensions: ["jpg", "jpeg", "png", "webp", "tif", "tiff", "svg"]

    function isValidImageByName(name: string): bool {
        return validImageExtensions.some(t => name.endsWith(`.${t}`));
    }
}
