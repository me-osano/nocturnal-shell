import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services.Power
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL
  Layout.fillWidth: true

  // Master enable
  NToggle {
    Layout.fillWidth: true
    label: "Enable idle management"
    description: "Automatically turn off the screen, lock, or suspend after a period of inactivity."
    checked: Settings.data.idle.enabled
    defaultValue: Settings.getDefaultValue("idle.enabled")
    onToggled: checked => Settings.data.idle.enabled = checked
  }

  // Live idle status
  RowLayout {
    Layout.fillWidth: true
    enabled: Settings.data.idle.enabled
    visible: IdleService.nativeIdleMonitorAvailable

    NLabel {
      label: "Idle time"
      description: "Idle time as reported by the compositor."
    }

    Item {
      Layout.fillWidth: true
    }

    NText {
      Layout.alignment: Qt.AlignBottom | Qt.AlignRight
      text: IdleService.idleSeconds > 0 ? ((IdleService.idleSeconds) == 1 ? "{count} second" : "{count} seconds") : "Active"
      family: Settings.data.ui.fontFixed
      pointSize: Style.fontSizeM
      color: IdleService.idleSeconds > 0 ? Color.mPrimary : Color.mOnSurfaceVariant
    }
  }

  NLabel {
    visible: !IdleService.nativeIdleMonitorAvailable
    description: "Native idle monitoring is not available on this compositor."
  }

  NDivider {
    Layout.fillWidth: true
  }

  // Timeout spinboxes (disabled when idle is off)
  ColumnLayout {
    Layout.fillWidth: true
    spacing: Style.marginL
    enabled: Settings.data.idle.enabled

    NLabel {
      label: "Timeouts"
      description: "Set to 0 to disable a stage. Timeouts are paused while Keep Awake is active."
    }

    NSpinBox {
      label: "Turn off screen"
      description: "Seconds of inactivity before monitors are turned off."
      from: 0
      to: 86400
      suffix: "s"
      value: Settings.data.idle.screenOffTimeout
      defaultValue: 0
      onValueChanged: Settings.data.idle.screenOffTimeout = value
    }

    NSpinBox {
      label: "Lock screen"
      description: "Seconds of inactivity before the lock screen activates."
      from: 0
      to: 86400
      suffix: "s"
      value: Settings.data.idle.lockTimeout
      defaultValue: 0
      onValueChanged: Settings.data.idle.lockTimeout = value
    }

    NSpinBox {
      label: "Suspend"
      description: "Seconds of inactivity before the system suspends."
      from: 0
      to: 86400
      suffix: "s"
      value: Settings.data.idle.suspendTimeout
      defaultValue: 0
      onValueChanged: Settings.data.idle.suspendTimeout = value
    }

    NDivider {
      Layout.fillWidth: true
    }

    NSpinBox {
      label: "Fade duration"
      description: "Seconds for the fade-to-black animation before each action fires. Any mouse movement cancels the fade."
      from: 1
      to: 60
      suffix: "s"
      value: Settings.data.idle.fadeDuration
      defaultValue: Settings.getDefaultValue("idle.fadeDuration")
      onValueChanged: Settings.data.idle.fadeDuration = value
    }
  }
}
