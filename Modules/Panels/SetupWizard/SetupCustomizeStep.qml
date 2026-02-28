import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property real selectedScaleRatio: 1.0
  property string selectedBarPosition: "top"

  signal scaleRatioChanged(real ratio)
  signal barPositionChanged(string position)

  spacing: Style.marginM

  // Beautiful header with icon
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
        icon: "palette"
        pointSize: Style.fontSizeL
        color: Color.mPrimary
        anchors.centerIn: parent
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: Style.marginXS

      NText {
        text: "Customize your experience"
        pointSize: Style.fontSizeXL
        font.weight: Style.fontWeightBold
        color: Color.mPrimary
      }

      NText {
        text: "Adjust bar position, density, scaling and more."
        pointSize: Style.fontSizeM
        color: Color.mOnSurfaceVariant
      }
    }
  }

  NScrollView {
    id: customizeScrollView
    Layout.fillWidth: true
    Layout.fillHeight: true
    horizontalPolicy: ScrollBar.AlwaysOff
    verticalPolicy: ScrollBar.AsNeeded

    ColumnLayout {
      width: customizeScrollView.availableWidth
      spacing: Style.marginM

      // Bar Position section
      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.marginS

          Rectangle {
            width: 28
            height: 28
            radius: Style.radiusM
            color: Color.mSurface

            NIcon {
              icon: "layout-2"
              pointSize: Style.fontSizeL
              color: Color.mPrimary
              anchors.centerIn: parent
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            NText {
              text: "Bar position"
              pointSize: Style.fontSizeL
              font.weight: Style.fontWeightBold
              color: Color.mOnSurface
            }

            NText {
              text: "Choose where to place the bar on the screen."
              pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.marginS

          Repeater {
            model: [
              {
                "key": "top",
                "name": "Top",
                "icon": "arrow-up"
              },
              {
                "key": "bottom",
                "name": "Bottom",
                "icon": "arrow-down"
              },
              {
                "key": "left",
                "name": "Left",
                "icon": "arrow-left"
              },
              {
                "key": "right",
                "name": "Right",
                "icon": "arrow-right"
              }
            ]
            delegate: Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 40
              radius: Style.radiusM
              border.width: Style.borderS

              property bool isActive: selectedBarPosition === modelData.key

              color: (hoverHandler.hovered || isActive) ? Color.mPrimary : Color.mSurfaceVariant
              border.color: (hoverHandler.hovered || isActive) ? Color.mPrimary : Color.mOutline
              opacity: (hoverHandler.hovered || isActive) ? 1.0 : 0.8

              NText {
                text: modelData.name
                pointSize: Style.fontSizeM
                font.weight: (hoverHandler.hovered || parent.isActive) ? Style.fontWeightBold : Style.fontWeightMedium
                color: (hoverHandler.hovered || parent.isActive) ? Color.mOnPrimary : Color.mOnSurface
                anchors.centerIn: parent
              }

              HoverHandler {
                id: hoverHandler
              }
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  selectedBarPosition = modelData.key;
                  barPositionChanged(modelData.key);
                }
              }

              Behavior on color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
              Behavior on border.color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
              Behavior on opacity {
                NumberAnimation {
                  duration: Style.animationFast
                }
              }
            }
          }
        }
      }

      // Divider
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Color.mOutline
        opacity: 0.2
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
      }

      // Bar Density section
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        Rectangle {
          width: 32
          height: 32
          radius: Style.radiusM
          color: Color.mSurface
          NIcon {
            icon: "minimize"
            pointSize: Style.fontSizeL
            color: Color.mPrimary
            anchors.centerIn: parent
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 2
          NText {
            text: "Bar density"
            pointSize: Style.fontSizeL
            font.weight: Style.fontWeightBold
            color: Color.mOnSurface
          }
          NText {
            text: "Adjust the bar's padding for a compact or spacious look."
            pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
          }
        }

        RowLayout {
          spacing: Style.marginS
          Repeater {
            model: [
              {
                "key": "mini",
                "name": "Mini"
              },
              {
                "key": "compact",
                "name": "Compact"
              },
              {
                "key": "default",
                "name": "Default"
              },
              {
                "key": "comfortable",
                "name": "Comfortable"
              },
              {
                "key": "spacious",
                "name": "Spacious"
              }
            ]
            delegate: Rectangle {
              radius: Style.radiusM
              border.width: Style.borderS
              Layout.preferredHeight: 32
              Layout.preferredWidth: Math.max(90, densityText.implicitWidth + Style.margin2XL)

              property bool isActive: Settings.data.bar.density === modelData.key

              color: (hoverHandler.hovered || isActive) ? Color.mPrimary : Color.mSurfaceVariant
              border.color: (hoverHandler.hovered || isActive) ? Color.mPrimary : Color.mOutline
              opacity: (hoverHandler.hovered || isActive) ? 1.0 : 0.8

              NText {
                id: densityText
                text: modelData.name
                pointSize: Style.fontSizeS
                font.weight: (hoverHandler.hovered || parent.isActive) ? Style.fontWeightBold : Style.fontWeightMedium
                color: (hoverHandler.hovered || parent.isActive) ? Color.mOnPrimary : Color.mOnSurface
                anchors.centerIn: parent
              }

              HoverHandler {
                id: hoverHandler
              }
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Settings.data.bar.density = modelData.key;
                }
              }

              Behavior on color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
              Behavior on border.color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
              Behavior on opacity {
                NumberAnimation {
                  duration: Style.animationFast
                }
              }
            }
          }
        }
      }

      // Divider
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Color.mOutline
        opacity: 0.2
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
      }

      // UI Scale section
      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.marginS
          Rectangle {
            width: 32
            height: 32
            radius: Style.radiusM
            color: Color.mSurface
            NIcon {
              icon: "maximize"
              pointSize: Style.fontSizeL
              color: Color.mPrimary
              anchors.centerIn: parent
            }
          }
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            NText {
              text: "Interface scaling"
              pointSize: Style.fontSizeL
              font.weight: Style.fontWeightBold
              color: Color.mOnSurface
            }
            NText {
              text: "Changes the size of the general user interface, excluding the bar."
              pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
            }
          }
        }

        NValueSlider {
          Layout.fillWidth: true
          from: 0.8
          to: 1.2
          stepSize: 0.05
          value: selectedScaleRatio
          onMoved: function (value) {
            selectedScaleRatio = value;
            scaleRatioChanged(value);
          }
          text: Math.floor(selectedScaleRatio * 100) + "%"
        }
      }

      // Divider
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Color.mOutline
        opacity: 0.2
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
      }

      // Bar Type section
      ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.marginS

          Rectangle {
            width: 28
            height: 28
            radius: Style.radiusM
            color: Color.mSurface

            NIcon {
              icon: "layout-2"
              pointSize: Style.fontSizeL
              color: Color.mPrimary
              anchors.centerIn: parent
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            NText {
              text: "Bar type" ?? "Bar Type"
              pointSize: Style.fontSizeL
              font.weight: Style.fontWeightBold
              color: Color.mOnSurface
            }

            NText {
              text: "Choose the style of the bar: Simple, Floating or Framed." ?? "Choose the style of the bar: Simple, Floating or Framed"
              pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.marginS

          Repeater {
            model: [
              {
                "key": "simple",
                "name": "Simple" ?? "Simple"
              },
              {
                "key": "floating",
                "name": "Floating" ?? "Floating"
              },
              {
                "key": "framed",
                "name": "Framed" ?? "Framed"
              }
            ]
            delegate: Rectangle {
              Layout.fillWidth: true
              Layout.preferredHeight: 40
              radius: Style.radiusM
              border.width: Style.borderS

              property bool isActive: Settings.data.bar.barType === modelData.key

              color: (hoverHandler.hovered || isActive) ? Color.mPrimary : Color.mSurfaceVariant
              border.color: (hoverHandler.hovered || isActive) ? Color.mPrimary : Color.mOutline
              opacity: (hoverHandler.hovered || isActive) ? 1.0 : 0.8

              NText {
                text: modelData.name
                pointSize: Style.fontSizeM
                font.weight: (hoverHandler.hovered || parent.isActive) ? Style.fontWeightBold : Style.fontWeightMedium
                color: (hoverHandler.hovered || parent.isActive) ? Color.mOnPrimary : Color.mOnSurface
                anchors.centerIn: parent
              }

              HoverHandler {
                id: hoverHandler
              }
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Settings.data.bar.barType = modelData.key;
                  Settings.data.bar.floating = (modelData.key === "floating");
                }
              }

              Behavior on color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
              Behavior on border.color {
                ColorAnimation {
                  duration: Style.animationFast
                }
              }
              Behavior on opacity {
                NumberAnimation {
                  duration: Style.animationFast
                }
              }
            }
          }
        }
      }

      // Divider
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Color.mOutline
        opacity: 0.2
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
      }

      // Divider
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Color.mOutline
        opacity: 0.2
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
      }

      // Dim Desktop opacity
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        Rectangle {
          width: 32
          height: 32
          radius: Style.radiusM
          color: Color.mSurface
          NIcon {
            icon: "screen-share"
            pointSize: Style.fontSizeL
            color: Color.mPrimary
            anchors.centerIn: parent
          }
        }
        ColumnLayout {
          Layout.fillWidth: true
          spacing: 2
          NText {
            text: "Dimmed desktop opacity"
            pointSize: Style.fontSizeL
            font.weight: Style.fontWeightBold
            color: Color.mOnSurface
          }
          NText {
            text: "Set the opacity level for desktop dimming."
            pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
          }
          NValueSlider {
            Layout.fillWidth: true
            Layout.topMargin: Style.marginXS
            from: 0
            to: 1
            stepSize: 0.01
            value: Settings.data.general.dimmerOpacity
            onMoved: value => Settings.data.general.dimmerOpacity = value
            text: Math.floor(Settings.data.general.dimmerOpacity * 100) + "%"
          }
        }
      }

      // Divider
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Color.mOutline
        opacity: 0.2
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
      }

      // Drop Shadows toggle
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM
        Rectangle {
          width: 32
          height: 32
          radius: Style.radiusM
          color: Color.mSurface
          NIcon {
            icon: "shadow"
            pointSize: Style.fontSizeL
            color: Color.mPrimary
            anchors.centerIn: parent
          }
        }
        ColumnLayout {
          Layout.fillWidth: true
          spacing: 2
          NText {
            text: "Drop shadows"
            pointSize: Style.fontSizeL
            font.weight: Style.fontWeightBold
            color: Color.mOnSurface
          }
          NText {
            text: "Enables drop shadows under bars and panels."
            pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
          }
        }
        NToggle {
          checked: Settings.data.general.enableShadows
          onToggled: checked => Settings.data.general.enableShadows = checked
        }
      }

      Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Style.marginL
      }
    }
  }
}
