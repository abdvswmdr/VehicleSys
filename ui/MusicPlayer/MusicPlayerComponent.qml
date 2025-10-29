import QtQuick 2.15

Rectangle {
  id: musicPlayer
  width: 400
  height: 300
  color: "#1a1a1a"
  radius: 8
  border.color: "#333"
  border.width: 1

  property bool isPlaying: mediaController ? mediaController.isPlaying : false
  property string currentSong: mediaController ? mediaController.currentTitle : "No Track Selected"
  property string currentArtist: mediaController ? mediaController.currentArtist : "Unknown Artist"
  property int currentTime: mediaController ? Math.floor(mediaController.currentTime / 1000) : 0
  property int totalTime: mediaController ? Math.floor(mediaController.totalTime / 1000) : 240
  property real volume: mediaController ? mediaController.volume : 50

  Rectangle {
  id: header
  anchors.top: parent.top
  anchors.left: parent.left
  anchors.right: parent.right
  height: 50
  color: "#2a2a2a"
  radius: parent.radius
        
  Text {
  anchors.centerIn: parent
  text: "Music Player"
  color: "#ffffff"
  font.pixelSize: 18
  font.bold: true
}
        
  Rectangle {
  anchors.bottom: parent.bottom
  anchors.left: parent.left
  anchors.right: parent.right
  height: 1
  color: "#444"
}
}

  // Album art placeholder
  Rectangle {
  id: albumArt
  anchors.top: header.bottom
  anchors.topMargin: 20
  anchors.left: parent.left
  anchors.leftMargin: 20
  width: 80
  height: 80
  color: "#333"
  radius: 4
        
  Image {
  anchors.centerIn: parent
  width: 40
  height: 40
  source: "qrc:/images/musicIcon.png"
  fillMode: Image.PreserveAspectFit
}
}

  // Song info
  Column {
  anchors.top: header.bottom
  anchors.topMargin: 20
  anchors.left: albumArt.right
  anchors.leftMargin: 15
  anchors.right: parent.right
  anchors.rightMargin: 20
  spacing: 5

  Text {
  text: currentSong
  color: "#ffffff"
  font.pixelSize: 16
  font.bold: true
  elide: Text.ElideRight
  width: parent.width
}

  Text {
  text: currentArtist
  color: "#aaa"
  font.pixelSize: 14
  elide: Text.ElideRight
  width: parent.width
}

  // Progress bar
  Rectangle {
  width: parent.width
  height: 4
  color: "#444"
  radius: 2
  anchors.topMargin: 10

  Rectangle {
  id: progressBar
  width: parent.width * (currentTime / Math.max(totalTime, 1))
  height: parent.height
  color: "#00aaff"
  radius: 2
                
  Behavior on width {
  SmoothedAnimation { duration: 500 }
}
}

  MouseArea {
  anchors.fill: parent
  onClicked: {
    if (mediaController) {
      var newTime = (mouse.x / width) * totalTime
      mediaController.seek(newTime * 1000) // Convert to milliseconds
    }
  }
}
}

  Row {
  spacing: 10
  Text {
  text: formatTime(currentTime)
  color: "#aaa"
  font.pixelSize: 12
}
  Text {
  text: "/"
  color: "#666"
  font.pixelSize: 12
}
  Text {
  text: formatTime(totalTime)
  color: "#aaa"
  font.pixelSize: 12
}
}
}

  // Control buttons
  Row {
  anchors.bottom: parent.bottom
  anchors.bottomMargin: 40
  anchors.horizontalCenter: parent.horizontalCenter
  spacing: 40

  // Previous button
  Rectangle {
  width: 70
  height: 70
  color: "#333"
  radius: 40
  anchors.verticalCenter: parent.verticalCenter

  
  Image {
  anchors.centerIn: parent
  source: "qrc:/images/rewind-button.png"
  width: parent.width * 0.4 // relative to button 
  height: parent.height * 0.4
  fillMode: Image.PreserveAspectFit
  smooth: true
}
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
    if (mediaController) {
      mediaController.previous()
    }
  }
}
}

  // Play/Pause button
  Rectangle {
  width: 100
  height: 100
  color: isPlaying ? "#ff4444" : "#00aa44"
  radius: 55
  anchors.verticalCenter: parent.verticalCenter
            
  Image {
  anchors.centerIn: parent
  source: isPlaying ? "qrc:/images/pause.png" : "qrc:/images/play-button.png"
  width: parent.width * 0.4 // relative to button 
  height: parent.height * 0.4
  fillMode: Image.PreserveAspectFit
  smooth: true
}
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
    if (mediaController) {
      mediaController.togglePlayPause()
    }
  }
}
            
  Behavior on color {
  ColorAnimation { duration: 200 }
}
}

  // Next button
  Rectangle {
  width: 70
  height: 70
  color: "#333"
  radius: 40
  anchors.verticalCenter: parent.verticalCenter
            
  Image {
  anchors.centerIn: parent
  source: "qrc:/images/forward-button.png"
  width: parent.width * 0.4 // relative to button 
  height: parent.height * 0.4
  fillMode: Image.PreserveAspectFit
  smooth: true
}
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
    if (mediaController) {
      mediaController.next()
    }
  }
}
}
}

  // Volume control
  Row {
  anchors.bottom: parent.bottom
  anchors.bottomMargin: 30
  anchors.right: parent.right
  anchors.rightMargin: 20
  spacing: 10

  Text {
  anchors.verticalCenter: parent.verticalCenter
  text: "♪"
  color: "#aaa"
  font.pixelSize: 16
}

  Rectangle {
  width: 80
  height: 4
  color: "#444"
  radius: 2
  anchors.verticalCenter: parent.verticalCenter

  Rectangle {
  width: parent.width * (volume / 100)
  height: parent.height
  color: "#00aaff"
  radius: 2
                
  Behavior on width {
  SmoothedAnimation { duration: 200 }
}
}

  MouseArea {
  anchors.fill: parent
  onClicked: {
    if (mediaController) {
      var newVolume = (mouse.x / width) * 100
      mediaController.setVolume(Math.round(newVolume))
    }
  }
}
}
}

  function formatTime(seconds) {
    var mins = Math.floor(seconds / 60)
    var secs = Math.floor(seconds % 60)
    return mins + ":" + (secs < 10 ? "0" : "") + secs
  }
}
