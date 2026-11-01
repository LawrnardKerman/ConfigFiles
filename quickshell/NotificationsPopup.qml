import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Notifications popup — mako list with per-item dismiss + clear all.
// Triggered by the bell pill in shell.qml. Same anchoring contract as the other popups.
Item {
    id: notifPopup

    property bool open: false
    property var anchorWindow: null
    property var anchorPill: null
    property int anchorY: 0
    property int screenWidth: 1920   // set from shell.qml
    property real anchorX: 0
    readonly property int popupHeight: 250   // consumed by shell.qml stacking

    required property QtObject notifStatus

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
            notifStatus.refresh()
        }
    }

    PopupWindow {
        id: popWin
        visible: notifPopup.open
        implicitWidth:  300
        implicitHeight: notifPopup.popupHeight
        anchor.window: notifPopup.anchorWindow
        anchor.rect.y: notifPopup.anchorY
        anchor.rect.x: notifPopup.anchorX

        Rectangle {
            id: bg
            anchors.fill: parent
            color: "#282828"
            border.color: "#3c3836"
            border.width: 3

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: bg.border.width + 8
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Notifications"
                        color: "#a89984"
                        font.family: "iosevka, monospace"
                        font.pixelSize: 10
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        id: clearBtn
                        visible: notifPopup.notifStatus.notifications.length > 0
                        text: "\uf00d  Clear all"
                        color: clearMa.containsMouse ? "#fb4934" : "#504945"
                        font.family: "iosevka, monospace"
                        font.pixelSize: 9
                        MouseArea {
                            id: clearMa
                            anchors.fill: parent
                            anchors.margins: -4
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notifPopup.notifStatus.dismissAll()
                        }
                    }
                }

                Text {
                    visible: notifPopup.notifStatus.notifications.length === 0
                    text: "No notifications"
                    color: "#665c54"
                    font.family: "iosevka, monospace"
                    font.pixelSize: 10
                }

                Repeater {
                    model: Math.min(notifPopup.notifStatus.notifications.length, 5)
                    delegate: ColumnLayout {
                        required property int index
                        readonly property var n: notifPopup.notifStatus.notifications[index]
                        spacing: 1
                        Layout.fillWidth: true

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: n.summary !== "" ? n.summary : n.appName
                                color: "#ebdbb2"
                                font.family: "iosevka, monospace"
                                font.pixelSize: 10
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: "\uf00d"
                                color: disMa.containsMouse ? "#fb4934" : "#665c54"
                                font.family: "Font Awesome 6 Free"
                                font.pixelSize: 9
                                MouseArea {
                                    id: disMa
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notifPopup.notifStatus.dismiss(n.id)
                                }
                            }
                        }
                        Text {
                            visible: n.body !== "" || n.summary === ""
                            text: n.body !== "" ? n.body : n.appName
                            color: "#a89984"
                            font.family: "iosevka, monospace"
                            font.pixelSize: 9
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                Text {
                    visible: notifPopup.notifStatus.notifications.length > 5
                    text: "…and " + (notifPopup.notifStatus.notifications.length - 5) + " more"
                    color: "#665c54"
                    font.family: "iosevka, monospace"
                    font.pixelSize: 9
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
