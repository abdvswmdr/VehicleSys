import QtQuick 2.15

Rectangle {
  id: bottomBar
  anchors {
  left: parent.left
  right: parent.right
  bottom: parent.bottom
}
  color: "black"
  height: parent.height / 12
    
  // Signals for parent communication
  signal musicClicked()
  signal dashboardClicked()
  signal phoneClicked()
  signal parkAssistClicked()

  Image {
  id: carSettingsIcon
  anchors {
  left: parent.left
  leftMargin: 15
  verticalCenter: parent.verticalCenter
}

  height: bottomBar.height * .85
  fillMode: Image.PreserveAspectFit

  source: "qrc:/images/carSettingsIcon.png"
}
    
  HVACComponent {
  id: driverHVACControl
  anchors {
  left: carSettingsIcon.right
  leftMargin: 50
  top: parent.top
  bottom: parent.bottom
}
  hvacController: driverHVAC
}
    
  Row {
  id: middleIconsRow
  anchors {
  horizontalCenter: parent.horizontalCenter
  verticalCenter: parent.verticalCenter
}
  spacing: 30
        
  Image {
  id: homeIcon
  width: bottomBar.height * 0.6
  height: bottomBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/homebuttonIcon.png"
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
	// TODO: Add home functionality
	console.log("Home button clicked")
  }
}
}
        
  Image {
  id: musicIcon
  width: bottomBar.height * 0.6
  height: bottomBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/musicIcon.png"
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
	bottomBar.musicClicked()
  }
}
}
        
  Image {
  id: mapIcon
  width: bottomBar.height * 0.6
  height: bottomBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/mapIcon.png"
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
	bottomBar.dashboardClicked()
  }
}
}
        
  Image {
  id: phoneIcon
  width: bottomBar.height * 0.6
  height: bottomBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/phoneCallIcon.png"
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
	bottomBar.phoneClicked()
  }
}
}
        
  Image {
  id: videoIcon
  width: bottomBar.height * 0.6
  height: bottomBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/videoIcon.png"
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
	// TODO: Add video functionality
	console.log("Video button clicked")
  }
}
}

  Image {
  id: settingsIcon
  width: bottomBar.height * 0.6
  height: bottomBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/settingsIcon.png"
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
	// TODO: Add video functionality
	console.log("Settings button clicked")
  }
}
}

  Image {
  id: parkAssistIcon
  width: bottomBar.height * 0.6
  height: bottomBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/parkAssistIcon.png"
            
  MouseArea {
  anchors.fill: parent
  onClicked: {
	bottomBar.parkAssistClicked()
  }
}
}
}
    
  MusicPlayerStatus {
  id: musicPlayerStatus
  anchors {
  right: volumeControl.left
  rightMargin: 8
  // left: passengerHVACControl.right
  verticalCenter: parent.verticalCenter
}
}
    
  VolumeControlComponent {
  id: volumeControl
  anchors {
  right: parent.right
  rightMargin: 170
  top: parent.top
  bottom: parent.bottom
}
  width: 40
}
    
  HVACComponent {
  id: passengerHVACControl
  anchors {
  left: carSettingsIcon.right
  leftMargin: 260
  top: parent.top
  bottom: parent.bottom
}
  hvacController: passengerHVAC
}
}

