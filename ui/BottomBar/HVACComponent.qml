import QtQuick 2.15

Rectangle {
    id: hvacComponent
    color: "transparent"
    
    // Property to connect to the appropriate HVAC controller
    property var hvacController
    property string fontColor: "#737373"
    
    // Width is calculated based on the content and will be set by the parent
    width: 100 * parent.width / 1280 // Responsive width based on screen size
    
    Rectangle {
        id: decrementButton
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: height / 2
        color: "black"
        
        Text {
            id: decrementText
            anchors.centerIn: parent
            text: "◀"
            font.pixelSize: 25
            color: fontColor
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: hvacController.incrementTargetTemperature(-1)
        }
    }
    
    Text {
        id: targetTemperatureText
        anchors {
            left: decrementButton.right
            leftMargin: 20
            verticalCenter: parent.verticalCenter
        }
        
        text: hvacController ? hvacController.targetTemperature : "70"
        font.pixelSize: 45
        color: "#ffffff"
    }
    
    Rectangle {
        id: incrementButton
        anchors {
            left: targetTemperatureText.right
            leftMargin: 20
            top: parent.top
            bottom: parent.bottom
        }
        width: height / 2
        color: "black"
        
        Text {
            id: incrementText
            anchors.centerIn: parent
            text: "▶"
            font.pixelSize: 25
            color: fontColor
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: hvacController.incrementTargetTemperature(1)
        }
    }
}
