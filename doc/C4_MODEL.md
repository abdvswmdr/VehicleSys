# C4 Model for VehicleSys

This document provides a C4 model for the VehicleSys application. The C4 model is a way to visualize software architecture at different levels of detail, making it easier to understand for different audiences.

This model is designed to be a clear and simple replacement for any existing diagrams, providing a single source of truth for the system's architecture that can be easily maintained.

## Level 1: System Context (C1)

The System Context diagram is the highest level of abstraction. It shows the `VehicleSys` software as a single entity and how it interacts with its users and other external systems.

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

LAYOUT_WITH_LEGEND()

title System Context diagram for VehicleSys

Person(driver, "Driver", "The user of the vehicle.")
System(vehicle_sys, "Vehicle System", "The QML application providing the in-car infotainment and dashboard display.")

System_Ext(car_hardware, "Car Hardware", "The vehicle's physical components (e.g., engine, sensors, speakers, climate control) that the software interacts with via the CAN bus.")

Rel(driver, vehicle_sys, "Views and controls")
Rel(vehicle_sys, car_hardware, "Reads data from and sends commands to", "CAN Bus")

@enduml
```

### Elements:
- **Driver:** The person inside the car who interacts with the Vehicle System's user interface.
- **Vehicle System:** The software application being built. It's a single, deployable unit that runs on the car's head unit.
- **Car Hardware:** Represents all the physical car systems that the software communicates with. In this project, this is largely simulated, but in a real-world scenario, it would be the actual hardware.

---

## Level 2: Container (C2)

The Container diagram zooms into the `VehicleSys` software system. A "container" in this context is a runnable or deployable unit, like a web application, a mobile app, or a standalone executable.

In this project, the entire system runs as a single process.

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

LAYOUT_WITH_LEGEND()

title Container diagram for VehicleSys

Person(driver, "Driver", "The user of the vehicle.")
System_Ext(car_hardware, "Car Hardware", "The vehicle's physical components.")

System_Boundary(c1, "Vehicle System") {
    Container(app, "Desktop Application", "Qt/QML", "The single executable that provides all functionality. It includes the UI, state management, and backend logic.")
}

Rel(driver, app, "Uses")
Rel(app, car_hardware, "Reads data from and sends commands to", "CAN Bus")

@enduml
```

### Elements:
- **Desktop Application:** This is the main container, a single executable built with Qt. It houses both the C++ backend logic and the QML frontend. It communicates with the car's hardware systems.

---

## Level 3: Component (C3)

The Component diagram zooms into the `Desktop Application` container and breaks it down into its major logical components. These components are not separately deployable but represent the key structural building blocks of the code.

```plantuml
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Component.puml

LAYOUT_WITH_LEGEND()

title Component diagram for VehicleSys

System_Ext(car_hardware, "Car Hardware", "The vehicle's physical components.")

Container_Boundary(app, "Desktop Application") {

    Component(qml_ui, "QML UI", "QML/Qt Quick", "Provides the entire user interface, including screens, buttons, and data displays.")
    Component(system_handler, "System Handler", "C++", "Manages application-wide state and acts as a central hub.")
    Component(data_controller, "Vehicle Data Controller", "C++", "Processes incoming CAN bus data and exposes vehicle state (speed, RPM, etc.).")
    Component(hvac_handler, "HVAC Handler", "C++", "Manages climate control logic.")
    Component(media_controller, "Media Controller", "C++", "Manages music playback, playlists, and track info.")
    Component(audio_controller, "Audio Controller", "C++", "Manages system volume.")
    Component(can_bus_controller, "CAN Bus Controller", "C++", "Provides a low-level interface to the CAN bus for sending and receiving data frames.")

    Rel(qml_ui, system_handler, "Reads state from and sends commands to")
    Rel(qml_ui, data_controller, "Binds to and displays data from")
    Rel(qml_ui, hvac_handler, "Sends commands to and reads state from")
    Rel(qml_ui, media_controller, "Sends commands to and reads state from")
    Rel(qml_ui, audio_controller, "Sends commands to and reads state from")

    Rel(system_handler, data_controller, "Uses")
    Rel(system_handler, hvac_handler, "Uses")
    Rel(system_handler, media_controller, "Uses")

    Rel(data_controller, can_bus_controller, "Receives CAN frames from")
    Rel(hvac_handler, can_bus_controller, "Sends CAN frames via")
    Rel(can_bus_controller, car_hardware, "Communicates with", "CAN Bus")
}

@enduml
```

### Components:
- **QML UI:** The entire collection of QML files that form the visual part of the application. It binds directly to the C++ controllers to display data and sends user commands back to them.
- **C++ Controllers (`System`, `VehicleData`, `HVAC`, `Media`, `Audio`):** These are the backend components. Each is a C++ object responsible for a specific domain of logic. They are exposed to the QML UI via Qt's context properties.
- **CAN Bus Controller:** A specialized C++ component that handles the raw communication with the car's hardware (or the simulator). It's the bridge between the physical world and the software logic.

---

## Level 4: Code (C4)

The Code level diagram is the most detailed. It's meant to zoom into an individual component to show its internal code structure, like classes, methods, and their relationships. This level is best represented by UML class diagrams or similar, and can be generated from the code itself.

### Recommendation for C4:
Instead of manually drawing these diagrams, you can focus on a single component to explain its design. For example, a C4 diagram for the **`VehicleDataController`** component would show:
- The `VehicleDataController` class.
- Its public properties exposed to QML (e.g., `m_speed`, `m_rpm`).
- The `speedChanged` and `rpmChanged` signals.
- The public slot `processCanFrame(const QCanBusFrame &frame)` which takes a raw CAN frame, parses it, and updates the internal properties, which in turn emits the signals to update the UI.

This level of detail is useful for developers working on that specific component but is often too granular for high-level architectural discussions. It's recommended to create these only when necessary to explain a complex part of the system.
