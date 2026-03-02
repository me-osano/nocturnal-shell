import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Networking
import qs.Services.UI
import qs.Widgets

NIconButtonHot {
  property ShellScreen screen

  icon: !BluetoothService.enabled ? "bluetooth-off" : ((BluetoothService.connectedDevices && BluetoothService.connectedDevices.length > 0) ? "bluetooth-connected" : "bluetooth")
  tooltipText: "Bluetooth"
  onClicked: {
    // Toggle bluetooth card expanded state in control center
    var panel = PanelService.getPanel("controlCenterPanel", screen);
    if (panel) {
      panel.bluetoothCardExpanded = !panel.bluetoothCardExpanded;
    }
  }
  onRightClicked: {
    if (!Settings.data.network.airplaneModeEnabled) {
      BluetoothService.setBluetoothEnabled(!BluetoothService.enabled);
    }
  }
}
