import QtQuick 2.15

Rectangle {
  id: statusBar
  height: 30
  color: "#1a1a1a"
    
  Row {
  id: statusRow
  anchors {
  left: parent.left
  verticalCenter: parent.verticalCenter
  leftMargin: 20
}
  spacing: 25
        
  Image {
  id: lockIcon
  width: statusBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: ( systemHandler.carLocked ? "qrc:/images/padlockLock.png" : "qrc:/images/padlockUnlock.png" )
  anchors.verticalCenter: parent.verticalCenter
            
  MouseArea {
  anchors.fill: parent
  onClicked: systemHandler.setCarLocked( !systemHandler.carLocked )
}
}

  Text {
  id: timeDisplay
  text: systemHandler.currentTime
  font.pixelSize: 16
  font.bold: true
  color: "white"
  anchors.verticalCenter: parent.verticalCenter
}

  Text {
  id: temperatureDisplay
  text: systemHandler.outdoorTemp + "°C"
  font.pixelSize: 16
  font.bold: true
  color: "#ffffff"
  anchors.verticalCenter: parent.verticalCenter
}

  Rectangle {
  id: recordingIcon
  width: 16
  height: 16
  radius: 16
  color: "red"
  border.color: "darkred"
  border.width: 1
  anchors.verticalCenter: parent.verticalCenter
            
  Rectangle {
  anchors.centerIn: parent
  width: 4
  height: 4
  radius: 8
  color: "white"
}
}

  Row {
  spacing: 8
  anchors.verticalCenter: parent.verticalCenter
            
  Image {
  id: userIcon
  width: statusBar.height * 0.55
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/userIcon_w.png"
  anchors.verticalCenter: parent.verticalCenter
}

  Text {
  id: userNameDisplay
  text: systemHandler.userName
  font.pixelSize: 16
  font.bold: true
  color: "white"
  anchors.verticalCenter: parent.verticalCenter
}
}
}
    
  Row {
  id: connectivityRow
  anchors {
  right: parent.right
  verticalCenter: parent.verticalCenter
  rightMargin: 20
}
  spacing: 15
        
  // Bluetooth icon
  Rectangle {
  width: 28
  height: 28
  radius: 4
  color: "#1a1a1a"
  anchors.verticalCenter: parent.verticalCenter
            
  Image {
  id:bluetoothIcon
  width: statusBar.height * 0.6  
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/bluetoothIcon.png"
  anchors.verticalCenter: parent.verticalCenter
  anchors.centerIn: parent
}
}
        
  // Wi-Fi icon  
  Rectangle {
  width: 28
  height: 28
  radius: 4
  color: "#1a1a1a"
  anchors.verticalCenter: parent.verticalCenter
  
  Image {
  id:wifiIcon
  width: statusBar.height * 0.6  
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/wifiIcon.png"
  anchors.verticalCenter: parent.verticalCenter
  anchors.centerIn: parent
}
}
        
  // Battery icon
  Rectangle {
  width: 28
  height: 28
  radius: 4
  color: "#1a1a1a"
  anchors.verticalCenter: parent.verticalCenter

  Image {
  id:batteryChargingIcon
  width: statusBar.height * 0.6
  fillMode: Image.PreserveAspectFit
  source: "qrc:/images/batteryChargingIcon.png"
  anchors.verticalCenter: parent.verticalCenter
  anchors.centerIn: parent
}
}
}
}
