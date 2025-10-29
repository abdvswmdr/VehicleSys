#include "canbuscontroller.h"
#include <QDebug>
#include <QRandomGenerator>

#ifdef HAVE_QT_SERIALBUS
#include <QCanBus>
#endif

CanBusController::CanBusController(QObject *parent)
    : QObject(parent)
#ifdef HAVE_QT_SERIALBUS
    , m_canDevice(nullptr)
#endif
    , m_simulationTimer(new QTimer(this))
    , m_connected(false)
    , m_status("Disconnected")
    , m_speed(0)
    , m_rpm(800)
    , m_fuelLevel(85)
    , m_engineTemp(90)
    , m_leftTurnSignal(false)
    , m_rightTurnSignal(false)
    , m_headlights(false)
    , m_engineRunning(true)
{
    connect(m_simulationTimer, &QTimer::timeout, this, &CanBusController::simulateVehicleData);
    setupSimulatedData();
}

CanBusController::~CanBusController()
{
#ifdef HAVE_QT_SERIALBUS
    if (m_canDevice) {
        m_canDevice->disconnectDevice();
        delete m_canDevice;
    }
#endif
}

bool CanBusController::connected() const
{
    return m_connected;
}

QString CanBusController::status() const
{
    return m_status;
}

void CanBusController::connectToSimulator()
{
    // Always allow switching to simulation mode, regardless of current state
    if (m_status != "Simulation Mode Active") {
        // First disconnect from any existing connection
        if (m_connected) {
            disconnectFromSimulator();
        }
        
        // Start simulation mode
        m_status = "Simulation Mode Active";
        m_connected = true;
        m_simulationTimer->start(100); // 10Hz update rate
        
        emit statusChanged(m_status);
        emit connectedChanged(m_connected);
        qDebug() << "Switched to simulation mode";
    }
}

void CanBusController::connectToBus(const QString &interface)
{
    if (m_connected) {
        return;
    }

#ifdef HAVE_QT_SERIALBUS
    // Try to connect to specified interface (e.g., vcan0 for virtual CAN)
    qDebug() << "Attempting to connect to CAN interface:" << interface;
    
    // Create device using socketcan plugin with specified interface
    m_canDevice = QCanBus::instance()->createDevice(QStringLiteral("socketcan"), interface);
    
    if (!m_canDevice) {
        qDebug() << "Failed to create CAN device for interface:" << interface;
        // Check available devices
        QString errorString;
        auto availableDevices = QCanBus::instance()->availableDevices(QStringLiteral("socketcan"), &errorString);
        qDebug() << "Available devices:" << availableDevices.size();
        for (const auto &device : availableDevices) {
            qDebug() << "  -" << device.name() << device.description();
        }
    }

    if (m_canDevice) {
        connect(m_canDevice, &QCanBusDevice::framesReceived, this, &CanBusController::handleFramesReceived);
        connect(m_canDevice, &QCanBusDevice::errorOccurred, this, &CanBusController::handleErrorOccurred);
        connect(m_canDevice, &QCanBusDevice::stateChanged, this, &CanBusController::handleStateChanged);

        if (m_canDevice->connectDevice()) {
            m_status = "Connecting to CAN Bus...";
            emit statusChanged(m_status);
            return;
        } else {
            delete m_canDevice;
            m_canDevice = nullptr;
        }
    }
#endif

    // Start simulation mode (fallback or when SerialBus not available)
    m_status = "Simulation Mode Active";
    m_connected = true;
    m_simulationTimer->start(100); // 10Hz update rate
    emit connectedChanged(m_connected);
    emit statusChanged(m_status);
}

