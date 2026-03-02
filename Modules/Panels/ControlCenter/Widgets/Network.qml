import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Networking
import qs.Services.UI
import qs.Widgets

NIconButtonHot {
  property ShellScreen screen

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
      Logger.e("Wi-Fi", "Error getting icon:", error);
      return "wifi-off";
    }
  }

  tooltipText: {
    try {
      if (NetworkService.ethernetConnected) {
        // Match design: fixed label when on Ethernet
        return "Ethernet";
      }
      // Wi‑Fi: SSID — link speed (if available)
      for (const net in NetworkService.networks) {
        if (NetworkService.networks[net].connected) {
          const w = NetworkService.activeWifiDetails || ({});
          const rate = (w.rateShort && w.rateShort.length > 0) ? w.rateShort : (w.rate || "");
          return rate && rate.length > 0 ? (net + " — " + rate) : net;
        }
      }
    } catch (e) {
      // noop
    }
    return "Wi-Fi";
  }
  onClicked: {
    // Toggle network card visibility in control center
    if (Settings.data.controlCenter.cards) {
      let found = false;
      for (let i = 0; i < Settings.data.controlCenter.cards.length; i++) {
        if (Settings.data.controlCenter.cards[i].id === "network-card") {
          Settings.data.controlCenter.cards[i].enabled = !Settings.data.controlCenter.cards[i].enabled;
          found = true;
          break;
        }
      }
      if (!found) {
        // Network card not in the list, add it enabled
        Settings.data.controlCenter.cards.push({
          "id": "network-card",
          "enabled": true
        });
      }
      // Trigger update by reassigning
      Settings.data.controlCenter.cards = Settings.data.controlCenter.cards;
    }
  }
  onRightClicked: {
    if (!Settings.data.network.airplaneModeEnabled) {
      NetworkService.setWifiEnabled(!Settings.data.network.wifiEnabled);
    }
  }
}
