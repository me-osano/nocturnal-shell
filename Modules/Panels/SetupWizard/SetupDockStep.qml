import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Compositor
import qs.Widgets

ColumnLayout {
  id: root

  spacing: Style.marginM

  // Header
  RowLayout {
    Layout.fillWidth: true
    Layout.bottomMargin: Style.marginL
    spacing: Style.marginM

    Rectangle {
      width: 40
      height: 40
      radius: Style.radiusL
      color: Color.mSurfaceVariant
      opacity: 0.6

      NIcon {
        icon: "device-desktop"
        pointSize: Style.fontSizeL
        color: Color.mPrimary
        anchors.centerIn: parent
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginXS

      NText {
        text: "Dock" || "Dock"
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mPrimary
      }

      NText {
        text: "Show dock on specific monitors. Defaults to all if none are chosen."
        pointSize: Style.fontSizeM
        color: Color.mOnSurfaceVariant
      }
    }
  }

  // Options
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginL

    NToggle {
      Layout.fillWidth: true
      label: "Enable dock"
      description: "Show or hide the dock entirely."
      checked: Settings.data.dock.enabled
      onToggled: checked => Settings.data.dock.enabled = checked
    }

    // Display behavior
    NComboBox {
      visible: Settings.data.dock.enabled
      Layout.fillWidth: true
      label: "Display"
      description: "Choose how the dock behaves."
      model: [
        {
          "key": "always_visible",
          "name": "Always visible"
        },
        {
          "key": "auto_hide",
          "name": "Auto hide"
        },
        {
          "key": "exclusive",
          "name": "Exclusive"
        }
      ]
      currentKey: Settings.data.dock.displayMode
      onSelected: key => Settings.data.dock.displayMode = key
    }

    // Background opacity
    ColumnLayout {
      visible: Settings.data.dock.enabled
      spacing: Style.marginXXS
      Layout.fillWidth: true
      NLabel {
        label: "Background opacity"
        description: "Adjust the dock's background opacity."
      }
      NValueSlider {
        Layout.fillWidth: true
        from: 0
        to: 1
        stepSize: 0.01
        value: Settings.data.dock.backgroundOpacity
        onMoved: value => Settings.data.dock.backgroundOpacity = value
        text: Math.floor(Settings.data.dock.backgroundOpacity * 100) + "%"
      }
    }

    // Floating distance
    ColumnLayout {
      visible: Settings.data.dock.enabled
      spacing: Style.marginXXS
      Layout.fillWidth: true
      NLabel {
        label: "Dock floating distance"
        description: "Set the distance between the dock and the edge of the screen."
      }
      NValueSlider {
        Layout.fillWidth: true
        from: 0
        to: 4
        stepSize: 0.01
        value: Settings.data.dock.floatingRatio
        onMoved: value => Settings.data.dock.floatingRatio = value
        text: Math.floor(Settings.data.dock.floatingRatio * 100) + "%"
      }
    }

    // Icon size
    ColumnLayout {
      visible: Settings.data.dock.enabled
      spacing: Style.marginXXS
      Layout.fillWidth: true
      NLabel {
        label: "Dock size"
        description: "Adjust the overall size of the dock."
      }
      NValueSlider {
        Layout.fillWidth: true
        from: 0
        to: 2
        stepSize: 0.01
        value: Settings.data.dock.size
        onMoved: value => Settings.data.dock.size = value
        text: Math.floor(Settings.data.dock.size * 100) + "%"
      }
    }

    NToggle {
      visible: Settings.data.dock.enabled
      Layout.fillWidth: true
      label: "Only apps from same monitor"
      description: "Show only apps from the monitor where the dock is located."
      checked: Settings.data.dock.onlySameOutput
      onToggled: checked => Settings.data.dock.onlySameOutput = checked
    }

    NToggle {
      visible: Settings.data.dock.enabled
      Layout.fillWidth: true
      label: "Colorize icons"
      description: "Apply theme colors to dock app icons (non-focused apps only)."
      checked: Settings.data.dock.colorizeIcons
      onToggled: checked => Settings.data.dock.colorizeIcons = checked
    }

    NHeader {
      visible: Settings.data.dock.enabled
      label: "Monitor display"
      description: "Show dock on specific monitors. Defaults to all if none are chosen."
    }

    Repeater {
      visible: Settings.data.dock.enabled
      model: Quickshell.screens || []
      delegate: NCheckbox {
        Layout.fillWidth: true
        label: modelData.name || "Unknown"
        visible: Settings.data.dock.enabled
        description: {
          const compositorScale = CompositorService.getDisplayScale(modelData.name);
          "{model} ({width}x{height} @ {scale}x)";
        }
        checked: (Settings.data.dock.monitors || []).indexOf(modelData.name) !== -1
        onToggled: checked => {
                     if (checked) {
                       const arr = (Settings.data.dock.monitors || []).slice();
                       if (arr.indexOf(modelData.name) === -1)
                       arr.push(modelData.name);
                       Settings.data.dock.monitors = arr;
                     } else {
                       Settings.data.dock.monitors = (Settings.data.dock.monitors || []).filter(function (n) {
                         return n !== modelData.name;
                       });
                     }
                   }
      }
    }
  }
}
