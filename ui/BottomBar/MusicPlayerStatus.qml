import QtQuick 2.15

Rectangle {
  id: musicStatus
  width: 300
  height: parent.height * 0.7
  anchors.verticalCenter: parent.verticalCenter
  color: "#2a2a2a"
  radius: 4
  border.color: "#444"
  border.width: 1
  visible: mediaController ? mediaController.isPlaying : false
    
  Row {
  anchors.fill: parent
  anchors.margins: 8
  spacing: 10
        
  // Album art thumbnail
  Rectangle {
  id: albumArt
  width: parent.height
  height: parent.height
  color: "#444"
  radius: 2
  anchors.verticalCenter: parent.verticalCenter
            
  Image {
  anchors.centerIn: parent
  width: parent.width * 0.6
  height: parent.height * 0.6
  source: "qrc:/images/musicIcon.png"
  fillMode: Image.PreserveAspectFit
}
}
        
  // Song info
  Column {
  anchors.verticalCenter: parent.verticalCenter
  spacing: 2
  width: parent.width - stopButton.width - albumArt.width - parent.spacing * 2 - parent.anchors.margins * 2
            
  Text {
  text: mediaController ? mediaController.currentTitle : "No Track"
  color: "#ffffff"
  font.pixelSize: 14
  font.bold: true
  elide: Text.ElideRight
  width: parent.width
}
            
  Text {
  text: mediaController ? mediaController.currentArtist : "Unknown Artist"
  color: "#aaa"
  font.pixelSize: 12
  elide: Text.ElideRight
  width: parent.width
}
}
        
  // Stop button
  Rectangle {
  id: stopButton
  width: parent.height * 0.8
  height: parent.height * 0.8
  radius: width / 2
  color: "#ff4444"
  anchors.verticalCenter: parent.verticalCenter
            
  Image {
  anchors.centerIn: parent
  source: "qrc:/images/stop-button.png"
  width: parent.width * 0.4 // relative to button 
  height: parent.height * 0.4
  fillMode: Image.PreserveAspectFit
  smooth: true
}
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
    if (mediaController) {
      mediaController.stop()
    }
  }
                
  onPressed: parent.color = "#cc3333"
  onReleased: parent.color = "#ff4444"
}
            
  Behavior on color {
  ColorAnimation { duration: 100 }
}
}
}
    
  // Fade in/out animation
  Behavior on visible {
  PropertyAnimation {
  duration: 300
  easing.type: Easing.InOutQuad
}
}
    
  // Only show when music is actually playing (not paused)
  property bool shouldShow: mediaController ? mediaController.isPlaying : false
    
  onShouldShowChanged: {
    visible = shouldShow
  }
}
