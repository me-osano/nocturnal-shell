import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Panels.Network
import qs.Services.Networking
import qs.Services.UI
import qs.Widgets

// Inline network panel that appears below shortcuts when WiFi button is clicked
NBox {
  id: root

  property ShellScreen screen
  property bool expanded: false
  
  // Expose the target height (non-animated) for parent layout calculations
  readonly property real targetHeight: expanded ? contentColumn.implicitHeight + Style.margin2M : 0

  clip: true
  visible: expanded
  
  Behavior on implicitHeight {
    NumberAnimation {
      duration: Style.animationNormal
      easing.type: Easing.InOutQuad
    }
  }

  implicitHeight: expanded ? contentColumn.implicitHeight + Style.margin2M : 0

  ColumnLayout {
    id: contentColumn
    anchors.fill: parent
    anchors.margins: Style.marginM
    spacing: Style.marginM

    // Header row with network status
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginM

      NIcon {
        id: headerIcon
        pointSize: Style.fontSizeL
        color: {
          try {
            if (NetworkService.ethernetConnected) {
              return Color.mPrimary;
            }
            for (const net in NetworkService.networks) {
              if (NetworkService.networks[net].connected) {
                return Color.mPrimary;
              }
            }
            return Color.mOnSurfaceVariant;
          } catch (e) {
            return Color.mOnSurfaceVariant;
          }
        }
        icon: {
          try {
            if (NetworkService.ethernetConnected) {
              return NetworkService.internetConnectivity ? "ethernet" : "ethernet-off";
            }
            let connected = false;
            let signalStrength = 0;
            for (const net in NetworkService.networks) {
              if (NetworkService.networks[net].connected) {
                connected = true;
                signalStrength = NetworkService.networks[net].signal;
                break;
              }
            }
            return connected ? NetworkService.signalIcon(signalStrength, true) : "wifi-off";
          } catch (error) {
            Logger.e("Network Panel", "Error getting icon:", error);
            return "wifi-off";
          }
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        NText {
          text: {
            try {
              if (NetworkService.ethernetConnected) {
                return "Ethernet";
              }
              for (const net in NetworkService.networks) {
                if (NetworkService.networks[net].connected) {
                  return net;
                }
              }
              return "Not Connected";
            } catch (e) {
              return "Network";
            }
          }
          font.weight: Style.fontWeightBold
          pointSize: Style.fontSizeS
        }

        NText {
          text: {
            try {
              if (NetworkService.ethernetConnected) {
                const d = NetworkService.activeEthernetDetails || ({});
                const speed = (d.speed && d.speed.length > 0) ? d.speed : "";
                return speed ? "Speed: " + speed : "Connected";
              }
              for (const net in NetworkService.networks) {
                if (NetworkService.networks[net].connected) {
                  const w = NetworkService.activeWifiDetails || ({});
                  const rate = (w.rateShort && w.rateShort.length > 0) ? w.rateShort : (w.rate || "");
                  return rate ? "Speed: " + rate : "Connected";
                }
              }
              return "Enable Wi-Fi to connect";
            } catch (e) {
              return "—";
            }
          }
          pointSize: Style.fontSizeXS
          color: Color.mOnSurfaceVariant
        }
      }

      Item {
        Layout.fillWidth: true
      }

      NToggle {
        id: wifiSwitch
        checked: Settings.data.network.wifiEnabled
        enabled: !Settings.data.network.airplaneModeEnabled && NetworkService.wifiAvailable
        onToggled: checked => NetworkService.setWifiEnabled(checked)
        baseSize: Style.baseWidgetSize * 0.65
      }

      // Collapse button
      NIconButton {
        icon: "chevron-up"
        baseSize: Style.baseWidgetSize * 0.8
        tooltipText: "Collapse"
        onClicked: {
          var panel = PanelService.getPanel("controlCenterPanel", screen);
          if (panel) {
            panel.networkCardExpanded = false;
          }
        }
      }
    }

    NDivider {
      Layout.fillWidth: true
    }

    // Network Settings button
    NButton {
      text: "Network Settings"
      Layout.fillWidth: true
      onClicked: SettingsPanelService.openToTab(SettingsPanel.Tab.Connections, 0, screen)
    }

    // WiFi Networks info
    NText {
      text: "Available Networks"
      font.weight: Style.fontWeightBold
      pointSize: Style.fontSizeS
      Layout.fillWidth: true
    }

    NText {
      text: Settings.data.network.wifiEnabled ? "Scan for networks..." : "Enable Wi-Fi to see networks"
      pointSize: Style.fontSizeXS
      color: Color.mOnSurfaceVariant
      Layout.fillWidth: true
    }
  }
}
