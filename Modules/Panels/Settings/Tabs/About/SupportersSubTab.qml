import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  spacing: Style.marginL

  NHeader {
    description: "Supporter feature has been removed"
  }

  NButton {
    Layout.alignment: Qt.AlignHCenter
    icon: "heart"
    text: "Become a supporter"
    outlined: true
    onClicked: {
      Quickshell.execDetached(["xdg-open", "https://buymeacoffee.com/nocturnal"]);
    }
  }
}