void CanBusController::disconnectFromSimulator()
{
    // Always allow switching to CAN control mode
    m_simulationTimer->stop();
    
#ifdef HAVE_QT_SERIALBUS
    if (m_canDevice) {
        m_canDevice->disconnectDevice();
        delete m_canDevice;
        m_canDevice = nullptr;
    }
    
    // Try to connect to actual CAN bus
    qDebug() << "Attempting to connect to CAN interface: vcan0";
    
    // Create device using socketcan plugin
    m_canDevice = QCanBus::instance()->createDevice(QStringLiteral("socketcan"), "vcan0");
    
    if (m_canDevice) {
        connect(m_canDevice, &QCanBusDevice::framesReceived, this, &CanBusController::handleFramesReceived);
        connect(m_canDevice, &QCanBusDevice::errorOccurred, this, &CanBusController::handleErrorOccurred);
        connect(m_canDevice, &QCanBusDevice::stateChanged, this, &CanBusController::handleStateChanged);

        if (m_canDevice->connectDevice()) {
            m_status = "Connecting to CAN Bus...";
            emit statusChanged(m_status);
            return;
        } else {
            delete m_canDevice;
            m_canDevice = nullptr;
        }
    }
    
    // If CAN connection failed, show CAN control mode but indicate no CAN available
    m_connected = false;
    m_status = "CAN Control Mode (No CAN Bus Available)";
    emit connectedChanged(m_connected);
    emit statusChanged(m_status);
    qDebug() << "Switched to CAN control mode, but no CAN bus available";
#else
    // If no SerialBus support, show CAN control mode but indicate no CAN available
    m_connected = false;
    m_status = "CAN Control Mode (No CAN Bus Available)";
    emit connectedChanged(m_connected);
    emit statusChanged(m_status);
    qDebug() << "Switched to CAN control mode, but no CAN bus support available";
#endif
}

void CanBusController::sendFrame(quint32 frameId, const QByteArray &data)
{
#ifdef HAVE_QT_SERIALBUS
    if (!m_canDevice || !m_connected) {
        return;
    }

    QCanBusFrame frame(frameId, data);
    m_canDevice->writeFrame(frame);
#else
    Q_UNUSED(frameId)
    Q_UNUSED(data)
#endif
}

#ifdef HAVE_QT_SERIALBUS
void CanBusController::handleFramesReceived()
{
    if (!m_canDevice) {
        return;
    }

    while (m_canDevice->framesAvailable()) {
        const QCanBusFrame frame = m_canDevice->readFrame();
        if (frame.isValid()) {
            emit frameReceived(frame.frameId(), frame.payload());
        }
    }
}

void CanBusController::handleErrorOccurred(QCanBusDevice::CanBusError error)
{
    if (m_canDevice) {
        QString errorString = m_canDevice->errorString();
        m_status = "Error: " + errorString;
        emit statusChanged(m_status);
        emit errorOccurred(errorString);
    }
}

void CanBusController::handleStateChanged(QCanBusDevice::CanBusDeviceState state)
{
    switch (state) {
    case QCanBusDevice::ConnectedState:
        m_connected = true;
        m_status = "Connected to CAN Bus";
        break;
    case QCanBusDevice::ConnectingState:
        m_status = "Connecting to CAN Bus";
        break;
    case QCanBusDevice::UnconnectedState:
        m_connected = false;
        m_status = "Disconnected from CAN Bus";
        break;
    }
    
    emit connectedChanged(m_connected);
    emit statusChanged(m_status);
}
#endif

