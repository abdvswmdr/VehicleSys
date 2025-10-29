import QtQuick 2.15

Rectangle {
    id: warningLight
    width: 40
    height: 40
    radius: 20
    color: active ? lightColor : "#2a2a2a"
    border.color: active ? Qt.lighter(lightColor, 1.3) : "#444"
    border.width: 1

    property bool active: false
    property color lightColor: "#ff4444"
    property string symbol: "⚠"
  //property real symbolScale: 0.7    // optionally to override from caller (font.pixelSize)
    property bool blinking: false

    Behavior on color {
        ColorAnimation { duration: 400 }
    }

    Behavior on border.color {
        ColorAnimation { duration: 400 }
    }

    Text {
        anchors.centerIn: parent
        text: symbol
        color: active ? "#ffffff" : "#666"
        font.pixelSize: 24
        
        Behavior on color {
            ColorAnimation { duration: 400 }
        }
    }

    // Blinking animation for critical warnings
    SequentialAnimation {
        id: blinkAnimation
        running: active && blinking
        loops: Animation.Infinite
        
        PropertyAnimation {
            target: warningLight
            property: "opacity"
            to: 0.3
            duration: 500
        }
        PropertyAnimation {
            target: warningLight
            property: "opacity"
            to: 1.0
            duration: 500
        }
    }

    // Glow effect for active lights
    Rectangle {
        anchors.centerIn: parent
        width: parent.width + 6
        height: parent.height + 6
        radius: (parent.width + 6) / 2
        color: "transparent"
        border.color: lightColor
        border.width: 1
        opacity: active ? 0.5 : 0
        
        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
    }
}
