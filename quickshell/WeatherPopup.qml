import QtQuick
import QtQuick.Layouts
import Quickshell

// Weather popup — current conditions, hourly strip, weekly list.
// Same anchoring contract as CalendarPopup/NotificationsPopup.
Item {
    id: wxPopup

    property bool open: false
    property var anchorWindow: null
    property var anchorPill: null
    property int anchorY: 0
    property int screenWidth: 1920
    property real anchorX: 0
    readonly property int popupHeight: 220   // consumed by shell.qml stacking

    required property QtObject weatherStatus

    function updateAnchorX() {
        if (!anchorPill || !anchorWindow) {
            anchorX = 0
            return
        }
        var pos = anchorPill.mapToItem(null, 0, 0)
        var rightAligned = pos.x + anchorPill.width - popWin.implicitWidth
        anchorX = Math.max(0, Math.min(screenWidth - popWin.implicitWidth - 4, rightAligned))
    }

    onOpenChanged: {
        if (open) {
            updateAnchorX()
            weatherStatus.refresh()
        }
    }

    PopupWindow {
        id: popWin
        visible: wxPopup.open
        implicitWidth:  300
        implicitHeight: wxPopup.popupHeight
        anchor.window: wxPopup.anchorWindow
        anchor.rect.y: wxPopup.anchorY
        anchor.rect.x: wxPopup.anchorX

        Rectangle {
            anchors.fill: parent
            color: "#282828"
            border.color: "#3c3836"
            border.width: 3

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // ── Current conditions ────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 14

                    Text {
                        text: wxPopup.weatherStatus.weatherIcon(wxPopup.weatherStatus.currentCode)
                        color: wxPopup.weatherStatus.weatherColor(wxPopup.weatherStatus.currentCode)
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 44
                    }
                    Text {
                        text: Math.round(wxPopup.weatherStatus.currentTemp) + "°F"
                        color: "#ebdbb2"
                        font.family: "iosevka, monospace"
                        font.pixelSize: 28
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                }

                // ── Hourly — next 8 hours ──────────────────────────────
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 10

                    Repeater {
                        model: wxPopup.weatherStatus.hourly
                        delegate: Column {
                            required property int index
                            readonly property var hr: wxPopup.weatherStatus.hourly[index]
                            spacing: 4

                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: hr.hourLabel; color: "#928374"; font.family: "iosevka, monospace"; font.pixelSize: 11 }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: wxPopup.weatherStatus.weatherIcon(hr.code); color: wxPopup.weatherStatus.weatherColor(hr.code); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 17 }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: hr.temp + "°"; color: "#ebdbb2"; font.family: "iosevka, monospace"; font.pixelSize: 12; font.bold: true }
                        }
                    }
                }

                // ── Weekly — day above, icon with hi/lo stacked beside ──
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Repeater {
                        model: wxPopup.weatherStatus.weekly
                        delegate: ColumnLayout {
                            required property int index
                            readonly property var wd: wxPopup.weatherStatus.weekly[index]
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: wd.dayLabel
                                color: "#a89984"
                                font.family: "iosevka, monospace"
                                font.pixelSize: 11
                            }
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 3
                                Text {
                                    text: wxPopup.weatherStatus.weatherIcon(wd.code)
                                    color: wxPopup.weatherStatus.weatherColor(wd.code)
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 18
                                }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: wd.hi; color: "#ebdbb2"; font.family: "iosevka, monospace"; font.pixelSize: 11; font.bold: true }
                                    Text { text: wd.lo; color: "#928374"; font.family: "iosevka, monospace"; font.pixelSize: 10 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
