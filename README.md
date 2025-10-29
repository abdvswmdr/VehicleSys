# Vehicle Infotainment System

A modern, feature-rich automotive infotainment interface built with Qt/QML, showcasing advanced UI development skills and automotive software design patterns.

## 🚗 Overview

VehicleSys is a sophisticated car infotainment system that demonstrates professional-grade Qt/QML development. The application features a clean, intuitive interface with real-time vehicle data management, interactive controls, and modern automotive UI design principles.

![Vehicle Infotainment System Demo](images/region_rec_20250823_093651_medium_reddit.gif)

## ✨ Features

- **Real-time Vehicle Control**: Lock/unlock functionality with visual feedback
- **Dual-Zone Climate Control**: Independent driver and passenger HVAC systems (50-90°F)
- **Intelligent Audio Management**: Dynamic volume control with 4-state visual feedback
- **Full Music Player System**: Qt Multimedia integration with audio playback, playlist management, and media controls
- **Music Status Display**: Real-time now-playing information with song/artist display in bottom bar
- **Interactive Dashboard**: Temperature monitoring, clock display, user profile, and telltale warning lights
- **Smart Status Bar**: Connectivity indicators (Bluetooth, Wi-Fi, Battery) with system status
- **Navigation Interface**: Search box with map integration using MapboxGL
- **Quick Access Controls**: Central navigation icons for music, map, phone, and video
- **Modern UI Design**: Clean, automotive-inspired interface with responsive layouts
- **Modular Architecture**: Reusable component system with clean separation of concerns
- **Property System**: Qt's property system for real-time data binding and updates

## 🛠️ Technical Stack

- **Framework**: Qt 5.15+ with QML
- **Language**: C++ (backend) / QML (frontend)  
- **Build System**: CMake 3.20+
- **Architecture**: Model-View-Controller (MVC) pattern
- **Components**: QtQuick, QtLocation, QtPositioning, QtMultimedia
- **Audio System**: Qt5 Multimedia with GStreamer backend for media playback
- **Graphics**: Hardware-accelerated rendering with OpenGL/Vulkan support

## 📋 Prerequisites

- Qt 5.15 or higher with Multimedia support
- CMake 3.20+
- C++17 compatible compiler
- Git
- Audio system: PulseAudio/PipeWire for audio playback

### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install qt5-default qtdeclarative5-dev qtpositioning5-dev qtlocation5-dev \
                     qtmultimedia5-dev libqt5multimedia5-plugins libqt5multimedia5 \
                     cmake build-essential
```

**Note**: For audio codec support, you may also need:
```bash
sudo apt-get install gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly
```

## 🚀 Building & Running

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd Vehicle-Infotainment
   ```

2. **Build the project**
   ```bash
   mkdir build && cd build
   cmake ..
   make
   ```

3. **Run the application**
   ```bash
   ./VehicleSys
   ```

## 🎵 Music System Setup

The VehicleSys includes a complete audio playback system using Qt Multimedia. Follow these steps to ensure proper music functionality.

### Audio File Setup

1. **Create music directory**
   ```bash
   mkdir music
   ```

2. **Add audio files** (supported formats: MP3, MP4, WAV, OGG, M4A, AAC, FLAC, WMA)
   ```bash
   cp /path/to/your/music/*.mp3 music/
   ```

### Qt Multimedia Installation & Configuration

If you encounter the error "Qt Multimedia not available", follow these steps:

1. **Install Qt Multimedia packages**
   ```bash
   sudo apt-get update
   sudo apt-get install qtmultimedia5-dev libqt5multimedia5-plugins libqt5multimedia5
   ```

2. **Verify audio system**
   ```bash
   pactl info  # Check PulseAudio/PipeWire status
   pactl list sinks short  # List audio output devices
   ```

3. **Test system audio**
   ```bash
   speaker-test -t sine -f 440 -l 1
   ```

4. **Clean rebuild after installing Qt Multimedia**
   ```bash
   rm -rf build/*
   cd build
   cmake ..
   make -j4
   ```

### Music System Architecture

- **MediaController**: Handles audio playback, playlist management, and media controls
- **AudioController**: Manages volume levels and audio routing
- **MusicPlayerStatus**: Real-time display component showing current track info
- **Integration**: Seamless volume synchronization between UI and audio backend

### Expected Output

When Qt Multimedia is properly configured, you should see:
```
MediaController: Qt Multimedia available, audio role set to MusicRole
MediaController: Initial volume set to: 50
Found 19 audio files in "/path/to/music"
Loaded 19 tracks
```

Instead of the fallback message:
```
MediaController: Qt Multimedia not available - audio playback will not work
Loaded 19 tracks (simulation mode)
```

## 🔧 Troubleshooting

### Common QML Errors and Solutions

