import QtQuick 2.9
import QtQuick.Window 2.2
import QtPositioning


Window {
    id: root
    visible: true
    width: 1920
    height: 1080
    title: "Airline Manager"

    property bool isFullScreen: false

    visibility: isFullScreen ? Window.FullScreen : Window.Windowed

    WorldMap {
        id: worldMap
        anchors.fill: parent     
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_F11) {
                root.isFullScreen = !root.isFullScreen
                event.accepted = true
            }
            if (event.key === Qt.Key_Space) {
                worldMap.center = QtPositioning.coordinate(0,0)
                worldMap.zoomLevel = 2.1
                event.accepted = true
            }
        }
    }
}