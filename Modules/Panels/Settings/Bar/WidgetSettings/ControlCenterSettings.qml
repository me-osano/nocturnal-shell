import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginM

  // Properties to receive data from parent
  property var screen: null
  property var widgetData: null
  property var widgetMetadata: null

  signal settingsChanged(var settings)

  // Local state - Display mode
  property string valueDisplayMode: widgetData.displayMode !== undefined ? widgetData.displayMode : widgetMetadata.displayMode
  property bool valueShowNetworkIcon: widgetData.showNetworkIcon !== undefined ? widgetData.showNetworkIcon : widgetMetadata.showNetworkIcon
  property bool valueShowBluetoothIcon: widgetData.showBluetoothIcon !== undefined ? widgetData.showBluetoothIcon : widgetMetadata.showBluetoothIcon
  property bool valueShowNotificationIcon: widgetData.showNotificationIcon !== undefined ? widgetData.showNotificationIcon : widgetMetadata.showNotificationIcon

  // Local state - Icon mode
  property string valueIcon: widgetData.icon !== undefined ? widgetData.icon : widgetMetadata.icon
  property bool valueUseDistroLogo: widgetData.useDistroLogo !== undefined ? widgetData.useDistroLogo : widgetMetadata.useDistroLogo
  property string valueCustomIconPath: widgetData.customIconPath !== undefined ? widgetData.customIconPath : widgetMetadata.customIconPath
  property bool valueEnableColorization: widgetData.enableColorization !== undefined ? widgetData.enableColorization : widgetMetadata.enableColorization
  property string valueColorizeSystemIcon: widgetData.colorizeSystemIcon !== undefined ? widgetData.colorizeSystemIcon : widgetMetadata.colorizeSystemIcon

  function saveSettings() {
    var settings = Object.assign({}, widgetData || {});
    settings.displayMode = valueDisplayMode;
    settings.showNetworkIcon = valueShowNetworkIcon;
    settings.showBluetoothIcon = valueShowBluetoothIcon;
    settings.showNotificationIcon = valueShowNotificationIcon;
    settings.icon = valueIcon;
    settings.useDistroLogo = valueUseDistroLogo;
    settings.customIconPath = valueCustomIconPath;
    settings.enableColorization = valueEnableColorization;
    settings.colorizeSystemIcon = valueColorizeSystemIcon;
    settingsChanged(settings);
  }

  // Display Mode Selection
  NHeader {
    text: "Display Mode"
  }

  NComboBox {
    label: "Widget style"
    description: "Choose how the control center button appears in the bar."
    model: [
      { value: "icon", text: "Single Icon" },
      { value: "capsule", text: "Capsule (Network, Bluetooth, Notifications)" }
    ]
    textRole: "text"
    valueRole: "value"
    currentIndex: valueDisplayMode === "capsule" ? 1 : 0
    onActivated: index => {
      valueDisplayMode = model[index].value;
      saveSettings();
    }
  }

  // Capsule mode settings
  NHeader {
    visible: valueDisplayMode === "capsule"
    text: "Capsule Icons"
  }

  NToggle {
    visible: valueDisplayMode === "capsule"
    label: "Show network icon"
    description: "Display network/Wi-Fi status icon in the capsule."
    checked: valueShowNetworkIcon
    onToggled: checked => {
      valueShowNetworkIcon = checked;
      saveSettings();
    }
  }

  NToggle {
    visible: valueDisplayMode === "capsule"
    label: "Show Bluetooth icon"
    description: "Display Bluetooth status icon in the capsule."
    checked: valueShowBluetoothIcon
    onToggled: checked => {
      valueShowBluetoothIcon = checked;
      saveSettings();
    }
  }

  NToggle {
    visible: valueDisplayMode === "capsule"
    label: "Show notification icon"
    description: "Display notification bell icon in the capsule."
    checked: valueShowNotificationIcon
    onToggled: checked => {
      valueShowNotificationIcon = checked;
      saveSettings();
    }
  }

  // Icon mode settings
  NHeader {
    visible: valueDisplayMode === "icon"
    text: "Icon Settings"
  }

  NToggle {
    visible: valueDisplayMode === "icon"
    label: "Use distro logo instead of icon"
    description: "Use your distribution's logo instead of a custom icon."
    checked: valueUseDistroLogo
    onToggled: checked => {
                 valueUseDistroLogo = checked;
                 saveSettings();
               }
  }

  NToggle {
    visible: valueDisplayMode === "icon"
    label: "Enable colorization"
    description: "Enable colorization for icon, applying theme colors."
    checked: valueEnableColorization
    onToggled: checked => {
                 valueEnableColorization = checked;
                 saveSettings();
               }
  }

  NColorChoice {
    visible: valueDisplayMode === "icon" && valueEnableColorization
    label: "Select icon color"
    description: "Apply theme colors to icons."
    currentKey: valueColorizeSystemIcon
    onSelected: function (key) {
      valueColorizeSystemIcon = key;
      saveSettings();
    }
  }

  RowLayout {
    visible: valueDisplayMode === "icon"
    spacing: Style.marginM

    NLabel {
      label: "Icon"
      description: "Select an icon from the library or a custom file."
    }

    NImageRounded {
      Layout.preferredWidth: Style.fontSizeXL * 2
      Layout.preferredHeight: Style.fontSizeXL * 2
      Layout.alignment: Qt.AlignVCenter
      radius: Math.min(Style.radiusL, Layout.preferredWidth / 2)
      imagePath: valueCustomIconPath
      visible: valueCustomIconPath !== "" && !valueUseDistroLogo
    }

    NIcon {
      Layout.alignment: Qt.AlignVCenter
      icon: valueIcon
      pointSize: Style.fontSizeXXL * 1.5
      visible: valueIcon !== "" && valueCustomIconPath === "" && !valueUseDistroLogo
    }
  }

  RowLayout {
    visible: valueDisplayMode === "icon"
    spacing: Style.marginM
    NButton {
      enabled: !valueUseDistroLogo
      text: "Browse Library"
      onClicked: iconPicker.open()
    }

    NButton {
      enabled: !valueUseDistroLogo
      text: "Browse File"
      onClicked: imagePicker.openFilePicker()
    }
  }

  NIconPicker {
    id: iconPicker
    initialIcon: valueIcon
    onIconSelected: iconName => {
                      valueIcon = iconName;
                      valueCustomIconPath = "";
                      saveSettings();
                    }
  }

  NFilePicker {
    id: imagePicker
    title: "Select a custom icon"
    selectionMode: "files"
    nameFilters: ImageCacheService.basicImageFilters.concat(["*.svg"])
    initialPath: Quickshell.env("HOME")
    onAccepted: paths => {
                  if (paths.length > 0) {
                    valueCustomIconPath = paths[0]; // Use first selected file
                    saveSettings();
                  }
                }
  }
}