void CanBusController::simulateVehicleData()
{
    // Simulate realistic vehicle behavior
    QRandomGenerator *rng = QRandomGenerator::global();
    
    // Speed variation (0-120 km/h)
    int speedChange = rng->bounded(-2, 3);
    m_speed = qBound(0, m_speed + speedChange, 120);
    
    // RPM correlates with speed and engine state
    int targetRpm = 800 + (m_speed * 25); // Idle + speed-based RPM
    m_rpm = qBound(700, targetRpm + rng->bounded(-100, 101), 6000);
    
    // Engine running determination
    m_engineRunning = (m_rpm > 500);
    
    // Fuel consumption (very slow decrease)
    if (m_speed > 0 && rng->bounded(0, 1000) < 1) {
        m_fuelLevel = qMax(0, m_fuelLevel - 1);
    }
    
    // Engine temperature (stable around 90°C)
    int tempChange = rng->bounded(-1, 2);
    m_engineTemp = qBound(70, m_engineTemp + tempChange, 110);
    
    // Random turn signals
    if (rng->bounded(0, 100) < 2) {
        m_leftTurnSignal = !m_leftTurnSignal;
        m_rightTurnSignal = false;
    }
    if (rng->bounded(0, 100) < 2) {
        m_rightTurnSignal = !m_rightTurnSignal;
        m_leftTurnSignal = false;
    }
    
    // Headlights based on time simulation
    static int timeCounter = 0;
    timeCounter++;
    if (timeCounter % 300 == 0) { // Change every 30 seconds
        m_headlights = !m_headlights;
    }

    // Emit CAN frames with simulated data matching DBC format and VehicleDataController expectations
    
    // 0x100: Engine_Data (RPM, load, temperature, fuel) - 8 bytes
    QByteArray engineData(8, 0);
    // Engine Speed (RPM) - bytes 0-1, scale 0.25, so multiply by 4 for raw value
    quint16 rpmRaw = m_rpm * 4;
    engineData[0] = static_cast<char>(rpmRaw & 0xFF);
    engineData[1] = static_cast<char>((rpmRaw >> 8) & 0xFF);
    // Engine Load - byte 2 (not used in simulation, set to reasonable value)
    engineData[2] = static_cast<char>(50); // 50% load
    // Engine Coolant Temperature - byte 3, offset +40, so add 40 to actual temp
    engineData[3] = static_cast<char>(m_engineTemp + 40);
    // Throttle Position - byte 4 (correlate with speed)
    engineData[4] = static_cast<char>(qMin(100, m_speed * 2));
    // Engine Oil Pressure - bytes 5-6 (not critical for simulation)
    engineData[5] = static_cast<char>(150); // Low byte of reasonable pressure
    engineData[6] = static_cast<char>(0);   // High byte
    // Fuel Level - byte 7, scale 0.392157, so divide by 0.392157 for raw
    engineData[7] = static_cast<char>(m_fuelLevel / 0.392157);
    emit frameReceived(0x100, engineData);

    // 0x200: Vehicle_Speed - 8 bytes
    QByteArray speedData(8, 0);
    // Vehicle Speed - bytes 0-1, scale 0.1, so multiply by 10 for raw value
    quint16 speedRaw = m_speed * 10;
    speedData[0] = static_cast<char>(speedRaw & 0xFF);
    speedData[1] = static_cast<char>((speedRaw >> 8) & 0xFF);
    // Wheel speeds (simulate same as vehicle speed)
    speedData[2] = speedData[0]; // Wheel FL low
    speedData[3] = speedData[1]; // Wheel FL high  
    speedData[4] = speedData[0]; // Wheel FR low
    speedData[5] = speedData[1]; // Wheel FR high
    speedData[6] = speedData[0]; // Wheel RL low
    speedData[7] = speedData[1]; // Wheel RL high
    emit frameReceived(0x200, speedData);

    // 0x400: Transmission_Data - 8 bytes
    QByteArray transData(8, 0);
    // Gear position in lower 4 bits (simulate Drive = 3)
    quint8 gearValue = (m_speed > 0) ? 3 : 0; // Drive if moving, Park if stopped
    transData[0] = static_cast<char>(gearValue & 0x0F);
    // Park status in bit 1 of byte 2
    quint8 parkStatus = (m_speed == 0) ? 0x02 : 0x00;
    transData[2] = static_cast<char>(parkStatus);
    emit frameReceived(0x400, transData);

    // 0x500: Battery_Status - 8 bytes  
    QByteArray batteryData(8, 0);
    // Battery voltage - bytes 0-1, scale 0.01, so multiply by 100 for raw
    quint16 voltageRaw = 1400; // 14.0V typical running voltage
    if (!m_engineRunning) voltageRaw = 1200; // 12.0V when engine off
    batteryData[0] = static_cast<char>(voltageRaw & 0xFF);
    batteryData[1] = static_cast<char>((voltageRaw >> 8) & 0xFF);
    emit frameReceived(0x500, batteryData);

    // 0x600: Warning_Lights - 8 bytes
    QByteArray signalsData(8, 0);
    // Warnings in byte 0 (not used in current simulation)
    signalsData[0] = 0;
    // Signal bits in byte 1
    quint8 signalBits = 0;
    if (m_leftTurnSignal) signalBits |= 0x01;
    if (m_rightTurnSignal) signalBits |= 0x02;
    if (m_headlights) signalBits |= 0x04;
    signalsData[1] = static_cast<char>(signalBits);
    emit frameReceived(0x600, signalsData);
}

void CanBusController::setupSimulatedData()
{
    // Initialize with realistic starting values
    m_speed = 0;
    m_rpm = 800; // Idle RPM
    m_fuelLevel = 85; // 85% fuel
    m_engineTemp = 90; // Normal operating temperature
    m_leftTurnSignal = false;
    m_rightTurnSignal = false;
    m_headlights = false;
    m_engineRunning = true; // Engine running by default in simulation
}