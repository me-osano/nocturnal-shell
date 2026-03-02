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
  property bool expanded: (root.unreadCount > 0)
  property int compactItems: 5
  property bool showAll: false
  readonly property real compactViewportHeight: Math.round(160 * Style.uiScaleRatio)
  readonly property real expandedViewportHeight: Math.round(260 * Style.uiScaleRatio)
  readonly property real listViewportHeight: showAll ? expandedViewportHeight : compactViewportHeight
  // 0 = All, 1 = Today, 2 = Yesterday, 3 = Earlier
  property int currentRange: 1

  clip: true

  Behavior on implicitHeight {
    NumberAnimation {
      duration: Style.animationNormal
      easing.type: Easing.InOutQuad
    }
  }

  implicitHeight: expanded ? (headerRow.implicitHeight + Style.margin2M + contentArea.implicitHeight + Style.margin2M) : (headerRow.implicitHeight + Style.margin2M)

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

  readonly property var rangeCounts: {
    var counts = [0, 0, 0, 0];
    var model = NotificationService.historyList;
    counts[0] = model.count;
    for (var i = 0; i < model.count; i++) {
      var item = model.get(i);
      if (!item || item.timestamp === undefined)
        continue;
      var ts = item.timestamp instanceof Date ? item.timestamp.getTime() : Number(item.timestamp);
      if (!isFinite(ts))
        continue;
      var range = rangeForTimestamp(ts);
      counts[range + 1] = counts[range + 1] + 1;
    }
    return counts;
  }

  readonly property var filteredIndices: {
    var list = [];
    var model = NotificationService.historyList;
    for (var i = 0; i < model.count; i++) {
      var item = model.get(i);
      if (!item || item.timestamp === undefined)
        continue;
      var ts = item.timestamp instanceof Date ? item.timestamp.getTime() : Number(item.timestamp);
      if (!isFinite(ts))
        continue;
      if (currentRange === 0 || rangeForTimestamp(ts) === (currentRange - 1)) {
        list.push(i);
      }
    }
    return list;
  }

  readonly property bool canViewAll: filteredIndices.length > compactItems

  implicitHeight: Math.max(Math.round(240 * Style.uiScaleRatio), content.implicitHeight + Style.margin2M)

  function dateOnly(dateObj) {
    return new Date(dateObj.getFullYear(), dateObj.getMonth(), dateObj.getDate());
  }

  function rangeForTimestamp(ts) {
    var dt = new Date(ts);
    var today = dateOnly(new Date());
    var thatDay = dateOnly(dt);
    var diffMs = today - thatDay;
    var diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    if (diffDays === 0)
      return 0;
    if (diffDays === 1)
      return 1;
    return 2;
  }

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
      id: headerRow
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
        icon: "check"
        tooltipText: "Mark all as read"
        onClicked: NotificationService.updateLastSeenTs()
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

      // Expand/collapse button
      NIconButton {
        icon: root.expanded ? "chevron-up" : "chevron-down"
        baseSize: Style.baseWidgetSize * 0.8
        tooltipText: root.expanded ? "Collapse" : "Expand"
        onClicked: root.expanded = !root.expanded
      }
    }

    // Collapsible content
    Item {
      id: contentArea
      visible: root.expanded
      Layout.fillWidth: true
      implicitHeight: contentColumn.implicitHeight

      ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: Style.marginS

        NDivider {
          Layout.fillWidth: true
        }

        NTabBar {
          id: rangeTabs
          visible: root.totalCount > 0
          Layout.fillWidth: true
          currentIndex: root.currentRange
          distributeEvenly: true

          NTabButton {
            tabIndex: 0
            text: "All (" + root.rangeCounts[0] + ")"
            checked: rangeTabs.currentIndex === 0
            onClicked: root.currentRange = 0
            pointSize: Style.fontSizeXS
          }

          NTabButton {
            tabIndex: 1
            text: "Today (" + root.rangeCounts[1] + ")"
            checked: rangeTabs.currentIndex === 1
            onClicked: root.currentRange = 1
            pointSize: Style.fontSizeXS
          }

          NTabButton {
            tabIndex: 2
            text: "Yesterday (" + root.rangeCounts[2] + ")"
            checked: rangeTabs.currentIndex === 2
            onClicked: root.currentRange = 2
            pointSize: Style.fontSizeXS
          }

          NTabButton {
            tabIndex: 3
            text: "Earlier (" + root.rangeCounts[3] + ")"
            checked: rangeTabs.currentIndex === 3
            onClicked: root.currentRange = 3
            pointSize: Style.fontSizeXS
          }
        }

        RowLayout {
          visible: root.filteredIndices.length > 0 && root.canViewAll
          Layout.fillWidth: true
          spacing: Style.marginS

          Item {
            Layout.fillWidth: true
          }

          NButton {
            icon: root.showAll ? "chevron-up" : "chevron-down"
            text: root.showAll ? "Show less" : "View all"
            outlined: true
            onClicked: root.showAll = !root.showAll
          }
        }

        Loader {
          active: root.totalCount === 0 || root.filteredIndices.length === 0
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

              text: root.totalCount === 0 ? "No notifications" : "No notifications in this range"
              color: Color.mOnSurfaceVariant
              Layout.alignment: Qt.AlignHCenter
            }
          }
        }

        NScrollView {
          visible: root.filteredIndices.length > 0
          Layout.fillWidth: true
          Layout.preferredHeight: root.listViewportHeight
          horizontalPolicy: ScrollBar.AlwaysOff
          verticalPolicy: ScrollBar.AsNeeded
          reserveScrollbarSpace: false

          ColumnLayout {
            width: parent.width
            spacing: Style.marginXS

            Repeater {
          model: root.showAll ? root.filteredIndices : root.filteredIndices.slice(0, root.compactItems)

          delegate: Rectangle {
            required property var modelData

            readonly property int notifIndex: Number(modelData)
            readonly property var notif: NotificationService.historyList.get(notifIndex)
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
                PanelService.getPanel("controlCenterPanel", root.screen)?.open();
              }
            }
          }
        }
      }
    }
  }
}