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

    function computeDetails() {
        var dep = airportSelector.departure
        var arr = airportSelector.arrival
        var ac = airportSelector.aircraft
        if (dep === "" || arr === "" || ac === "") {
            routeDetails.clear()
            return
        }
        var coord1 = airportModel.coordinateFromIATA(dep)
        var coord2 = airportModel.coordinateFromIATA(arr)
        var d = gcgeneratorModel.calculateRouteDetails(coord1, coord2, ac)
        routeDetails.applyDetails(d)
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
        onCalculate: computeDetails()
    }

    RouteDetails {
        id: routeDetails
        anchors.top: airportSelector.bottom
        anchors.topMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 16
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
