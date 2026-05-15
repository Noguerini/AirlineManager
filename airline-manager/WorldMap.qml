import QtLocation
import QtPositioning
import QtQuick

Map {
	anchors.fill:parent
    id: map
    plugin: Plugin {
		name: "osm"
		PluginParameter {
			name: "osm.mapping.custom.host"
			value: "https://tile.openstreetmap.org/"
		}
		PluginParameter {
			name: "osm.mapping.providersrepository.disabled"
			value: "true"
		}
		PluginParameter { name: "osm.mapping.cache.disk.size"; value: 500000000 }   // 500 MB
		PluginParameter { name: "osm.mapping.cache.memory.size"; value: 100000000 }
    }
	center: QtPositioning.coordinate(0, 0)
	zoomLevel: 0

	activeMapType: {
		for (let i = 0; i < supportedMapTypes.length; i++) {
			if (supportedMapTypes[i].name.indexOf("Custom") !== -1)
				return supportedMapTypes[i]
		}
		return supportedMapTypes[0]
	}

	MapItemView {
		model: airportModel
		delegate: MapQuickItem {
			coordinate: model.coordinate
			anchorPoint.x: 6
			anchorPoint.y: 6
			sourceItem: Row {
				spacing: 4
				Rectangle {
					width: 12; height: 12; radius: 6
					color: "red"
					border.color: "white"; border.width: 2
				}
				Text {
					text: model.iata
					color: "black"
					font.pixelSize: 11
					font.bold: true
					anchors.verticalCenter: parent.verticalCenter
				}
			}
		}
	}

	DragHandler {
		property real lastX: 0
		property real lastY: 0

		onActiveChanged: {
			if (active) {
				lastX = centroid.position.x
				lastY = centroid.position.y
			}
		}

		onCentroidChanged: {
			if (active) {
				let dx = centroid.position.x - lastX
				let dy = centroid.position.y - lastY
				
				parent.pan(-dx, -dy)

				lastX = centroid.position.x
				lastY = centroid.position.y
			}
		}
	}
	
	WheelHandler  {
		onWheel: function(event) {
	        let mousePos = Qt.point(event.x, event.y)
	        let coordBefore = parent.toCoordinate(mousePos)
			let delta = event.angleDelta.y / 120
			
			parent.zoomLevel += delta*0.2

	        let pixelAfter = parent.fromCoordinate(coordBefore, false)
	        parent.pan(pixelAfter.x - mousePos.x, pixelAfter.y - mousePos.y)
		}
	}
	
		
}