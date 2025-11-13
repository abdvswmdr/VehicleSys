# Unit Testing Strategy for Vehicle Infotainment System

## Why Unit Testing Matters for This Project

### For C++ Roles:
- Demonstrates **code quality** and professional practices
- Shows understanding of **SOLID principles** (testable code = well-designed code)
- Proves ability to write **maintainable**, **regression-proof** code
- Critical skill for automotive/embedded systems (safety-critical)

### For Robotics Roles:
- Navigation algorithms MUST be tested (safety-critical)
- Coordinate transformations need precision validation
- Sensor fusion requires numerical accuracy verification
- Shows **systems thinking** - understanding component interactions

### For Software Engineering:
- Industry standard - most companies require 70-80% code coverage
- Demonstrates **test-driven development** (TDD) mindset
- Shows ability to write **decoupled**, **modular** code
- Proves debugging skills and edge case handling

---

## Testing Framework Recommendations

### Primary: Google Test (gtest)
```bash
# Install on Ubuntu
sudo apt-get install libgtest-dev cmake
cd /usr/src/gtest
sudo cmake CMakeLists.txt
sudo make
sudo cp lib/*.a /usr/lib
```

**Why Google Test?**
- Industry standard for C++ (used by Google, Uber, Tesla)
- Excellent C++ integration
- Rich assertion library
- Mocking support with gmock
- Test fixtures for setup/teardown

### Alternative: Qt Test
```cpp
#include <QtTest/QtTest>
// Built-in to Qt, great for Qt-specific features
```

**Why Qt Test?**
- Native Qt integration
- Signal/Slot testing built-in
- Good for QML component testing
- Already have Qt installed

### Recommendation: **Use BOTH**
- Google Test for pure C++ logic (NavigationController algorithms)
- Qt Test for Qt-specific features (signal/slot connections)

---

## What to Test: Priority Matrix

### 🔴 CRITICAL PRIORITY (Must Have for Interviews)

#### 1. **NavigationController - Core Algorithms**

**Test: Distance Calculation (Haversine Formula)**
```cpp
// tests/test_navigation_controller.cpp
#include <gtest/gtest.h>
#include "navigationcontroller.h"

class NavigationControllerTest : public ::testing::Test {
protected:
    NavigationController* navCtrl;

    void SetUp() override {
        navCtrl = new NavigationController();
    }

    void TearDown() override {
        delete navCtrl;
    }
};

TEST_F(NavigationControllerTest, CalculateDistance_SamePoint_ReturnsZero) {
    QGeoCoordinate point(1.0, 1.0);
    double distance = navCtrl->calculateDistance(point, point);
    EXPECT_DOUBLE_EQ(distance, 0.0);
}

TEST_F(NavigationControllerTest, CalculateDistance_OneDegreeApart_ReturnsCorrectValue) {
    QGeoCoordinate point1(0.0, 0.0);
    QGeoCoordinate point2(0.0, 1.0);
    double distance = navCtrl->calculateDistance(point1, point2);
    // 1 degree longitude at equator ≈ 111.32 km
    EXPECT_NEAR(distance, 111319.5, 1.0); // Within 1 meter
}

TEST_F(NavigationControllerTest, CalculateDistance_KnownLocations_ReturnsCorrectValue) {
    // Kuching to Kuala Lumpur (real-world test)
    QGeoCoordinate kuching(1.55311, 110.345032);
    QGeoCoordinate kl(3.1390, 101.6869);
    double distance = navCtrl->calculateDistance(kuching, kl);
    // Known distance ≈ 850 km
    EXPECT_NEAR(distance, 850000.0, 10000.0); // Within 10km (good enough for nav)
}
```

**Why This Test?**
- Validates critical navigation math
- Shows understanding of **geospatial calculations**
- Demonstrates **numerical testing** (EXPECT_NEAR for floats)
- Real-world test case (Kuching to KL) shows domain knowledge

**Test: Bearing Calculation**
```cpp
TEST_F(NavigationControllerTest, CalculateBearing_North_Returns0) {
    QGeoCoordinate point1(0.0, 0.0);
    QGeoCoordinate point2(1.0, 0.0); // 1° north
    double bearing = navCtrl->calculateBearing(point1, point2);
    EXPECT_NEAR(bearing, 0.0, 0.1);
}

TEST_F(NavigationControllerTest, CalculateBearing_East_Returns90) {
    QGeoCoordinate point1(0.0, 0.0);
    QGeoCoordinate point2(0.0, 1.0); // 1° east
    double bearing = navCtrl->calculateBearing(point1, point2);
    EXPECT_NEAR(bearing, 90.0, 0.1);
}

TEST_F(NavigationControllerTest, CalculateBearing_South_Returns180) {
    QGeoCoordinate point1(1.0, 0.0);
    QGeoCoordinate point2(0.0, 0.0); // 1° south
    double bearing = navCtrl->calculateBearing(point1, point2);
    EXPECT_NEAR(bearing, 180.0, 0.1);
}
```

**Why This Test?**
- Validates **compass heading** calculations
- Tests all cardinal directions (edge cases)
- Important for **autonomous navigation**

