import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

// Blurred-screenshot lock screen.
//
// Flow: on lock() a screenshot of the current desktop is taken (must happen
// before the session lock engages), blurred with ImageMagick into
// ~/.cache/quickshell/lock-bg.png, then the WlSessionLock engages and shows
// that image behind a centered square password box.
//
// Requires: grim, ImageMagick (magick), and /etc/pam.d/quickshell:
//   auth required pam_unix.so
//
// NOTE: WlSessionLock's default property only accepts its surface, so the
// Process/PamContext live in this Scope wrapper next to the lock.
Scope {
    id: root

    function lock() {
        console.warn("lockscreen: lock() called")
        failed = false
        shotProc.running = true
    }

    property string blurPath: Quickshell.env("HOME") + "/.cache/quickshell/lock-bg.png"
    property string bgSource: ""
    property bool authing: false
    property bool failed: false
    property string pendingResponse: ""

    WlSessionLock {
        id: lockItem

        WlSessionLockSurface {
            Image {
                id: bgImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                cache: false
                source: root.bgSource === "" ? "" : "file://" + root.bgSource

                // Dim + gruvbox tint so the input box pops
                Rectangle {
                    anchors.fill: parent
                    color: Theme.bg
                    opacity: 0.35
                }
            }

            // ── Square password box ──────────────────────────────────────
            Rectangle {
                id: inputBox
                width: 240; height: 240
                anchors.centerIn: parent
                color: Theme.bg
                border.color: root.failed ? Theme.red
                            : passwordBox.activeFocus ? Theme.aqua
                            : Theme.border
                border.width: Theme.pillBorderWidth

                Column {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(new Date(), "h:mm ap")
                        color: Theme.aqua
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 6
                        font.bold: true

                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: parent.text = Qt.formatDateTime(new Date(), "h:mm ap")
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.failed ? "Wrong password" : "Enter password"
                        color: root.failed ? Theme.red : "#a89984"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                    }

                    TextField {
                        id: passwordBox
                        width: 180
                        height: 36
                        anchors.horizontalCenter: parent.horizontalCenter
                        echoMode: TextInput.Password
                        enabled: !root.authing
                        focus: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        color: Theme.fg
                        selectionColor: Theme.aqua
                        verticalAlignment: TextInput.AlignVCenter
                        horizontalAlignment: TextInput.AlignHCenter

                        background: Rectangle {
                            color: Theme.bgHover
                            border.color: Theme.borderLight
                            border.width: 1
                        }

                        onAccepted: {
                            console.warn("lockscreen: accepted len=" + text.length + " authing=" + root.authing)
                            if (text.length === 0 || root.authing) return
                            root.authing = true
                            root.failed = false
                            root.pendingResponse = text
                            text = ""
                            var ok = pam.start()
                            console.warn("lockscreen: pam.start() -> " + ok)
                            if (!ok) {
                                root.pendingResponse = ""
                                root.failed = true
                                root.authing = false
                            }
                        }

                        Keys.onEscapePressed: text = ""
                    }
                }
            }

            Component.onCompleted: passwordBox.forceActiveFocus()

            Connections {
                target: root
                function onFailedChanged() {
                    if (root.failed) passwordBox.forceActiveFocus()
                }
            }
        }
    }

    // Screenshot + blur BEFORE engaging the lock (compositor blocks
    // screencopy while locked)
    Process {
        id: shotProc
        command: ["bash", "-c",
            "CACHE=\"$HOME/.cache/quickshell\"; " +
            "mkdir -p \"$CACHE\"; " +
            "grim -c \"$CACHE/lock-raw.png\" && " +
            "magick \"$CACHE/lock-raw.png\" -resize 50% -blur 0x8 -resize 200% \"$CACHE/lock-bg.png\" && " +
            "rm -f \"$CACHE/lock-raw.png\""]
        onExited: function(code) {
            console.warn("lockscreen: screenshot exited " + code + ", engaging lock")
            if (code === 0) {
                lockItem.locked = true
                root.bgSource = root.blurPath   // surface now exists; decode fresh file
            }
        }
    }

    PamContext {
        id: pam
        config: "quickshell"

        // pam asks for the password via a prompt; respond once it is required
        onPamMessage: {
            console.warn("lockscreen: pamMessage msg=" + pam.message
                + " responseRequired=" + pam.responseRequired)
            if (pam.responseRequired) {
                console.warn("lockscreen: responding len=" + root.pendingResponse.length)
                pam.respond(root.pendingResponse)
                root.pendingResponse = ""
            }
        }

        onCompleted: result => {
            console.warn("lockscreen: completed result=" + result
                + " (Success=" + PamResult.Success + ")")
            if (result === PamResult.Success) {
                lockItem.locked = false
            } else {
                root.failed = true
            }
            root.authing = false
        }
        onError: err => {
            console.warn("lockscreen: pam error code=" + err)
            root.failed = true
            root.authing = false
        }
    }
}
