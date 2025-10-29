import QtQuick 2.15

Rectangle {
    id: gauge
    width: 100
    height: 100
    color: "transparent"

    property real value: 0
    property real maxValue: 100
    property string title: "GAUGE"
    property string unit: ""
    property color gaugeColor: "#00aa44"
    property real warningThreshold: maxValue * 0.8
    property real needleAngle: (value / maxValue) * 180 - 90 // -90 to +90 degrees

    Canvas {
        id: gaugeCanvas
        anchors.fill: parent
        
        onPaint: {
            var ctx = getContext("2d")
            var centerX = width / 2
            var centerY = height / 2
            var radius = Math.min(centerX, centerY) - 10
            
            // Clear canvas
            ctx.clearRect(0, 0, width, height)
            
            // Draw arc background
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, Math.PI, 2 * Math.PI)
            ctx.strokeStyle = "#333"
            ctx.lineWidth = 8
            ctx.stroke()
            
            // Draw value arc
            var valueAngle = Math.PI + (value / maxValue) * Math.PI
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, Math.PI, valueAngle)
            ctx.strokeStyle = value > warningThreshold ? "#ff4444" : gaugeColor
            ctx.lineWidth = 8
            ctx.stroke()
            
            // Draw tick marks
            ctx.strokeStyle = "#666"
            ctx.lineWidth = 2
            
            for (var i = 0; i <= 10; i++) {
                var angle = Math.PI + (i / 10) * Math.PI
                var x1 = centerX + (radius - 8) * Math.cos(angle)
                var y1 = centerY + (radius - 8) * Math.sin(angle)
                var x2 = centerX + radius * Math.cos(angle)
                var y2 = centerY + radius * Math.sin(angle)
                
                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.stroke()
            }
        }
        
        // Redraw when value changes
        Connections {
            target: gauge
            function onValueChanged() {
                gaugeCanvas.requestPaint()
            }
        }
    }
    
    // Needle
    Rectangle {
        id: needle
        width: 2
        height: gauge.height * 0.3
        color: value > warningThreshold ? "#ff4444" : "#ffffff"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        transformOrigin: Item.Bottom
        rotation: needleAngle
        
        Behavior on rotation {
            SmoothedAnimation { duration: 500 }
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    // Center dot
    Rectangle {
        anchors.centerIn: parent
        width: 6
        height: 6
        radius: 3
        color: "#666"
    }
    
    // Title
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        anchors.topMargin: 15
        text: title
        color: "#666"
        font.pixelSize: 12
        font.bold: true
    }
    
    // Value display
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        text: Math.round(value) + unit
        color: value > warningThreshold ? "#ff4444" : gaugeColor
        font.pixelSize: 16
        font.bold: true
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
}