**Test: Position Interpolation**
```cpp
TEST_F(NavigationControllerTest, InterpolatePosition_MidPoint_ReturnsCorrectValue) {
    QGeoCoordinate start(0.0, 0.0);
    QGeoCoordinate end(2.0, 2.0);
    QGeoCoordinate mid = navCtrl->interpolatePosition(start, end, 0.5);

    EXPECT_NEAR(mid.latitude(), 1.0, 0.01);
    EXPECT_NEAR(mid.longitude(), 1.0, 0.01);
}

TEST_F(NavigationControllerTest, InterpolatePosition_StartPoint_ReturnsSamePoint) {
    QGeoCoordinate start(1.0, 1.0);
    QGeoCoordinate end(2.0, 2.0);
    QGeoCoordinate result = navCtrl->interpolatePosition(start, end, 0.0);

    EXPECT_DOUBLE_EQ(result.latitude(), start.latitude());
    EXPECT_DOUBLE_EQ(result.longitude(), start.longitude());
}
```

**Why This Test?**
- Critical for **smooth vehicle movement** along route
- Shows understanding of **trajectory planning**
- Validates **boundary conditions** (start/end points)

#### 2. **VehicleDataController - CAN Bus Processing**

**Test: CAN Frame Parsing**
```cpp
class VehicleDataControllerTest : public ::testing::Test {
protected:
    VehicleDataController* vehicleCtrl;

    void SetUp() override {
        vehicleCtrl = new VehicleDataController();
    }

    void TearDown() override {
        delete vehicleCtrl;
    }
};

TEST_F(VehicleDataControllerTest, ProcessSpeedFrame_CorrectParsing) {
    // 0x200 frame with 50 km/h (speed * 10 = 500)
    QByteArray data(8, 0);
    data[0] = static_cast<char>(500 & 0xFF);         // Low byte
    data[1] = static_cast<char>((500 >> 8) & 0xFF);  // High byte

    QSignalSpy spy(vehicleCtrl, &VehicleDataController::speedChanged);
    vehicleCtrl->processCanFrame(0x200, data);

    EXPECT_EQ(vehicleCtrl->speed(), 50);
    EXPECT_EQ(spy.count(), 1); // Signal emitted once
}

TEST_F(VehicleDataControllerTest, ProcessRpmFrame_CorrectScaling) {
    // 0x100 frame with 2000 RPM (rpm * 4 = 8000)
    QByteArray data(8, 0);
    data[0] = static_cast<char>(8000 & 0xFF);
    data[1] = static_cast<char>((8000 >> 8) & 0xFF);

    vehicleCtrl->processCanFrame(0x100, data);

    EXPECT_EQ(vehicleCtrl->rpm(), 2000);
}

TEST_F(VehicleDataControllerTest, LowFuelWarning_EmitsSignal) {
    QByteArray data(8, 0);
    data[7] = static_cast<char>(10 / 0.392157); // 10% fuel

    QSignalSpy spy(vehicleCtrl, &VehicleDataController::lowFuelWarning);
    vehicleCtrl->processCanFrame(0x100, data);

    EXPECT_EQ(spy.count(), 1); // Warning emitted
}
```

**Why This Test?**
- Validates **protocol parsing** (critical for automotive)
- Shows understanding of **bit manipulation** and **scaling**
- Tests **signal emission** (Qt-specific)
- Demonstrates **edge case testing** (warnings)

### 🟡 HIGH PRIORITY (Great for Showcasing Skills)

#### 3. **Integration Tests - Controller Interactions**

**Test: Speed Synchronization**
```cpp
TEST(IntegrationTest, VehicleSpeed_SyncsToNavigation) {
    VehicleDataController vehicleCtrl;
    NavigationController navCtrl;

    // Connect signal/slot
    QObject::connect(&vehicleCtrl, &VehicleDataController::speedChanged,
                     &navCtrl, &NavigationController::updateVehicleSpeed);

    // Simulate CAN frame with 60 km/h
    QByteArray data(8, 0);
    data[0] = static_cast<char>(600 & 0xFF);
    data[1] = static_cast<char>((600 >> 8) & 0xFF);
    vehicleCtrl.processCanFrame(0x200, data);

    // Verify navigation controller received speed
    EXPECT_EQ(navCtrl.currentSpeed(), 60.0);
}
```

**Why This Test?**
- Validates **component integration** (not just unit isolation)
- Shows understanding of **signal/slot mechanism**
- Demonstrates **system-level thinking**

#### 4. **Edge Cases & Error Handling**

**Test: Invalid Coordinates**
```cpp
TEST_F(NavigationControllerTest, StartNavigation_InvalidCoordinates_HandlesGracefully) {
    // Test with invalid latitude (>90)
    navCtrl->startNavigation(100.0, 50.0);

    EXPECT_FALSE(navCtrl->navigationActive());
    // Should not crash, should handle invalid input
}

TEST_F(NavigationControllerTest, RouteCalculation_NoRoute_HandlesGracefully) {
    navCtrl->setDestination(0.0, 0.0); // Invalid destination
    navCtrl->calculateRoute();

    EXPECT_EQ(navCtrl->routeDistance(), 0.0);
    // Should fail gracefully, not crash
}
```

