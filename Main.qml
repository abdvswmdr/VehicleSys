import QtQuick 2.15
import QtQuick.Window 2.15
import QtLocation 5.15
import QtPositioning 5.15
import "ui/BottomBar"
import "ui/RightScreen"
import "ui/LeftScreen"
import "ui/Dashboard"
import "ui/MusicPlayer"
import "ui/Phone"
import "ui/ParkAssist"

Window {
    // 15 inches 
    width: 1280
    height: 720
    visible: true
    title: qsTr("VehicleSys")

    LeftScreen {
	id: leftScreen
    }

    RightScreen {
	id: rightScreen
    }

    BottomBar {
	id: bottomBar
	onMusicClicked: rightScreen.showMusic()
	onDashboardClicked: rightScreen.showMap() // Map button now only restores map
	onPhoneClicked: rightScreen.showPhone()
	onParkAssistClicked: leftScreen.showParkAssist()
    }

    // Focus for key handling
    Item {
	anchors.fill: parent
	focus: true
	Keys.onEscapePressed: {
	    // ESC key can return to map view
	    rightScreen.showMap()
	}
    }
}