#### 1. "StatusBar is not a type" Error
**Problem**: QML component not registered in qmldir
```
qrc:/ui/RightScreen/RightScreen.qml:24:5: StatusBar is not a type
```

**Solution**: Ensure `ui/RightScreen/qmldir` contains:
```
StatusBar 1.0 StatusBar.qml
```

#### 2. "Cannot anchor item to self" Error
**Problem**: Circular anchor reference in QML
```
qrc:/ui/BottomBar/BottomBar.qml:155:3: QML VolumeControlComponent: Cannot anchor item to self.
```

**Solution**: Remove self-referencing anchors:
```qml
// WRONG
anchors.left: volumeControl.left

// CORRECT  
width: 80
anchors.right: parent.right
```

#### 3. "ReferenceError: albumArt is not defined"
**Problem**: Missing id property on QML element
```
qrc:/ui/BottomBar/MusicPlayerStatus.qml:39: ReferenceError: albumArt is not defined
```

**Solution**: Add id to the referenced element:
```qml
Rectangle {
    id: albumArt  // Add this line
    width: parent.height
    // ... rest of properties
}
```

#### 4. "Unable to assign [undefined] to bool"
**Problem**: Property doesn't exist on controller object
```
qrc:/ui/Dashboard/VehicleDashboard.qml:335:3: Unable to assign [undefined] to bool
```

**Solution**: Check property exists in C++ controller:
```qml
// WRONG (if highBeam property doesn't exist)
active: vehicleData.highBeam

// CORRECT (use existing property)
active: vehicleData.headlights
```

### Audio System Issues

#### 1. No Audio Output
**Check audio system status**:
```bash
pactl info
pactl list sinks short
pulseaudio --check  # Should return nothing if running
```

#### 2. GStreamer Plugin Issues
**Install additional codecs**:
```bash
sudo apt-get install gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad
```

#### 3. Qt Multimedia Detection
**Verify Qt Multimedia is linked**:
```bash
ldd VehicleSys | grep Qt5Multimedia
```

Should show: `libQt5Multimedia.so.5 => /usr/lib/...`

## 🏗️ Project Structure

```
VehicleSys/
├── CMakeLists.txt          # Build configuration with Qt Multimedia
├── main.cpp                # Application entry point
├── qml.qrc                 # Resource file (includes all QML components)
├── controllers/            # Backend logic
│   ├── headers/
│   │   ├── system.h       # Core system controller
│   │   ├── hvachandler.h  # Climate control management
│   │   ├── audiocontroller.h # Volume control system
│   │   ├── mediacontroller.h # Music playback management
│   │   ├── vehicledatacontroller.h # Vehicle data and telltales
│   │   └── canbuscontroller.h # CAN bus simulation
│   └── src/
│       ├── system.cpp     # System controller implementation
│       ├── hvachandler.cpp # HVAC logic implementation
│       ├── audiocontroller.cpp # Audio control implementation
│       ├── mediacontroller.cpp # Qt Multimedia integration
│       ├── vehicledatacontroller.cpp # Vehicle state management
│       └── canbuscontroller.cpp # CAN data simulation
├── ui/                    # QML components
│   ├── BottomBar/         # Interactive bottom controls
│   │   ├── BottomBar.qml  # Main bottom interface
│   │   ├── HVACComponent.qml # Temperature controls
│   │   ├── VolumeControlComponent.qml # Audio controls
│   │   ├── MusicPlayerStatus.qml # Now-playing display
│   │   └── qmldir         # Component registration
│   ├── Dashboard/         # Vehicle dashboard components
│   │   ├── VehicleDashboard.qml # Main dashboard
│   │   ├── Speedometer.qml # Speed gauge
│   │   ├── TachometerGauge.qml # RPM gauge
│   │   ├── CircularGauge.qml # Generic gauge component
│   │   ├── WarningLight.qml # Telltale indicators
│   │   └── qmldir         # Component registration
│   ├── LeftScreen/        # Left dashboard panel
│   │   ├── LeftScreen.qml # Left panel container
│   │   └── qmldir         # Component registration
│   ├── RightScreen/       # Map and navigation interface
│   │   ├── RightScreen.qml # Main right panel
│   │   ├── NavigationSearchBox.qml # Search functionality
│   │   ├── StatusBar.qml  # Top status bar with connectivity
│   │   └── qmldir         # Component registration
│   ├── MusicPlayer/       # Music player interface
│   │   ├── MusicPlayerComponent.qml # Full music player
│   │   └── qmldir         # Component registration
│   ├── Phone/            # Phone interface
│   │   ├── PhoneInterface.qml # Phone UI
│   │   └── qmldir        # Component registration
│   └── ParkAssist/       # Parking assistance
│       ├── ParkAssistComponent.qml # Parking UI
│       └── qmldir        # Component registration
├── music/                # Audio files directory
│   └── *.mp3            # Supported audio files
├── images/               # UI assets and icons
├── build/               # Build output directory
└── README.md           # Project documentation
```

