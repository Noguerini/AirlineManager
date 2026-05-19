import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls

Rectangle {
    id: rootItem

    width: 300
    height: 330
    color: "#ffffff"
    opacity: 0.97
    border.color: "#d0d7de"
    border.width: 1
    radius: 12

    property var airports: []
    property string departure: ""
    property string arrival: ""
    property string aircraft: ""

    signal calculate()

    Component.onCompleted: {
        airports = airportModel.allIataCodes()
        var planes = gcgeneratorModel.availableAircraft()
        aircraftCombo.model = planes
        if (planes.length > 0) {
            aircraftCombo.currentIndex = 0
            rootItem.aircraft = planes[0]
        }
    }

    function suggestionsFor(text) {
        if (text.length === 0) return []
        return airports.filter(a => a.toLowerCase().startsWith(text.toLowerCase()))
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {forceActiveFocus()}
        onWheel: function(wheel) { wheel.accepted = true }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Text {
            text: qsTr("Flight Route")
            font.pixelSize: 14
            font.bold: true
            color: "#1f2328"
        }

        // ----- Departure -----
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: qsTr("From")
                font.pixelSize: 11
                color: "#656d76"
            }

            Rectangle {
                id: departureBox
                width: parent.width
                height: 36
                radius: 6
                color: "#f6f8fa"
                border.color: departureInput.activeFocus ? "#0969da" : "#d0d7de"
                border.width: 1

                property var suggestions: []

                TextField {
                    id: departureInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    placeholderText: qsTr("Departure IATA")
                    background: Item {}
                    font.pixelSize: 13
                    color: "#1f2328"
                    onTextChanged: departureBox.suggestions = rootItem.suggestionsFor(text)
                }

                Popup {
                    y: departureBox.height + 2
                    width: departureBox.width
                    height: Math.min(departureBox.suggestions.length * 32, 160)
                    visible: departureBox.suggestions.length > 0
                    padding: 0

                    background: Rectangle {
                        color: "white"
                        border.color: "#d0d7de"
                        border.width: 1
                        radius: 6
                    }

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        model: departureBox.suggestions
                        clip: true

                        delegate: ItemDelegate {
                            width: ListView.view.width
                            height: 32
                            text: modelData
                            font.pixelSize: 13
                            onClicked: {
                                departureInput.text = modelData
                                rootItem.departure = modelData
                                departureBox.suggestions = []
                            }
                        }
                    }
                }
            }
        }

        // ----- Arrival -----
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: qsTr("To")
                font.pixelSize: 11
                color: "#656d76"
            }

            Rectangle {
                id: arrivalBox
                width: parent.width
                height: 36
                radius: 6
                color: "#f6f8fa"
                border.color: arrivalInput.activeFocus ? "#0969da" : "#d0d7de"
                border.width: 1

                property var suggestions: []

                TextField {
                    id: arrivalInput
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    placeholderText: qsTr("Arrival IATA")
                    background: Item {}
                    font.pixelSize: 13
                    color: "#1f2328"
                    onTextChanged: arrivalBox.suggestions = rootItem.suggestionsFor(text)
                }

                Popup {
                    y: arrivalBox.height + 2
                    width: arrivalBox.width
                    height: Math.min(arrivalBox.suggestions.length * 32, 160)
                    visible: arrivalBox.suggestions.length > 0
                    padding: 0

                    background: Rectangle {
                        color: "white"
                        border.color: "#d0d7de"
                        border.width: 1
                        radius: 6
                    }

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 1
                        model: arrivalBox.suggestions
                        clip: true

                        delegate: ItemDelegate {
                            width: ListView.view.width
                            height: 32
                            text: modelData
                            font.pixelSize: 13
                            onClicked: {
                                arrivalInput.text = modelData
                                rootItem.arrival = modelData
                                arrivalBox.suggestions = []
                            }
                        }
                    }
                }
            }
        }

        // ----- Aircraft -----
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: qsTr("Aircraft")
                font.pixelSize: 11
                color: "#656d76"
            }

            ComboBox {
                id: aircraftCombo
                width: parent.width
                height: 36
                font.pixelSize: 13
                onCurrentTextChanged: rootItem.aircraft = currentText
            }
        }

        // ----- Calculate -----
        Item {
            width: parent.width
            height: 40
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100
                height: parent.height
                background: Rectangle {
                    color: "#0969da"
                    radius: 8
                }
                contentItem: Text {
                    text: "Calculate"
                    color: "white"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: rootItem.calculate()
            }
        }
    }
}
