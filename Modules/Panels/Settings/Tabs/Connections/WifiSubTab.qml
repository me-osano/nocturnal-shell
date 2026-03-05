import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Bluetooth

import qs.Commons
import qs.Services.Networking
import qs.Services.System
import qs.Services.UI
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL
  Layout.fillWidth: true

  // Master Controls
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: masterControlCol.implicitHeight + Style.margin2L
    color: Color.mSurface

    ColumnLayout {
      id: masterControlCol
      spacing: Style.marginL
      anchors.fill: parent
      anchors.margins: Style.marginL

      // Airplane Mode Toggle
      NToggle {
        Layout.fillWidth: true
        label: "Airplane Mode"
        description: "Disable all wireless connections"
        icon: Settings.data.network.airplaneModeEnabled ? "plane" : "plane-off"
        checked: Settings.data.network.airplaneModeEnabled
        onToggled: checked => BluetoothService.setAirplaneMode(checked)
      }

      NDivider {
        Layout.fillWidth: true
      }

      // Wi-Fi Master Control
      NToggle {
        Layout.fillWidth: true
        label: "Wi-Fi"
        description: NetworkService.wifiAvailable ? "Wireless network connectivity" : "No Wi-Fi adapter detected"
        icon: Settings.data.network.wifiEnabled ? "wifi" : "wifi-off"
        checked: Settings.data.network.wifiEnabled
        onToggled: checked => NetworkService.setWifiEnabled(checked)
        enabled: ProgramCheckerService.nmcliAvailable && !Settings.data.network.airplaneModeEnabled && NetworkService.wifiAvailable
      }
    }
  }

  // Connection Status
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: statusCol.implicitHeight + Style.margin2L
    color: Color.mSurface

    ColumnLayout {
      id: statusCol
      spacing: Style.marginM
      anchors.fill: parent
      anchors.margins: Style.marginL

      NHeader {
        label: "Connection Status"
      }

      // Current Wi-Fi connection
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        visible: Settings.data.network.wifiEnabled

        NIcon {
          icon: {
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
          }
          pointSize: Style.fontSizeXL
          color: {
            for (const net in NetworkService.networks) {
              if (NetworkService.networks[net].connected) {
                return Color.mPrimary;
              }
            }
            return Color.mOnSurfaceVariant;
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 0

          NText {
            text: {
              for (const net in NetworkService.networks) {
                if (NetworkService.networks[net].connected) {
                  return net;
                }
              }
              return "Not connected";
            }
            font.weight: Style.fontWeightBold
            pointSize: Style.fontSizeM
          }

          NText {
            visible: {
              for (const net in NetworkService.networks) {
                if (NetworkService.networks[net].connected) {
                  return true;
                }
              }
              return false;
            }
            text: {
              const w = NetworkService.activeWifiDetails || ({});
              const parts = [];
              if (w.rateShort) parts.push(w.rateShort);
              if (w.freq) parts.push(w.freq);
              if (w.security) parts.push(w.security);
              return parts.length > 0 ? parts.join(" · ") : "Connected";
            }
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
          }
        }

        NButton {
          visible: {
            for (const net in NetworkService.networks) {
              if (NetworkService.networks[net].connected) {
                return true;
              }
            }
            return false;
          }
          text: "Disconnect"
          onClicked: {
            for (const net in NetworkService.networks) {
              if (NetworkService.networks[net].connected) {
                NetworkService.disconnect(net);
                break;
              }
            }
          }
        }
      }

      // Ethernet status
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        visible: NetworkService.ethernetAvailable

        NIcon {
          icon: NetworkService.ethernetConnected ? "ethernet" : "ethernet-off"
          pointSize: Style.fontSizeXL
          color: NetworkService.ethernetConnected ? Color.mPrimary : Color.mOnSurfaceVariant
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 0

          NText {
            text: NetworkService.ethernetConnected ? "Ethernet Connected" : "Ethernet Disconnected"
            font.weight: Style.fontWeightBold
            pointSize: Style.fontSizeM
          }

          NText {
            visible: NetworkService.ethernetConnected
            text: {
              const d = NetworkService.activeEthernetDetails || ({});
              const parts = [];
              if (d.speed) parts.push(d.speed);
              if (d.ipv4) parts.push(d.ipv4);
              return parts.length > 0 ? parts.join(" · ") : "Connected";
            }
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
          }
        }
      }

      // Internet connectivity
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NIcon {
          icon: NetworkService.internetConnectivity ? "world" : "world-off"
          pointSize: Style.fontSizeL
          color: NetworkService.internetConnectivity ? Color.mPrimary : Color.mError
        }

        NText {
          text: NetworkService.internetConnectivity ? "Internet connected" : "No internet connection"
          pointSize: Style.fontSizeS
          color: NetworkService.internetConnectivity ? Color.mOnSurface : Color.mError
        }
      }
    }
  }

  // Network Details (when connected to Wi-Fi)
  NCollapsible {
    Layout.fillWidth: true
    title: "Wi-Fi Details"
    visible: {
      for (const net in NetworkService.networks) {
        if (NetworkService.networks[net].connected) {
          return true;
        }
      }
      return false;
    }

    ColumnLayout {
      spacing: Style.marginS
      Layout.fillWidth: true

      // SSID
      RowLayout {
        Layout.fillWidth: true
        NText {
          text: "Network Name"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: {
            for (const net in NetworkService.networks) {
              if (NetworkService.networks[net].connected) {
                return net;
              }
            }
            return "—";
          }
          pointSize: Style.fontSizeS
          Layout.fillWidth: true
        }
      }

      // Signal Strength
      RowLayout {
        Layout.fillWidth: true
        NText {
          text: "Signal Strength"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: {
            for (const net in NetworkService.networks) {
              if (NetworkService.networks[net].connected) {
                return NetworkService.networks[net].signal + "%";
              }
            }
            return "—";
          }
          pointSize: Style.fontSizeS
          Layout.fillWidth: true
        }
      }

      // Frequency
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeWifiDetails && NetworkService.activeWifiDetails.freq
        NText {
          text: "Frequency"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeWifiDetails ? (NetworkService.activeWifiDetails.freq || "—") : "—"
          pointSize: Style.fontSizeS
          Layout.fillWidth: true
        }
      }

      // Link Speed
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeWifiDetails && NetworkService.activeWifiDetails.rate
        NText {
          text: "Link Speed"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeWifiDetails ? (NetworkService.activeWifiDetails.rate || "—") : "—"
          pointSize: Style.fontSizeS
          Layout.fillWidth: true
        }
      }

      // Security
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeWifiDetails && NetworkService.activeWifiDetails.security
        NText {
          text: "Security"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeWifiDetails ? (NetworkService.activeWifiDetails.security || "—") : "—"
          pointSize: Style.fontSizeS
          Layout.fillWidth: true
        }
      }

      // BSSID
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeWifiDetails && NetworkService.activeWifiDetails.bssid
        NText {
          text: "BSSID"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeWifiDetails ? (NetworkService.activeWifiDetails.bssid || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          Layout.fillWidth: true
        }
      }

      // IPv4 Address
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeWifiDetails && NetworkService.activeWifiDetails.ipv4
        NText {
          text: "IPv4 Address"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeWifiDetails ? (NetworkService.activeWifiDetails.ipv4 || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          Layout.fillWidth: true
        }
      }

      // IPv6 Address
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeWifiDetails && NetworkService.activeWifiDetails.ipv6
        NText {
          text: "IPv6 Address"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeWifiDetails ? (NetworkService.activeWifiDetails.ipv6 || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          elide: Text.ElideMiddle
          Layout.fillWidth: true
        }
      }

      // Gateway
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeWifiDetails && NetworkService.activeWifiDetails.gateway
        NText {
          text: "Gateway"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeWifiDetails ? (NetworkService.activeWifiDetails.gateway || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          Layout.fillWidth: true
        }
      }

      // DNS
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeWifiDetails && NetworkService.activeWifiDetails.dns
        NText {
          text: "DNS"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeWifiDetails ? (NetworkService.activeWifiDetails.dns || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          Layout.fillWidth: true
        }
      }
    }
  }

  // Ethernet Details (when connected)
  NCollapsible {
    Layout.fillWidth: true
    title: "Ethernet Details"
    visible: NetworkService.ethernetConnected

    ColumnLayout {
      spacing: Style.marginS
      Layout.fillWidth: true

      // Interface
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeEthernetIf
        NText {
          text: "Interface"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeEthernetIf || "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          Layout.fillWidth: true
        }
      }

      // Speed
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeEthernetDetails && NetworkService.activeEthernetDetails.speed
        NText {
          text: "Link Speed"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeEthernetDetails ? (NetworkService.activeEthernetDetails.speed || "—") : "—"
          pointSize: Style.fontSizeS
          Layout.fillWidth: true
        }
      }

      // IPv4 Address
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeEthernetDetails && NetworkService.activeEthernetDetails.ipv4
        NText {
          text: "IPv4 Address"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeEthernetDetails ? (NetworkService.activeEthernetDetails.ipv4 || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          Layout.fillWidth: true
        }
      }

      // IPv6 Address
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeEthernetDetails && NetworkService.activeEthernetDetails.ipv6
        NText {
          text: "IPv6 Address"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeEthernetDetails ? (NetworkService.activeEthernetDetails.ipv6 || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          elide: Text.ElideMiddle
          Layout.fillWidth: true
        }
      }

      // Gateway
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeEthernetDetails && NetworkService.activeEthernetDetails.gateway
        NText {
          text: "Gateway"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeEthernetDetails ? (NetworkService.activeEthernetDetails.gateway || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          Layout.fillWidth: true
        }
      }

      // DNS
      RowLayout {
        Layout.fillWidth: true
        visible: NetworkService.activeEthernetDetails && NetworkService.activeEthernetDetails.dns
        NText {
          text: "DNS"
          pointSize: Style.fontSizeS
          color: Color.mOnSurfaceVariant
          Layout.preferredWidth: 120
        }
        NText {
          text: NetworkService.activeEthernetDetails ? (NetworkService.activeEthernetDetails.dns || "—") : "—"
          pointSize: Style.fontSizeS
          font.family: Style.fontMono
          Layout.fillWidth: true
        }
      }
    }
  }

  // Quick Actions
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: actionsCol.implicitHeight + Style.margin2L
    color: Color.mSurface

    ColumnLayout {
      id: actionsCol
      spacing: Style.marginM
      anchors.fill: parent
      anchors.margins: Style.marginL

      NHeader {
        label: "Quick Actions"
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NButton {
          text: "Scan Networks"
          icon: "refresh"
          enabled: Settings.data.network.wifiEnabled && !NetworkService.scanning
          onClicked: NetworkService.scan()
        }

        NButton {
          text: "Open Network Panel"
          icon: "wifi"
          onClicked: {
            var panel = PanelService.getPanel("networkPanel", null);
            if (panel) panel.toggle();
          }
        }
      }
    }
  }

  // Spacer to push content up
  Item {
    Layout.fillHeight: true
  }
}
