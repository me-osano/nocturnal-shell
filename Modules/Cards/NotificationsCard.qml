import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.System
import qs.Services.UI
import qs.Widgets

NBox {
  id: root

  property var screen
  property int maxItems: 3

  readonly property int totalCount: NotificationService.historyList.count
  readonly property int unreadCount: {
    var since = NotificationService.lastSeenTs;
    var count = 0;
    var model = NotificationService.historyList;
    for (var i = 0; i < model.count; i++) {
      var item = model.get(i);
      var ts = item.timestamp instanceof Date ? item.timestamp.getTime() : item.timestamp;
      if (ts > since)
        count++;
    }
    return count;
  }

  implicitHeight: Math.max(Math.round(128 * Style.uiScaleRatio), content.implicitHeight + Style.margin2M)

  function formatTime(ts) {
    var date = new Date(ts);
    return Qt.locale("en").toString(date, "HH:mm");
  }

  function isUnread(ts) {
    return ts > NotificationService.lastSeenTs;
  }

  ColumnLayout {
    id: content
    anchors.fill: parent
    anchors.margins: Style.marginM
    spacing: Style.marginS

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      NIcon {
        icon: NotificationService.doNotDisturb ? "bell-off" : "bell"
        pointSize: Style.fontSizeXL
        color: Color.mPrimary
      }

      NText {
        text: "Notifications"
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
      }

      Rectangle {
        visible: root.unreadCount > 0
        color: Color.mPrimary
        radius: Style.radiusL
        implicitWidth: unreadText.implicitWidth + Style.marginM
        implicitHeight: unreadText.implicitHeight + Style.marginXS

        NText {
          id: unreadText
          anchors.centerIn: parent
          text: root.unreadCount
          color: Color.mOnPrimary
          pointSize: Style.fontSizeXS
          font.weight: Style.fontWeightBold
        }
      }

      Item {
        Layout.fillWidth: true
      }

      NIconButton {
        icon: "external-link"
        tooltipText: "Open notification history"
        onClicked: PanelService.getPanel("notificationHistoryPanel", root.screen)?.open()
      }

      NIconButton {
        icon: NotificationService.doNotDisturb ? "bell" : "bell-off"
        tooltipText: NotificationService.doNotDisturb ? "Disable Do Not Disturb" : "Enable Do Not Disturb"
        onClicked: NotificationService.doNotDisturb = !NotificationService.doNotDisturb
      }

      NIconButton {
        icon: "trash"
        tooltipText: "Clear notification history"
        onClicked: NotificationService.clearHistory()
      }
    }

    NDivider {
      Layout.fillWidth: true
    }

    Loader {
      active: root.totalCount === 0
      Layout.fillWidth: true
      sourceComponent: ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginXS

        NIcon {
          icon: "bell-off"
          pointSize: Style.fontSizeXXL
          color: Color.mOnSurfaceVariant
          Layout.alignment: Qt.AlignHCenter
        }

        NText {
          text: "No notifications"
          color: Color.mOnSurfaceVariant
          Layout.alignment: Qt.AlignHCenter
        }
      }
    }

    ColumnLayout {
      visible: root.totalCount > 0
      Layout.fillWidth: true
      spacing: Style.marginXS

      Repeater {
        model: Math.min(root.maxItems, NotificationService.historyList.count)

        delegate: Rectangle {
          required property int index

          readonly property var notif: NotificationService.historyList.get(index)
          readonly property real ts: notif && notif.timestamp ? (notif.timestamp instanceof Date ? notif.timestamp.getTime() : notif.timestamp) : 0

          Layout.fillWidth: true
          radius: Style.radiusS
          color: itemMouseArea.containsMouse ? Color.mHover : "transparent"
          implicitHeight: itemLayout.implicitHeight + Style.marginS

          Behavior on color {
            enabled: !Color.isTransitioning
            ColorAnimation {
              duration: Style.animationFast
              easing.type: Easing.InOutQuad
            }
          }

          RowLayout {
            id: itemLayout
            anchors.fill: parent
            anchors.leftMargin: Style.marginS
            anchors.rightMargin: Style.marginS
            anchors.topMargin: Style.marginXS
            anchors.bottomMargin: Style.marginXS
            spacing: Style.marginS

            Rectangle {
              visible: root.isUnread(ts)
              width: 8
              height: 8
              radius: width / 2
              color: Color.mPrimary
              Layout.alignment: Qt.AlignTop
              Layout.topMargin: Style.marginXS
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 0

              NText {
                text: (notif && notif.summary) ? notif.summary : "Notification"
                font.weight: Style.fontWeightSemiBold
                color: itemMouseArea.containsMouse ? Color.mOnHover : Color.mOnSurface
                elide: Text.ElideRight
                maximumLineCount: 1
                Layout.fillWidth: true
              }

              NText {
                text: (notif && notif.appName ? notif.appName + " • " : "") + root.formatTime(ts)
                pointSize: Style.fontSizeXS
                color: itemMouseArea.containsMouse ? Color.mOnHover : Color.mOnSurfaceVariant
                elide: Text.ElideRight
                maximumLineCount: 1
                Layout.fillWidth: true
              }
            }
          }

          MouseArea {
            id: itemMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              NotificationService.updateLastSeenTs();
              PanelService.getPanel("notificationHistoryPanel", root.screen)?.open();
            }
          }
        }
      }
    }
  }
}
