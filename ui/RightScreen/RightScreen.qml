import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import "../MusicPlayer"
import "../Phone"
import "."

Rectangle {
    id: rightScreen

    anchors {
	top: parent.top
	bottom: bottomBar.top
	right: parent.right
    }
    
    property string currentContent: "map" // "map", "music", "phone"

    Plugin {
	id: mapPlugin
	name: "mapboxgl"
    }
    
    StatusBar {
        id: statusBar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    // Map view (default)
    Rectangle {
        id: mapContainer
        anchors {
            top: statusBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        visible: currentContent === "map"
        
        Map {
            anchors.fill: parent
            plugin: mapPlugin
            center: QtPositioning.coordinate(59.91, 10.76) //Oslo
            zoomLevel: 14
        }

        NavigationSearchBox {
            id: navSearchBox
            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 20
                topMargin: 15
            }
            width: parent.width / 3
            height: parent.height / 14
        }
    }
    
    // Music Player view
    Rectangle {
        id: musicContainer
        anchors.fill: parent
        visible: currentContent === "music"
        color: "black"
        
        MusicPlayerComponent {
            anchors.fill: parent
            anchors.margins: 20
        }
        
        // Minimize button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 15
            anchors.rightMargin: 15
            width: 30
            height: 30
            radius: 15
            color: "#444444"
            
            Text {
                anchors.centerIn: parent
                text: "−"
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentContent = "map"
                }
            }
        }
    }
    
    // Phone view
    Rectangle {
        id: phoneContainer
        anchors.fill: parent
        visible: currentContent === "phone"
        color: "black"
        
        PhoneInterface {
            anchors.fill: parent
            anchors.margins: 20
        }
        
        // Minimize button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 15
            anchors.rightMargin: 15
            width: 30
            height: 30
            radius: 15
            color: "#444444"
            
            Text {
                anchors.centerIn: parent
                text: "−"
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentContent = "map"
                }
            }
        }
    }
    
    width: parent.width * 1.68/3    // this sets width ratio for right/left screen
    
    function showMap() {
        currentContent = "map"
    }
    
    function showMusic() {
        currentContent = "music"
    }
    
    function showPhone() {
        currentContent = "phone"
    }
}
