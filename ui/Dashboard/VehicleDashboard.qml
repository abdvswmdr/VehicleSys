import QtQuick 2.15
import "."

Rectangle {
  id: dashboard
  anchors.fill: parent
  anchors.margins: 5
  color: "#0a0a0a"
  radius: 8
    
  // Main dashboard layout - 2 columns
  Row {
  anchors.fill: parent
  anchors.margins: 8
  spacing: parent.width * 0.01
        
  // Left column - Speedometer, Tachometer, and Circular Gauges
  Column {
  anchors.top: parent.top
  anchors.bottom: parent.bottom
  spacing: 4
  width: parent.width * 0.66  // increments gauges too
            
  // Top row - Main gauges
  Row {
  anchors.horizontalCenter: parent.horizontalCenter
  spacing: parent.width * 0.02
                
  Speedometer {
  id: speedometer
  width: parent.parent.width * 0.48
  height: width * 0.96
}
                
  TachometerGauge {
  id: tachometer
  width: parent.parent.width * 0.48
  height: width * 0.96
}
}
            
  // Middle row - Fuel and temperature gauges
  Row {
  anchors.horizontalCenter: parent.horizontalCenter
  spacing: parent.width * 0.22
                
  CircularGauge {
  id: fuelGauge
  //anchors.horizontalCenter: tachometer.horizontalCenter
  width: parent.parent.width * 0.25
  height: width
  value: vehicleData.fuelLevel
  maxValue: 100
  title: "FUEL"
  unit: "%"
  gaugeColor: value < 20 ? "#ff4444" : "#00aa44"
  warningThreshold: 20
}
                
  CircularGauge {
  id: tempGauge
  width: parent.parent.width * 0.25
  height: width
  value: vehicleData.engineTemperature
  maxValue: 120
  title: "TEMP"
  unit: "°C"
  gaugeColor: value > 100 ? "#ff4444" : "#00aaff"
  warningThreshold: 105
}
}
            
  // Bottom row - Gear display and CAN Mode Selector
  Row {
  anchors.horizontalCenter: parent.horizontalCenter
  spacing: parent.width * 0.05
                
  Rectangle {
  width: parent.parent.width * 0.3
  height: 80
  color: "#1a1a1a"
  radius: 10
  border.color: "#333"
  border.width: 1
                    
  Column {
  anchors.centerIn: parent
                        spacing: 2
                        
                        Text {
    anchors.horizontalCenter: parent.horizontalCenter
    text: "GEAR"
    color: "#FFFFFF"
    font.bold: true
    font.pixelSize: 16
  }
                        
  Text {
  anchors.horizontalCenter: parent.horizontalCenter
  text: vehicleData.gear
  color: "#00ff00"
  font.pixelSize: 36
  font.bold: true
}
}
}
                
  // CAN Mode Selector
  Rectangle {
  width: parent.parent.width * 0.54
  height: 80
  color: "#1a1a1a"
  radius: 8
  border.color: "#333"
  border.width: 1
                    
  property bool simulationMode: canBusController.status === "Simulation Mode Active"
                    
  Column {
  anchors.fill: parent
  anchors.margins: 10
  spacing: 8
                        
  Text {
  text: "CAN MODE"
  color: "#FFFFFF"
  font.pixelSize: 16
  font.bold: true
  anchors.horizontalCenter: parent.horizontalCenter
}
                        
  Row {
  anchors.horizontalCenter: parent.horizontalCenter
  spacing: 10
                            
  Rectangle {
  width: parent.parent.parent.width * 0.4
  height: 30
  color: parent.parent.parent.simulationMode ? "#004488" : "#333"
  radius: 4
  border.color: parent.parent.parent.simulationMode ? "#0088ff" : "#555"
  border.width: 1
                                
  Text {
  anchors.centerIn: parent
  text: "Simulation"
  color: parent.parent.parent.parent.simulationMode ? "#ffffff" : "#aaa"
  font.pixelSize: 12
}
                                
  MouseArea {
  anchors.fill: parent
  onClicked: {
    if (canBusController) {
      canBusController.connectToSimulator()
    }
  }
}
}
                            
  Rectangle {
  width: parent.parent.parent.width * 0.4
  height: 30
  color: !parent.parent.parent.simulationMode ? "#004400" : "#333"
  radius: 4
  border.color: !parent.parent.parent.simulationMode ? "#00aa44" : "#555"
  border.width: 1
                                
  Text {
  anchors.centerIn: parent
  text: "CAN Control"
  color: !parent.parent.parent.parent.simulationMode ? "#ffffff" : "#aaa"
  font.pixelSize: 12
}
                                
  MouseArea {
  anchors.fill: parent
  onClicked: {
    if (canBusController) {
      canBusController.disconnectFromSimulator()
    }
  }
}
}
}
}
}
}
}
        
  // Right column - Warning lights and vehicle status
  Column {
  anchors.top: parent.top
  anchors.bottom: parent.bottom
  spacing: 8
  width: parent.width * 0.32
            
  // Warning lights grid
  Rectangle {
  width: parent.width 
  height: 240
  color: "#1a1a1a"
  radius: 8
  border.color: "#333"
  border.width: 1
                
  Text {
  anchors.top: parent.top
  anchors.topMargin: 10
  anchors.horizontalCenter: parent.horizontalCenter
  text: "TELLTALES"
  color: "#FFFFFF"
  font.pixelSize: 16
  font.bold: true
}
                
  Grid {
  anchors.horizontalCenter: parent.horizontalCenter
  anchors.verticalCenter: parent.verticalCenter
  //anchors.top: parent.top
  //anchors.topMargin: 
  //anchors.bottom: parent.bottom
  //anchors.bottomMargin: 2
  anchors.verticalCenterOffset: 10
  // anchors.horizontalCenterOffset: 5
  columns: 4
  spacing: parent.width * 0.03
                    
  // Turn signals
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: vehicleData.leftTurnSignal
  lightColor: "#00aa00"
  symbol: "◀"
  blinking: true
}
                    
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: vehicleData.rightTurnSignal
  lightColor: "#00aa00"
  symbol: "▶"
  blinking: true
}
                    
  // Engine warning
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: vehicleData.engineTemperature > 105
  lightColor: "#ff4444"
  symbol: "⚠"
  blinking: false
}
                    
  // Low fuel warning
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: vehicleData.fuelLevel < 20
  lightColor: "#ffaa00"
  //symbol: "⛽"
  Image {
  source: "qrc:/images/lowFuelIcon.png";
  //anchors.fill: parent; 
  anchors.centerIn: parent;       // center icon 
  //fillMode: Image.PreserveAspectFit
  width: parent.width * 0.7 // 70% of the outer size
  height: parent.height * 0.7
  //  smooth: true
}
  blinking: vehicleData.fuelLevel < 10
}
                    
  // Battery warning
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: vehicleData.batteryVoltage < 12
  lightColor: "#ff4444"
  symbol: "⚡"
  Image {
  source: "qrc:images/batteryIcon.png";
  anchors.centerIn: parent;       // center icon 
  width: parent.width * 0.7 // 70% of the outer size
  height: parent.height * 0.7
  //  smooth: true
}
  blinking: false
}
                    
  // Headlights
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: vehicleData.headlights
  lightColor: "#00aaff"
  symbol: "💡"
  blinking: false
}
                    
  // Parking brake
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: vehicleData.parkingBrake
  lightColor: "#ff4444"
  symbol: "🅿"
  blinking: false
}
                    
  // Seatbelt
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: !vehicleData.seatbelt && vehicleData.engineRunning
  lightColor: "#ff4444"
  symbol: ""
  Image {
  source: "qrc:/images/seatBeltIcon.png";
  anchors.centerIn: parent;       // center icon 
  width: parent.width * 0.9 // 70% of the outer size
  height: parent.height * 0.9
  //  smooth: true
}
  blinking: true
}
                    
  // High beam
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: vehicleData.headlights
  lightColor: "#0088ff"
  symbol: "⚡"
  blinking: false
}
                    
  // ABS warning (placeholder for now)
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: false
  lightColor: "#ff4444"
  symbol: "ABS"
  blinking: false
}
                    
  // New Warning Light 1 (placeholder)
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: false
  lightColor: "#ffaa00"
  symbol: "⚠1"
  blinking: false
}
                    
  // New Warning Light 2 (placeholder)
  WarningLight {
  width: parent.parent.width * 0.2
  height: width
  active: false
  lightColor: "#00aaff"
  symbol: "⚠2"
  blinking: false
}
}
}
            
  // Vehicle status information
  Rectangle {
  width: parent.width
  height: 140
  color: "#1a1a1a"
  radius: 8
  border.color: "#333"
  border.width: 1
                
  Column {
  anchors.fill: parent
  anchors.margins: 15
  spacing: 8
                    
  Text {
  text: "VEHICLE STATUS"
  color: "#FFFFFF"
  font.pixelSize: 16
  font.bold: true
  anchors.horizontalCenter: parent.horizontalCenter
}
                    
  Row {
  spacing: 20
  Text {
  text: "Odometer:"
  color: "#aaa"
  font.pixelSize: 12
}
  Text {
  text: vehicleData.odometer.toFixed(1) + " km"
  color: "#fff"
  font.pixelSize: 12
  font.family: "monospace"
}
}
                    
  Row {
  spacing: 20
  Text {
  text: "Battery:"
  color: "#aaa"
  font.pixelSize: 12
}
  Text {
  text: vehicleData.batteryVoltage + "V"
  color: vehicleData.batteryVoltage < 12 ? "#ff4444" : "#00aa44"
  font.pixelSize: 12
  font.family: "monospace"
}
}
                    
  Row {
  spacing: 20
  Text {
  text: "Engine:"
  color: "#aaa"
  font.pixelSize: 12
}
  Text {
  text: vehicleData.engineRunning ? "RUNNING" : "OFF"
  color: vehicleData.engineRunning ? "#00aa44" : "#666"
  font.pixelSize: 12
  font.bold: true
}
}
}
}
            
  // CAN Bus status
  Rectangle {
  width: parent.width
  height: 72
  color: "#1a1a1a"
  radius: 8
  border.color: "#333"
  border.width: 1
                
  Row {
  anchors.centerIn: parent
                      spacing: 10
  anchors.verticalCenter: parent.verticalCenter
  anchors.horizontalCenter: parent.horizontalCenter
                    
                    Rectangle {
  width: 8
  height: 18
  radius: 4
  color: canBusController.connected ? "#00aa44" : "#ff4444"
                        
  SequentialAnimation {
  running: canBusController.connected
  loops: Animation.Infinite
  PropertyAnimation {
  target: parent
  property: "opacity"
  to: 0.3
  duration: 5000
}
  PropertyAnimation {
  target: parent
  property: "opacity"
  to: 1.0
  duration: 5000
}
}
}
                    
  Text {
  text: "CAN: " + (canBusController.connected ? "connection ON" : "connection OFF")
  color: canBusController.connected ? "#00aa44" : "#ff4444"
  font.pixelSize: 16
  anchors.verticalCenter: parent.verticalCenter
}
}
}
}
}
}
