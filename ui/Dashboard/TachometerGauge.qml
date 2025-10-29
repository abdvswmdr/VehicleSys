import QtQuick 2.15

Rectangle {
  id: tachometer
  width: 250
  height: 250
  color: "transparent"

  property int rpm: vehicleData.rpm
  property int maxRpm: 7000
  property real needleAngle: (rpm / maxRpm) * 240 - 120 // 240 degree sweep, -120 start (7 o'clock position)

  Canvas {
  id: tachometerCanvas
  anchors.fill: parent
        
  onPaint: {
    var ctx = getContext("2d")
    var centerX = width / 2
    var centerY = height / 2
    var radius = Math.min(centerX, centerY) - 15
            
    // Clear canvas
    ctx.clearRect(0, 0, width, height)
            
    // Draw outer circle
    ctx.beginPath()
    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
    ctx.strokeStyle = "#333"
    ctx.lineWidth = 2
    ctx.stroke()
            
    // Draw RPM markings
    ctx.strokeStyle = "#666"
    ctx.lineWidth = 1.5
    ctx.font = "bold 18px sans-serif"
    //ctx.fillStyle = "#333"
	ctx.fillStyle= "#F54927"
    ctx.textAlign = "center"
            
    for (var i = 0; i <= maxRpm; i += 500) {
      var angle = (i / maxRpm) * 240 - 120
      var radian = angle * Math.PI / 180
      var x1 = centerX + (radius - 12) * Math.cos(radian)
      var y1 = centerY + (radius - 12) * Math.sin(radian)
      var x2 = centerX + radius * Math.cos(radian)
      var y2 = centerY + radius * Math.sin(radian)
                
      ctx.beginPath()
      ctx.moveTo(x1, y1)
      ctx.lineTo(x2, y2)
      ctx.stroke()
                
      // Add numbers (in thousands)
      if (i % 1000 === 0) {
        var textX = centerX + (radius - 25) * Math.cos(radian)
        var textY = centerY + (radius - 25) * Math.sin(radian) + 3
        ctx.fillText((i/1000).toString(), textX, textY)
      }
    }
            
    // Draw red zone (6000+ RPM)
    ctx.beginPath()
    var redStartAngle = (6000 / maxRpm) * 240 - 120
    var redEndAngle = 120
    var redStartRadian = redStartAngle * Math.PI / 180
    var redEndRadian = redEndAngle * Math.PI / 180
    ctx.arc(centerX, centerY, radius, redStartRadian, redEndRadian)
    ctx.strokeStyle = "#ff0000"
    ctx.lineWidth = 4
    ctx.stroke()
            
    // Draw center circle
    ctx.beginPath()
    ctx.arc(centerX, centerY, 6, 0, 2 * Math.PI)
    ctx.fillStyle = "#333"
    ctx.fill()
  }
        
  // Redraw when RPM changes
  Connections {
  target: vehicleData
  function onRpmChanged() {
    tachometerCanvas.requestPaint()
  }
}
}
    
  // Tachometer needle
  Rectangle {
  id: needle
  width: 4
  height: tachometer.height * 0.32
  color: rpm > 6000 ? "#ff0000" : "#ffffff"
  anchors.horizontalCenter: parent.horizontalCenter
  anchors.bottom: parent.verticalCenter
  transformOrigin: Item.Bottom
  rotation: needleAngle
        
  Behavior on rotation {
  SmoothedAnimation { duration: 200 }
}
        
  Behavior on color {
  ColorAnimation { duration: 150 }
}
}
    
  // RPM label
  Text {
  anchors.horizontalCenter: parent.horizontalCenter
  anchors.verticalCenter: parent.verticalCenter
  anchors.verticalCenterOffset: -40
  text: "RPM x1000"
  color: "#333"
  font.pixelSize: 12
  font.bold: false
  font.family: "sans-serif"
}
    
  // Digital RPM display
  Rectangle {
  anchors.horizontalCenter: parent.horizontalCenter
  anchors.bottom: parent.bottom
  anchors.bottomMargin: 80
  width: 70
  height: 20
  color: "#1a1a1a"
  border.color: "#333"
  border.width: 0.4
  radius: 2
        
  Text {
  anchors.horizontalCenter: parent.horizontalCenter
  anchors.verticalCenter: parent.verticalCenter
  text: rpm.toString()
  color: rpm > 6000 ? "#ff4444" : "#00ff00"
  font.pixelSize: 14
  font.bold: true
  font.family: "monospace"
            
  Behavior on color {
  ColorAnimation { duration: 150 }
}
}
}
}
