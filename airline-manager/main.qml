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

    function updateRoute() {
        var dep = airportSelector.departure
        var arr = airportSelector.arrival
        if (dep !== "" && arr !== "") {
            var coord1 = airportModel.coordinateFromIATA(dep)
            var coord2 = airportModel.coordinateFromIATA(arr)
            worldMap.routePath = gcgeneratorModel.calculatePath(coord1, coord2, 100)
        } else {
            worldMap.routePath = []
        }
    }

    AirportSelector {
        id: airportSelector
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 16
        onArrivalChanged: {
            worldMap.iataFilter = arrival !== "" ? [departure, arrival] : []
            updateRoute()
        }
        onDepartureChanged: {
            worldMap.iataFilter = departure !== "" ? [departure, arrival] : []
            updateRoute()
        }
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