## 🎯 Architecture Highlights

- **Multi-Controller Backend**: Specialized C++ controllers for system, HVAC, audio, and media management
- **Qt Multimedia Integration**: Full audio playback system with QMediaPlayer and QMediaPlaylist
- **Component Modularity**: Reusable QML components with configurable property bindings
- **Dual Audio Architecture**: Separate AudioController (volume) and MediaController (playback) with synchronized operation
- **Signal-Slot Pattern**: Reactive programming for real-time UI updates and media state changes
- **Event-Driven Design**: Mouse area interactions with immediate visual feedback
- **Resource Management**: Efficient asset loading through Qt's resource system and automatic music scanning
- **Property Binding**: Automatic UI synchronization with backend data changes and playback state
- **Conditional Compilation**: CMake-based feature detection for Qt Multimedia with graceful fallback
- **Audio System Abstraction**: Cross-platform audio support with PulseAudio/PipeWire compatibility

## 🔧 Development Features

- **Advanced Property System**: Q_PROPERTY macros for seamless C++/QML data binding
- **Interactive Controls**: Temperature increment/decrement with boundary checking
- **Dynamic UI States**: Volume icons that change based on audio level
- **Timer-Based Feedback**: Temporary UI state changes with automatic restoration
- **Event System**: Comprehensive mouse area handling for user interactions
- **Memory Management**: RAII principles and Qt's parent-child object model
- **Type Safety**: Strong typing with Qt's meta-object system

## 🎨 UI Components

### Interactive Bottom Bar
- **HVACComponent**: Dual-zone temperature controls with +/- buttons and live display
- **VolumeControlComponent**: Smart audio control with 4-state icon system
- **MusicPlayerStatus**: Dynamic now-playing display with album art, track info, and stop button
- **Navigation Icons**: Quick access buttons for music, map, phone, and video apps

### Right Screen Panel
- **NavigationSearchBox**: Interactive search with dynamic placeholder text
- **StatusBar**: Top status bar with lock control, real-time clock, temperature, connectivity indicators
- **Map Integration**: MapboxGL rendering with navigation capabilities
- **Content Switching**: Seamless transitions between map, music player, and phone interfaces

### Left Screen Panel
- **VehicleDashboard**: Comprehensive vehicle monitoring with gauges and telltales
- **Speedometer**: Analog speed gauge with digital display (0-160 km/h)
- **TachometerGauge**: RPM gauge with red-line indication (0-7000 RPM)
- **CircularGauge**: Reusable gauge component for fuel and temperature
- **WarningLight**: Telltale indicators with blinking animations and state management

### Music System Components
- **MusicPlayerComponent**: Full-screen music player with playlist, controls, and progress
- **Media Controls**: Play/pause/stop/skip with visual feedback
- **Playlist Management**: Automatic music directory scanning and track loading
- **Volume Integration**: Synchronized volume control between UI and audio backend

### System Elements
- **Dynamic Icons**: Context-aware visual feedback (lock states, volume levels, connectivity)
- **Responsive Layout**: Components that scale with screen dimensions
- **Real-time Updates**: Live data binding with automatic UI refresh
- **State Management**: Intelligent component visibility based on system state

## 📚 Learning Outcomes

This project demonstrates proficiency in:
- **Advanced Qt/QML Development**: Complex application architecture with multiple interacting components
- **C++/QML Integration**: Seamless data flow using property system, signals, and invokable methods  
- **Interactive UI Design**: Touch-friendly automotive interface with immediate feedback
- **Component-Based Architecture**: Reusable, configurable QML components with clean interfaces
- **Event-Driven Programming**: Responsive user interaction handling with state management
- **Build System Mastery**: CMake configuration with automatic MOC/UIC processing
- **Software Engineering**: Clean code practices, documentation, and version control


## 🔄 Future Enhancements
<!--
- **Media Playback**: Full music player with playlist management
- **Advanced Climate**: Automatic climate zones with sensors
- **Vehicle Diagnostics**: Real-time performance monitoring dashboard  
- **Connectivity**: Bluetooth device pairing and management
- **Voice Commands**: Speech recognition for hands-free control
- **Customization**: User profiles with personalized settings
- **Animation System**: Smooth transitions and micro-interactions
-->
## 🤝 Contributing

This is a **personal learning project** designed to enhance C++ and Qt/QML development skills. The project demonstrates software engineering practices and automotive UI development techniques. Feedback and suggestions for improvements are welcome!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

*Built with Qt/QML - Showcasing modern automotive software development*
