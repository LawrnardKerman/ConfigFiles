import QtQuick
import Quickshell.Io

// Shared weather source — instantiate once in shell.qml (like SystemStats/NetworkStatus),
// pass to popups as weatherStatus.
//
// Uses ~/.cache/quickshell/location.json if present, otherwise falls back
// to IP geolocation (ipinfo.io). Forecast JSON is cached at
// ~/.cache/quickshell/weather.json: served from cache when <30 min old,
// stale copy used when a fetch fails. Requires: jq, curl.
Item {
    id: root

    property real currentTemp: 0
    property int currentCode: 0
    property bool isDay: true
    property bool loaded: false
    property var weekly: []   // [{ dayLabel, code, hi, lo }]
    property var hourly: []   // [{ hourLabel, temp, code }] — next 8 hours

    // Icons use JetBrains Mono Nerd Font's embedded weather set (e3xx) —
    // there is no real "Font Awesome 6 Free" on this system and several FA
    // codepoints (cloud-sun/fog/rain/showers) don't exist in its fallback,
    // which rendered as missing glyphs.
    function weatherIcon(code) {
        var night = !root.isDay && root.loaded
        if (code === 0 || code === 1) return night ? "\uf186" : "\ue30d"  // moon / day sunny
        if (code === 2) return night ? "\ue37e" : "\ue302"       // night/day cloudy
        if (code === 3) return "\ue312"                          // overcast
        if (code === 45 || code === 48) return "\ue313"          // fog
        if (code >= 51 && code <= 57) return "\ue31b"            // drizzle/sprinkle
        if (code >= 61 && code <= 65) return "\ue318"            // rain
        if (code === 66 || code === 67) return "\ue316"          // freezing rain
        if ((code >= 71 && code <= 77) || code === 85 || code === 86) return "\ue31a"  // snow
        if (code >= 80 && code <= 82) return "\ue319"            // showers
        if (code >= 95) return "\ue31d"                          // thunderstorm
        return "\ue312"
    }

    function weatherColor(code) {
        if (code === 0) return Theme.yellow
        if (code >= 51 && code <= 82) return Theme.blue
        if (code >= 71 && code <= 86) return Theme.fg
        if (code >= 95) return Theme.red
        return "#a89984"
    }

    Process {
        id: fetchProc
        command: ["bash", "-c",
            "CACHE=\"$HOME/.cache/quickshell/weather.json\"; " +
            "LOC=\"$HOME/.cache/quickshell/location.json\"; " +
            // resolve coordinates: location cache, else IP geolocation
            "if [ -f \"$LOC\" ]; then " +
            "  LAT=$(jq -r '.lat // .latitude' \"$LOC\"); " +
            "  LON=$(jq -r '.lon // .longitude' \"$LOC\"); " +
            "else " +
            "  LL=$(curl -s --max-time 5 https://ipinfo.io/loc); " +
            "  LAT=${LL%,*}; LON=${LL#*,}; " +
            "fi; " +
            "URL=\"https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m,weather_code,is_day&hourly=temperature_2m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&timezone=auto&forecast_days=7\"; " +
            // fresh (<30 min) cache? serve it and skip the network entirely
            "if [ -f \"$CACHE\" ] && [ $(($(date +%s) - $(stat -c %Y \"$CACHE\"))) -lt 1800 ]; then " +
            "  cat \"$CACHE\"; exit 0; " +
            "fi; " +
            "RESP=$(curl -s --max-time 10 \"$URL\"); " +
            "if [ -n \"$RESP\" ] && echo \"$RESP\" | jq -e '.current' >/dev/null 2>&1; then " +
            "  echo \"$RESP\" > \"$CACHE\"; echo \"$RESP\"; " +
            "elif [ -f \"$CACHE\" ]; then " +
            "  cat \"$CACHE\"; " +   // fetch failed — fall back to stale copy
            "fi"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    root.currentTemp = data.current.temperature_2m
                    root.currentCode = data.current.weather_code
                    root.isDay = data.current.is_day === 1

                    var dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    var out = []
                    for (var i = 0; i < data.daily.time.length; i++) {
                        var d = new Date(data.daily.time[i])
                        out.push({
                            dayLabel: dayNames[d.getDay()],
                            code: data.daily.weather_code[i],
                            hi: Math.round(data.daily.temperature_2m_max[i]),
                            lo: Math.round(data.daily.temperature_2m_min[i])
                        })
                    }
                    root.weekly = out

                    // Next 8 hours from the hourly block
                    var hOut = []
                    var times = data.hourly.time
                    var now = Date.now()
                    for (var h = 0; h < times.length && hOut.length < 8; h++) {
                        var t = new Date(times[h])
                        if (t.getTime() < now - 3600000) continue   // keep current hour, skip past
                        hOut.push({
                            hourLabel: Qt.formatDateTime(t, "hap"),   // compact, e.g. "6pm"
                            temp: Math.round(data.hourly.temperature_2m[h]),
                            code: data.hourly.weather_code[h]
                        })
                    }
                    root.hourly = hOut

                    root.loaded = true
                } catch (e) {
                    root.loaded = false
                }
            }
        }
    }

    function refresh() {
        fetchProc.running = false
        fetchProc.running = true
    }

    // Same 30-minute throttle as the lock screen weather fetch
    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
