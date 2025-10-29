import QtQuick 2.15
import "../Dashboard"
import "../ParkAssist"

Rectangle {
    id: leftScreen
    anchors {
	left: parent.left
	right: rightScreen.left
	bottom: bottomBar.top
	top: parent.top
    }

    color: "white"
    
    property bool parkAssistVisible: false

    // Upper section - Car render or Park Assist
    Rectangle {
        id: upperSection
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: parent.height * 0.485
        color: "white"

        Image {
            id: carRender
            source: "qrc:/images/carRender.png"
            anchors.centerIn: parent
            width: parent.width * 0.7
            fillMode: Image.PreserveAspectFit
            visible: !parkAssistVisible
        }
        
        ParkAssistComponent {
            id: parkAssistComponent
            anchors.fill: parent
            anchors.margins: 10
            visible: parkAssistVisible
        }
        
        // Minimize button for Park Assist
        Rectangle {
            visible: parkAssistVisible
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 15
            anchors.rightMargin: 15
            width: 25
            height: 25
            radius: 12
            color: "#ff4444"
            
            Text {
                anchors.centerIn: parent
                text: "×"
                color: "white"
                font.pixelSize: 14
                font.bold: true
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    parkAssistVisible = false
                }
            }
        }
    }

    // Lower section - Vehicle Dashboard
    Rectangle {
        id: lowerSection
        anchors {
            left: parent.left
            right: parent.right
            top: upperSection.bottom
            bottom: parent.bottom
        }
        color: "white"

        VehicleDashboard {
            anchors.fill: parent
            anchors.margins: 5
        }
    }
    
    function showParkAssist() {
        parkAssistVisible = true
    }
    
    function hideParkAssist() {
        parkAssistVisible = false
    }
}
