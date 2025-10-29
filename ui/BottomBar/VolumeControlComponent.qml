import QtQuick 2.15

Rectangle {
    id: volumeControlComponent
    color: "transparent"
    
    property string fontColor: "#737373"
    
    // Width is calculated based on the content and will be set by the parent
    width: 120 * parent.width / 1280 // Responsive width based on screen size
    
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
            onClicked: audioController.incrementVolume(-1)
        }
    }
    
    Image {
        id: volumeIcon
        anchors {
            left: decrementButton.right
            leftMargin: 20
            verticalCenter: parent.verticalCenter
        }
        
        height: parent.height * 0.6
        fillMode: Image.PreserveAspectFit
        
        source: {
            if (audioController.volumeLevel <= 0) {
                return "qrc:/images/volume-mute.png"
            } else if (audioController.volumeLevel <= 1) {
                return "qrc:/images/volume-zero.png"
            } else if (audioController.volumeLevel <= 50) {
                return "qrc:/images/volume-up.png"
            } else {
                return "qrc:/images/volume-max.png"
            }
        }
    }
    
    Text {
        id: volumeTextLabel
        anchors.centerIn: volumeIcon
        text: audioController.volumeLevel
        font.pixelSize: 40
        color: fontColor
        visible: !volumeIcon.visible
    }
    
    Rectangle {
        id: incrementButton
        anchors {
            left: volumeIcon.right
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
            onClicked: audioController.incrementVolume(1)
        }
    }
    
    Timer {
        id: visibleTimer
        interval: 1000
        repeat: false
        onTriggered: {
            volumeIcon.visible = true
            volumeTextLabel.visible = !volumeIcon.visible
        }
    }
    
    Connections {
        target: audioController
        function onVolumeLevelChanged() {
            volumeIcon.visible = false
            volumeTextLabel.visible = !volumeIcon.visible
            visibleTimer.stop()
            visibleTimer.start()
        }
    }
}
