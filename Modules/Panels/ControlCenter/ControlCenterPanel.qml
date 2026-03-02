import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Modules.Cards
import qs.Modules.MainScreen
import qs.Services.Media
import qs.Services.UI
import qs.Widgets

SmartPanel {
  id: root

  // Positioning
  readonly property string controlCenterPosition: Settings.data.controlCenter.position

  // Check if there's a bar on this screen
  readonly property bool hasBarOnScreen: {
    var monitors = Settings.data.bar.monitors || [];
    return monitors.length === 0 || monitors.includes(screen?.name);
  }

  // When position is "close_to_bar_button" but there's no bar, fall back to center
  readonly property bool shouldCenter: controlCenterPosition === "close_to_bar_button" && !hasBarOnScreen

  panelAnchorHorizontalCenter: shouldCenter || (controlCenterPosition !== "close_to_bar_button" && (controlCenterPosition.endsWith("_center") || controlCenterPosition === "center"))
  panelAnchorVerticalCenter: shouldCenter || controlCenterPosition === "center"
  panelAnchorLeft: !shouldCenter && controlCenterPosition !== "close_to_bar_button" && controlCenterPosition.endsWith("_left")
  panelAnchorRight: !shouldCenter && controlCenterPosition !== "close_to_bar_button" && controlCenterPosition.endsWith("_right")
  panelAnchorBottom: !shouldCenter && controlCenterPosition !== "close_to_bar_button" && controlCenterPosition.startsWith("bottom_")
  panelAnchorTop: !shouldCenter && controlCenterPosition !== "close_to_bar_button" && controlCenterPosition.startsWith("top_")

  preferredWidth: Math.round(440 * Style.uiScaleRatio)

  // Network inline panel expanded state (shown in shortcuts card)
  property bool networkCardExpanded: false

  // Network inline panel height (dynamic, updated by ShortcutsCard)
  property int networkInlinePanelHeight: 0

  // Notifications card expanded state
  property bool notificationsCardExpanded: true

  readonly property var cardsForRender: {
    const sourceCards = Settings.data.controlCenter.cards || [];
    let cards = [];
    for (var i = 0; i < sourceCards.length; i++) {
      cards.push(sourceCards[i]);
    }

    var notificationsIndex = -1;
    var weatherIndex = -1;
    for (var j = 0; j < cards.length; j++) {
      if (cards[j].id === "notifications-card")
        notificationsIndex = j;
      if (cards[j].id === "weather-card")
        weatherIndex = j;
    }

    if (notificationsIndex === -1) {
      const notificationCard = {
        "enabled": true,
        "id": "notifications-card"
      };
      if (weatherIndex >= 0) {
        cards.splice(weatherIndex, 0, notificationCard);
      } else {
        cards.push(notificationCard);
      }
    } else if (weatherIndex >= 0 && notificationsIndex > weatherIndex) {
      const moved = cards.splice(notificationsIndex, 1)[0];
      cards.splice(weatherIndex, 0, moved);
    }

    return cards;
  }

  preferredHeight: {
    var height = 0;
    var count = 0;
    for (var i = 0; i < cardsForRender.length; i++) {
      const card = cardsForRender[i];
      if (!card.enabled)
        continue;
      const contributes = (card.id !== "weather-card" || Settings.data.location.weatherEnabled);
      if (!contributes)
        continue;
      count++;
      switch (card.id) {
      case "profile-card":
        height += profileHeight;
        break;
      case "shortcuts-card":
        height += shortcutsHeight + (networkCardExpanded ? networkInlinePanelHeight + Style.marginL : 0);
        break;
      case "audio-card":
        height += audioHeight;
        break;
      case "brightness-card":
        height += brightnessHeight;
        break;
      case "notifications-card":
        height += notificationsHeight;
        break;
      case "network-card":
        // Network card is now inline in shortcuts card, skip it
        count--; // Don't count it as a separate card
        break;
      case "weather-card":
        height += weatherHeight;
        break;
      case "media-sysmon-card":
        height += mediaSysMonHeight;
        break;
      default:
        break;
      }
    }
    return height + (count + 1) * Style.marginL;
  }

  readonly property int profileHeight: Math.round(64 * Style.uiScaleRatio)
  readonly property int shortcutsHeight: Math.round(52 * Style.uiScaleRatio)
  readonly property int audioHeight: Math.round(60 * Style.uiScaleRatio)
  readonly property int brightnessHeight: Math.round(60 * Style.uiScaleRatio)
  property int notificationsHeight: Math.round(110 * Style.uiScaleRatio)
  readonly property int mediaSysMonHeight: Math.round(260 * Style.uiScaleRatio)
  readonly property int networkHeight: Math.round(100 * Style.uiScaleRatio)

  // We keep a dynamic weather height due to a more complex layout and font scaling
  property int weatherHeight: Math.round(210 * Style.uiScaleRatio)

  onOpened: {
    MediaService.autoSwitchingPaused = true;
  }

  onClosed: {
    MediaService.autoSwitchingPaused = false;
    // Reset network inline panel state so it's hidden on next open
    networkCardExpanded = false;
    networkInlinePanelHeight = 0;
  }

  panelContent: Item {
    id: panelContent

    ColumnLayout {
      id: layout
      x: Style.marginL
      y: Style.marginL
      width: parent.width - Style.margin2L
      spacing: Style.marginL

      Repeater {
        model: root.cardsForRender
        Loader {
          // Skip network-card as it's now inline in shortcuts card
          active: modelData.enabled && modelData.id !== "network-card" && (modelData.id !== "weather-card" || Settings.data.location.weatherEnabled)
          visible: active
          Layout.fillWidth: true
          Layout.preferredHeight: {
            switch (modelData.id) {
            case "profile-card":
              return profileHeight;
            case "shortcuts-card":
              // Include inline network panel height when expanded
              return shortcutsHeight + (networkCardExpanded ? networkInlinePanelHeight + Style.marginL : 0);
            case "audio-card":
              return audioHeight;
            case "brightness-card":
              return brightnessHeight;
            case "notifications-card":
              // Dynamic height based on expanded state
              return notificationsHeight;
            case "weather-card":
              return weatherHeight;
            case "media-sysmon-card":
              return mediaSysMonHeight;
            default:
              return 0;
            }
          }
          sourceComponent: {
            switch (modelData.id) {
            case "profile-card":
              return profileCard;
            case "shortcuts-card":
              return shortcutsCard;
            case "audio-card":
              return audioCard;
            case "brightness-card":
              return brightnessCard;
            case "notifications-card":
              return notificationsCard;
            case "weather-card":
              return weatherCard;
            case "media-sysmon-card":
              return mediaSysMonCard;
            default:
              return null;
            }
          }
        }
      }
    }

    Component {
      id: profileCard
      ProfileCard {}
    }

    Component {
      id: shortcutsCard
      ShortcutsCard {}
    }

    Component {
      id: audioCard
      AudioCard {}
    }

    Component {
      id: brightnessCard
      BrightnessCard {}
    }

    Component {
      id: notificationsCard
      NotificationsCard {
        screen: root.screen
        expanded: root.notificationsCardExpanded
        onHeightChanged: root.notificationsHeight = this.height
      }
    }

    Component {
      id: networkCard
      NetworkCard {
        screen: root.screen
        expanded: root.networkCardExpanded
        onHeightChanged: root.networkHeight = this.height
      }
    }

    Component {
      id: weatherCard
      WeatherCard {
        Component.onCompleted: {
          root.weatherHeight = this.height;
        }
      }
    }

    Component {
      id: mediaSysMonCard
      RowLayout {
        spacing: Style.marginL

        // Media card
        MediaCard {
          Layout.fillWidth: true
          Layout.fillHeight: true
        }

        // System monitors combined in one card
        SystemMonitorCard {
          Layout.preferredWidth: Math.round(Style.baseWidgetSize * 2.625)
          Layout.fillHeight: true
        }
      }
    }
  }
}
