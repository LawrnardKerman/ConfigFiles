import QtQuick
import QtQuick.Layouts
import Quickshell.I3

Row {
    spacing: 0

    Repeater {
        model: I3.workspaces
        Rectangle {
            width: 22; height: 18
            color: modelData.focused ? Theme.bgHover
                 : modelData.urgent  ? Theme.urgent
                 : wsHover.hovered   ? Theme.bgHover
                 : Theme.bg

            HoverHandler { id: wsHover }

            Text {
                anchors.centerIn: parent
                text: modelData.name
                color: modelData.focused ? Theme.fg : (modelData.urgent ? Theme.bgHover : Theme.fg)
                font.bold: modelData.focused
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: I3.dispatch("workspace " + modelData.name)
                onWheel: (event) => {
                    if (event.angleDelta.y < 0)
                        I3.dispatch("workspace next")
                    else
                        I3.dispatch("workspace prev")
                }
            }
        }
    }
}
