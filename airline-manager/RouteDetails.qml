import QtQuick 2.9

Rectangle {
    id: rootItem

    width: 320
    height: 470
    color: "#ffffff"
    opacity: 0.97
    border.color: "#d0d7de"
    border.width: 1
    radius: 12

    property real total_time: 0
    property real distance: 0
    property real fuel_quantity: 0
    property real fuel_cost: 0
    property real emissions: 0
    property real navigation_services_cost: 0
    property real crew_cost: 0

    property real revenue: 0
    property real cost: 0
    property real profit: 0

    property string aircraft: ""
    property int passengers: 0
    property bool inRange: true
    property bool hasData: false

    function applyDetails(d) {
        if (!d || d.aircraft === undefined) {
            clear()
            return
        }
        aircraft = d.aircraft
        passengers = d.passengers
        inRange = d.in_range
        distance = d.distance
        total_time = d.total_time
        fuel_quantity = d.fuel_quantity
        fuel_cost = d.fuel_cost
        emissions = d.emissions
        navigation_services_cost = d.navigation_services_cost
        crew_cost = d.crew_cost
        revenue = d.revenue
        cost = d.cost
        profit = d.profit
        hasData = true
    }

    function clear() {
        aircraft = ""
        passengers = 0
        inRange = true
        distance = 0
        total_time = 0
        fuel_quantity = 0
        fuel_cost = 0
        emissions = 0
        navigation_services_cost = 0
        crew_cost = 0
        revenue = 0
        cost = 0
        profit = 0
        hasData = false
    }

    function formatTime(hours) {
        if (!hasData) return "—"
        var h = Math.floor(hours)
        var m = Math.round((hours - h) * 60)
        return h + "h " + (m < 10 ? "0" : "") + m + "m"
    }

    function formatKm(km) {
        if (!hasData) return "—"
        return Math.round(km).toLocaleString(Qt.locale(), 'f', 0) + " km"
    }

    function formatKg(kg) {
        if (!hasData) return "—"
        return Math.round(kg).toLocaleString(Qt.locale(), 'f', 0) + " kg"
    }

    function formatMoney(value) {
        if (!hasData) return "—"
        var sign = value < 0 ? "-" : ""
        var v = Math.abs(value)
        return sign + "$" + Math.round(v).toLocaleString(Qt.locale(), 'f', 0)
    }

    MouseArea {
        anchors.fill: parent
        onPressed: { forceActiveFocus() }
        onWheel: function(wheel) { wheel.accepted = true }
    }

    component MetricRow: Item {
        property string label: ""
        property string value: ""
        property color valueColor: "#1f2328"
        property bool emphasis: false
        width: parent ? parent.width : 0
        height: emphasis ? 22 : 18
        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: parent.label
            color: "#656d76"
            font.pixelSize: parent.emphasis ? 13 : 12
            font.bold: parent.emphasis
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: parent.value
            color: parent.valueColor
            font.pixelSize: parent.emphasis ? 13 : 12
            font.bold: parent.emphasis
        }
    }

    component SectionLabel: Text {
        font.pixelSize: 10
        color: "#656d76"
        font.bold: true
        font.letterSpacing: 0.6
    }

    component Divider: Rectangle {
        width: parent ? parent.width : 0
        height: 1
        color: "#eaeef2"
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 6

        Item {
            width: parent.width
            height: 22
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Route Details")
                font.pixelSize: 14
                font.bold: true
                color: "#1f2328"
            }
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: aircraftLabel.implicitWidth + 16
                height: 20
                radius: 10
                visible: rootItem.aircraft !== ""
                color: rootItem.inRange ? "#dafbe1" : "#ffebe9"
                border.color: rootItem.inRange ? "#1a7f37" : "#cf222e"
                border.width: 1
                Text {
                    id: aircraftLabel
                    anchors.centerIn: parent
                    text: rootItem.aircraft + (rootItem.inRange ? "" : " (out of range)")
                    color: rootItem.inRange ? "#1a7f37" : "#cf222e"
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }

        Rectangle { width: parent.width; height: 1; color: "#d0d7de" }

        SectionLabel { text: qsTr("FLIGHT") }
        MetricRow { label: qsTr("Distance"); value: rootItem.formatKm(rootItem.distance); valueColor: "#1f2328" }
        MetricRow { label: qsTr("Flight Time"); value: rootItem.formatTime(rootItem.total_time); valueColor: "#1f2328" }
        MetricRow { label: qsTr("Passengers"); value: rootItem.hasData ? rootItem.passengers.toString() : "—"; valueColor: "#1f2328" }

        Divider {}

        SectionLabel { text: qsTr("FUEL & EMISSIONS") }
        MetricRow { label: qsTr("Fuel Quantity"); value: rootItem.formatKg(rootItem.fuel_quantity); valueColor: "#1f2328" }
        MetricRow { label: qsTr("Fuel Cost"); value: rootItem.formatMoney(rootItem.fuel_cost); valueColor: "#1f2328" }
        MetricRow { label: qsTr("CO₂ Emissions"); value: rootItem.formatKg(rootItem.emissions); valueColor: "#1f2328" }

        Divider {}

        SectionLabel { text: qsTr("COSTS") }
        MetricRow { label: qsTr("Navigation"); value: rootItem.formatMoney(rootItem.navigation_services_cost); valueColor: "#1f2328" }
        MetricRow { label: qsTr("Crew"); value: rootItem.formatMoney(rootItem.crew_cost); valueColor: "#1f2328" }

        Divider {}

        SectionLabel { text: qsTr("SUMMARY") }
        MetricRow { label: qsTr("Revenue"); value: rootItem.formatMoney(rootItem.revenue); valueColor: "#1a7f37" }
        MetricRow { label: qsTr("Total Cost"); value: rootItem.formatMoney(rootItem.cost); valueColor: "#cf222e" }
        MetricRow {
            label: qsTr("Profit")
            value: rootItem.formatMoney(rootItem.profit)
            valueColor: rootItem.profit >= 0 ? "#1a7f37" : "#cf222e"
            emphasis: true
        }
    }
}