**Why This Test?**
- Shows **defensive programming**
- Demonstrates **error handling**
- Critical for **robustness** (recruiters love this)

### 🟢 MEDIUM PRIORITY (Nice to Have)

#### 5. **Performance Tests**

```cpp
TEST_F(NavigationControllerTest, Performance_1000Updates_CompletesInTime) {
    auto start = std::chrono::high_resolution_clock::now();

    for (int i = 0; i < 1000; i++) {
        navCtrl->simulateRouteMovement();
    }

    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

    // Should complete 1000 updates in < 100ms (10Hz requirement)
    EXPECT_LT(duration.count(), 100);
}
```

**Why This Test?**
- Shows understanding of **real-time requirements**
- Demonstrates **performance awareness**
- Important for **embedded/robotics** roles

---

## Test Organization Structure

```
VehicleSys/
├── CMakeLists.txt          # Add test target
├── tests/
│   ├── CMakeLists.txt
│   ├── test_navigation_controller.cpp
│   ├── test_vehicle_data_controller.cpp
│   ├── test_integration.cpp
│   ├── test_can_bus_parsing.cpp
│   └── test_main.cpp       # gtest main
└── controllers/
    ├── headers/
    └── src/
```

---

## CMake Integration

**tests/CMakeLists.txt**
```cmake
cmake_minimum_required(VERSION 3.20)

# Find Google Test
find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS})

# Include main project headers
include_directories(${CMAKE_SOURCE_DIR}/controllers/headers)

# Test executable
add_executable(vehicle_tests
    test_main.cpp
    test_navigation_controller.cpp
    test_vehicle_data_controller.cpp
    test_integration.cpp

    # Include source files to test
    ${CMAKE_SOURCE_DIR}/controllers/src/navigationcontroller.cpp
    ${CMAKE_SOURCE_DIR}/controllers/src/vehicledatacontroller.cpp
)

# Link libraries
target_link_libraries(vehicle_tests
    ${GTEST_LIBRARIES}
    Qt5::Core
    Qt5::Positioning
    pthread
)

# Enable testing
enable_testing()
add_test(NAME vehicle_tests COMMAND vehicle_tests)
```

**Root CMakeLists.txt - Add testing**
```cmake
# At the end of file
option(BUILD_TESTING "Build tests" ON)

if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
```

---

## Running Tests

```bash
# Build tests
mkdir build && cd build
cmake .. -DBUILD_TESTING=ON
make

# Run all tests
./tests/vehicle_tests

# Run with verbose output
./tests/vehicle_tests --gtest_verbose

# Run specific test
./tests/vehicle_tests --gtest_filter=NavigationControllerTest.CalculateDistance*

# Generate test report
./tests/vehicle_tests --gtest_output=xml:test_results.xml
```

---

## Code Coverage (Bonus Points!)

```bash
# Install coverage tools
sudo apt-get install lcov

# Build with coverage flags
cmake .. -DCMAKE_CXX_FLAGS="--coverage -fprofile-arcs -ftest-coverage"
make

# Run tests
./tests/vehicle_tests

# Generate coverage report
lcov --capture --directory . --output-file coverage.info
lcov --remove coverage.info '/usr/*' --output-file coverage.info
genhtml coverage.info --output-directory coverage_html

# Open in browser
firefox coverage_html/index.html
```

**Target:** 70-80% code coverage

---

## What to Say in Interviews

### When Discussing Testing:

✅ **Good Answer:**
*"I wrote unit tests for the NavigationController using Google Test, focusing on the core algorithms like Haversine distance calculation and bearing computation. I validated against known real-world coordinates like Kuching to KL (850km) to ensure accuracy. I also tested edge cases like invalid coordinates and boundary conditions. The tests run in under 100ms to meet our 10Hz update requirement, which is critical for real-time navigation."*

❌ **Bad Answer:**
*"I didn't have time to write tests."*

### Metrics to Mention:
- "Achieved 75% code coverage on NavigationController"
- "All 25 unit tests pass in < 100ms"
- "Tested against 10+ real-world coordinate pairs"
- "Validated numerical accuracy to within 1 meter"

---

## Quick Win: Minimal Viable Testing

**If time-constrained, test THESE 3 things:**

1. **NavigationController::calculateDistance()** - 5 test cases
2. **NavigationController::calculateBearing()** - 4 test cases
3. **VehicleDataController::processCanFrame()** - 3 test cases

**Total:** 12 tests, ~2 hours of work, massive ROI for interviews

---

## Summary: Testing Value Proposition

| Aspect | Value for Recruiters |
|--------|---------------------|
| **Code Quality** | Shows professional-grade development |
| **Algorithmic Thinking** | Validates math/logic correctness |
| **System Design** | Demonstrates modular, testable architecture |
| **Debugging Skills** | Proves ability to catch bugs early |
| **Industry Practice** | Matches real-world software engineering |
| **Confidence** | "I can prove my code works" |

**Bottom Line:** Unit tests turn this from a "student project" into a "production-ready system" in recruiters' eyes.
