import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Modules.OSD
import qs.Widgets

ColumnLayout {
  id: root
  spacing: Style.marginL
  Layout.fillWidth: true

  property var addType
  property var removeType

  Repeater {
    model: [
      {
        type: OSD.Type.Volume,
        key: "types-volume"
      },
      {
        type: OSD.Type.InputVolume,
        key: "types-input-volume"
      },
      {
        type: OSD.Type.Brightness,
        key: "types-brightness"
      },
      {
        type: OSD.Type.LockKey,
        key: "types-lockkey"
      }
    ]
    delegate: NCheckbox {
      required property var modelData
      Layout.fillWidth: true
      function humanizeKey(key) {
        if (!key) return "";
        var s = key.replace(/^.*\./, "");
        s = s.replace(/[-_]/g, " ");
        s = s.replace(/\b\w/g, function(m) { return m.toUpperCase(); });
        return s;
      }

      label: humanizeKey("panels.osd." + modelData.key + "-label")
      description: humanizeKey("panels.osd." + modelData.key + "-description")
      checked: (Settings.data.osd.enabledTypes || []).includes(modelData.type)
      onToggled: checked => {
                   if (checked) {
                     Settings.data.osd.enabledTypes = root.addType(Settings.data.osd.enabledTypes, modelData.type);
                   } else {
                     Settings.data.osd.enabledTypes = root.removeType(Settings.data.osd.enabledTypes, modelData.type);
                   }
                 }
    }
  }
}
