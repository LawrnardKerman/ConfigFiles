import QtQuick
import Quickshell.Services.Notifications

// Notifications source backed by quickshell's own NotificationServer.
// Replaces mako — do NOT run mako alongside this (both fight over the
// org.freedesktop.Notifications dbus name).
//
// Incoming notifications are copied into `notifications` (newest first)
// and held here until the user dismisses them, regardless of the
// sender's timeout. Nothing is rendered outside the popups.
Item {
    id: root

    property var notifications: []   // [{ id, appName, summary, body, ref }]
    property int maxStored: 20

    // Kept for popup compatibility; data arrives pushed, no polling needed.
    function refresh() {}

    function dismiss(id) {
        for (var i = 0; i < root.notifications.length; i++) {
            if (root.notifications[i].id === id) {
                var n = root.notifications[i]
                if (n.ref && n.ref.tracked) n.ref.dismiss()
                var arr = root.notifications.slice()
                arr.splice(i, 1)
                root.notifications = arr
                return
            }
        }
    }

    function dismissAll() {
        for (var i = 0; i < root.notifications.length; i++) {
            var n = root.notifications[i]
            if (n.ref && n.ref.tracked) n.ref.dismiss()
        }
        root.notifications = []
    }

    NotificationServer {
        id: server

        bodySupported: true
        actionsSupported: true
        persistenceSupported: true

        onNotification: function(notif) {
            var entry = {
                id: notif.id,
                appName: notif.appName || "Notification",
                summary: notif.summary || "",
                body: notif.body || "",
                ref: notif
            }
            var arr = [entry].concat(root.notifications)
            while (arr.length > root.maxStored) arr.pop()
            root.notifications = arr
        }
    }
}
