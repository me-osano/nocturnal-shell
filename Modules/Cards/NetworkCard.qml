import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Panels.Network
import qs.Services.Networking
import qs.Services.UI
import qs.Widgets

// Network card: network status and quick controls
NBox {
  id: root

  property ShellScreen screen

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Style.marginM
    spacing: Style.marginM

    // Header
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
            Logger.e("Network Card", "Error getting icon:", error);
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
    }

    // Open network settings button
    NButton {
      text: "Network Settings"
      Layout.fillWidth: true
      onClicked: SettingsPanelService.openToTab(SettingsPanel.Tab.Connections, 0, screen)
    }
  }
}
