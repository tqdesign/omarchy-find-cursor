import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons

// Click-through overlay that draws rings collapsing onto a point. The caller
// (find-cursor) passes the pointer position from `hyprctl cursorpos`, since
// layer surfaces can't read the global cursor themselves.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property real cx: 0
  property real cy: 0
  property int gen: 0

  readonly property string pluginId: (manifest && manifest.id) ? String(manifest.id) : "tqdesign.find-cursor"
  readonly property int ringCount: 2
  readonly property int ringDelayMs: 140
  readonly property int shrinkMs: 520
  readonly property real startRadius: 130
  readonly property real endRadius: 6

  function open(payloadJson) {
    var payload = ({})
    try { payload = JSON.parse(payloadJson || "{}") } catch (e) { payload = ({}) }
    root.cx = Number(payload.x) || 0
    root.cy = Number(payload.y) || 0
    root.opened = true
    root.gen += 1
    hideTimer.restart()
  }

  function close() {
    hideTimer.stop()
    root.opened = false
  }

  Timer {
    id: hideTimer
    interval: root.shrinkMs + root.ringDelayMs * (root.ringCount - 1) + 60
    onTriggered: {
      root.opened = false
      if (root.shell && typeof root.shell.hide === "function")
        root.shell.hide(root.pluginId)
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData
      screen: modelData

      readonly property real localX: root.cx - modelData.x
      readonly property real localY: root.cy - modelData.y
      readonly property bool hasCursor: localX >= 0 && localX < modelData.width
        && localY >= 0 && localY < modelData.height

      visible: root.opened && hasCursor
      color: "transparent"
      WlrLayershell.namespace: "tqdesign-find-cursor"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore
      anchors { top: true; bottom: true; left: true; right: true }
      mask: Region {}

      Repeater {
        model: root.ringCount

        Item {
          id: ring
          required property int index
          property real radius: root.startRadius

          x: panel.localX - radius
          y: panel.localY - radius
          width: radius * 2
          height: radius * 2
          opacity: 0

          // Dark halo under the accent stroke keeps the ring visible on any background.
          Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: width / 2
            color: "transparent"
            border.width: 8
            border.color: Qt.rgba(0, 0, 0, 0.45)
          }
          Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: 4
            border.color: Color.accent
          }

          SequentialAnimation {
            id: anim
            PropertyAction { target: ring; property: "radius"; value: root.startRadius }
            PropertyAction { target: ring; property: "opacity"; value: 0 }
            PauseAnimation { duration: ring.index * root.ringDelayMs }
            PropertyAction { target: ring; property: "opacity"; value: 1 }
            ParallelAnimation {
              NumberAnimation {
                target: ring; property: "radius"
                to: root.endRadius; duration: root.shrinkMs
                easing.type: Easing.InOutCubic
              }
              SequentialAnimation {
                PauseAnimation { duration: root.shrinkMs * 0.6 }
                NumberAnimation {
                  target: ring; property: "opacity"
                  to: 0; duration: root.shrinkMs * 0.4
                }
              }
            }
          }

          Connections {
            target: root
            function onGenChanged() { anim.restart() }
          }
          Component.onCompleted: if (root.opened) anim.restart()
        }
      }
    }
  }
}
