import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    WorldMap { id: worldMap; anchors.fill: parent }

    Rectangle {
        id: airportSelector
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 16
        width: 200
        height: 100
        color: "white"
        opacity: 0.9
        border.color: "#ccc"
        radius: 6
       
        MouseArea {
            anchors.fill: parent
            onPressed: {}
            onWheel: function(wheel) { wheel.accepted = true }
        }

        Text {
            anchors.centerIn: parent
            text: "Legend goes here"
        }
    }
}