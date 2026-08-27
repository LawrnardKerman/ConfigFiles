pragma Singleton
import QtQuick

// Gruvbox dark theme + bar metrics. Referenced as `Theme.<x>` from any
// QML file in this directory (see qmldir).
QtObject {
    // ── Palette ─────────────────────────────────────────────────────────
    readonly property color bg: "#282828"           // pill / popup background
    readonly property color bgHover: "#3c3836"      // hover fill, graph track
    readonly property color border: "#3c3836"       // pill border
    readonly property color borderLight: "#504945"  // popup / inner borders
    readonly property color fg: "#ebdbb2"           // primary text
    readonly property color urgent: "#fbf1c7"

    // Accents (one per module)
    readonly property color aqua: "#8ec07c"         // clock
    readonly property color green: "#b8bb26"        // memory
    readonly property color orange: "#fe8019"       // volume, warnings
    readonly property color purple: "#d3869b"       // mic
    readonly property color yellow: "#fabd2f"       // sun
    readonly property color blue: "#83a598"         // rain
    readonly property color red: "#fb4934"          // thunderstorm

    // ── Metrics ─────────────────────────────────────────────────────────
    readonly property int barHeight: 24
    readonly property int pillPadding: 12           // horizontal padding in pills
    readonly property int pillBorderWidth: 3
    readonly property int popupBorderWidth: 3
    readonly property int popupMargin: 8            // ColumnLayout margins in popups
    readonly property int popupSpacing: 6

    // ── Fonts ───────────────────────────────────────────────────────────
    readonly property string fontFamily: "iosevka, monospace"
    readonly property int fontSize: 11
    readonly property string iconFontFamily: "JetBrainsMono Nerd Font"
    readonly property int iconFontSize: 12
}
