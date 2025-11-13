# GitHub Actions CI/CD Setup Guide

## Why GitHub Actions Matters for This Project

### For All Roles (C++, Robotics, Software Engineering):
- **Industry Standard**: 90% of tech companies use CI/CD
- **Professionalism**: Shows you understand modern development workflows
- **Quality Assurance**: Automated testing prevents broken code from merging
- **Collaboration**: Essential for team development
- **DevOps Awareness**: Goes beyond just coding

### What Recruiters Look For:
✅ Automated builds on every commit
✅ Automated test execution
✅ Code quality checks (linting, static analysis)
✅ Multi-platform support (if applicable)
✅ Build status badges in README

---

## Complete GitHub Actions Workflow

### Workflow File Structure
```
.github/
└── workflows/
    ├── build-and-test.yml       # Main CI pipeline
    ├── code-quality.yml         # Static analysis
    └── release.yml              # Optional: Release automation
```

---

## 1. Main Build & Test Pipeline

**File:** `.github/workflows/build-and-test.yml`

```yaml
name: Build and Test

# Trigger on push to any branch and pull requests
on:
  push:
    branches: [ main, feat/*, fix/* ]
  pull_request:
    branches: [ main ]

# Environment variables
env:
  BUILD_TYPE: Release
  QT_VERSION: 5.15.2

jobs:
  build-linux:
    name: Build on Ubuntu
    runs-on: ubuntu-latest

    steps:
    # 1. Checkout code
    - name: Checkout repository
      uses: actions/checkout@v3
      with:
        submodules: recursive  # If you have git submodules

    # 2. Install Qt
    - name: Install Qt
      uses: jurplel/install-qt-action@v3
      with:
        version: ${{ env.QT_VERSION }}
        host: 'linux'
        target: 'desktop'
        modules: 'qtlocation qtpositioning qtmultimedia'
        cache: true

    # 3. Install system dependencies
    - name: Install Dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y \
          cmake \
          build-essential \
          libgtest-dev \
          ninja-build \
          qtpositioning5-dev \
          qtlocation5-dev

    # 4. Configure CMake
    - name: Configure CMake
      run: |
        cmake -B ${{github.workspace}}/build \
          -DCMAKE_BUILD_TYPE=${{env.BUILD_TYPE}} \
          -DBUILD_TESTING=ON \
          -G Ninja

    # 5. Build
    - name: Build
      run: cmake --build ${{github.workspace}}/build --config ${{env.BUILD_TYPE}}

    # 6. Run tests
    - name: Run Tests
      working-directory: ${{github.workspace}}/build
      run: |
        ctest --output-on-failure --verbose

    # 7. Upload test results (optional)
    - name: Upload Test Results
      if: always()
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: ${{github.workspace}}/build/test_results.xml

    # 8. Upload build artifacts (optional)
    - name: Upload Build Artifacts
      uses: actions/upload-artifact@v3
      with:
        name: vehicle-sys-linux
        path: ${{github.workspace}}/build/VehicleSys

  # Optional: macOS build
  build-macos:
    name: Build on macOS
    runs-on: macos-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Install Qt
      run: brew install qt@5

    - name: Configure and Build
      run: |
        export PATH="/usr/local/opt/qt@5/bin:$PATH"
        mkdir build && cd build
        cmake .. -DCMAKE_BUILD_TYPE=Release
        make -j$(sysctl -n hw.ncpu)

  # Optional: Windows build
  build-windows:
    name: Build on Windows
    runs-on: windows-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v3

    - name: Install Qt
      uses: jurplel/install-qt-action@v3
      with:
        version: '5.15.2'
        host: 'windows'
        target: 'desktop'
        arch: 'win64_msvc2019_64'

    - name: Configure and Build
      run: |
        mkdir build
        cd build
        cmake .. -DCMAKE_BUILD_TYPE=Release
        cmake --build . --config Release
```

---

## 2. Code Quality Pipeline

**File:** `.github/workflows/code-quality.yml`

```yaml
name: Code Quality

on:
  push:
    branches: [ main, feat/*, fix/* ]
  pull_request:
    branches: [ main ]

jobs:
  static-analysis:
    name: Static Analysis
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    # C++ Linting with clang-tidy
    - name: Install clang-tidy
      run: |
        sudo apt-get update
        sudo apt-get install -y clang-tidy

    - name: Run clang-tidy
      run: |
        find controllers -name "*.cpp" -o -name "*.h" | \
        xargs clang-tidy -checks='*,-modernize-use-trailing-return-type'

  cppcheck:
    name: CPPCheck Analysis
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Install cppcheck
      run: sudo apt-get install -y cppcheck

    - name: Run cppcheck
      run: |
        cppcheck --enable=all --inconclusive \
          --suppress=missingIncludeSystem \
          --error-exitcode=1 \
          controllers/

  code-coverage:
    name: Code Coverage
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Install Qt and Dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y \
          qtbase5-dev \
          qtlocation5-dev \
          qtpositioning5-dev \
          libgtest-dev \
          lcov

    - name: Build with Coverage
      run: |
        mkdir build && cd build
        cmake .. -DCMAKE_CXX_FLAGS="--coverage" -DBUILD_TESTING=ON
        make

    - name: Run Tests
      run: |
        cd build
        ./tests/vehicle_tests

    - name: Generate Coverage Report
      run: |
        cd build
        lcov --capture --directory . --output-file coverage.info
        lcov --remove coverage.info '/usr/*' --output-file coverage.info
        lcov --list coverage.info

    - name: Upload to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: ./build/coverage.info
        fail_ci_if_error: true
```

---

## 3. Pull Request Template

**File:** `.github/pull_request_template.md`

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manually tested

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
```

---

## 4. Branch Protection Rules

### Set up in GitHub Repository Settings:

**Settings → Branches → Add Rule for `main`**

✅ **Require status checks to pass before merging**
- `build-linux`
- `static-analysis`
- `cppcheck`

✅ **Require pull request reviews before merging**
- At least 1 approval (if working with others)

✅ **Require linear history**
- Enforces clean git history

---

## 5. Status Badges for README

Add these to your `README.md`:

```markdown
# Vehicle Infotainment System

![Build Status](https://github.com/YOUR_USERNAME/VehicleSys/workflows/Build%20and%20Test/badge.svg)
![Code Coverage](https://codecov.io/gh/YOUR_USERNAME/VehicleSys/branch/main/graph/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

...rest of README...
```

**Why Status Badges?**
- Immediately shows project health
- Professional appearance
- Demonstrates CI/CD setup
- Recruiters recognize these instantly

---

## 6. Advanced: Release Automation

**File:** `.github/workflows/release.yml`

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'  # Trigger on version tags like v1.0.0

jobs:
  create-release:
    name: Create Release
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Install Dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y qtbase5-dev cmake

    - name: Build Release
      run: |
        mkdir build && cd build
        cmake .. -DCMAKE_BUILD_TYPE=Release
        make

    - name: Package
      run: |
        cd build
        tar -czf VehicleSys-${{github.ref_name}}.tar.gz VehicleSys

    - name: Create GitHub Release
      uses: softprops/action-gh-release@v1
      with:
        files: build/VehicleSys-${{github.ref_name}}.tar.gz
        body: |
          Release ${{github.ref_name}}

          ## Changes
          See commit history for details.
      env:
        GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

---

## What GitHub Actions Does (Step-by-Step)

### When you push code:

1. **Trigger**: GitHub detects push to repository
2. **Spin up Runner**: GitHub provisions Ubuntu VM
3. **Checkout Code**: Downloads your repository
4. **Install Dependencies**: Qt, CMake, build tools
5. **Configure**: Runs CMake to generate build files
6. **Build**: Compiles C++ code
7. **Test**: Runs all unit tests
8. **Report**: Shows pass/fail status
9. **Artifacts**: Optionally saves build outputs

**Total Time:** ~3-5 minutes per build

---

## Cost & Limits

### GitHub Actions Free Tier:
- **Public Repos**: Unlimited minutes ✅ (Your project is public)
- **Private Repos**: 2,000 minutes/month
- **Storage**: 500MB artifacts

**For your project:** FREE forever (public repo)

---

## What to Say in Interviews

### Good Examples:

✅ *"I set up GitHub Actions CI/CD to automatically build and test on every commit. The pipeline runs my Google Test suite, checks code quality with clang-tidy, and generates coverage reports. Build time is under 4 minutes, and I enforce passing tests before merging PRs."*

✅ *"I use GitHub Actions for continuous integration. Every push triggers a build on Ubuntu, runs static analysis, and executes unit tests. I've configured branch protection so code can't merge to main without passing all checks. This caught several bugs before they made it to the main branch."*

✅ *"My CI pipeline builds on Linux, macOS, and Windows to ensure cross-platform compatibility. I also generate code coverage reports and upload them to Codecov. The README shows build status badges so anyone can see the project health at a glance."*

### Metrics to Mention:
- "Build completes in 3-4 minutes"
- "25 unit tests run automatically on every commit"
- "Code coverage tracked at 75%"
- "Cross-platform builds (Linux/macOS/Windows)"
- "Static analysis with clang-tidy catches issues early"

---

## Quick Start: Minimal CI Setup

**If time-constrained, do THIS:**

1. Create `.github/workflows/build.yml`
2. Use the basic build-linux job (first example above)
3. Add status badge to README
4. Done!

**Time:** 30 minutes
**Value:** Massive (shows professionalism)

---

## Troubleshooting Common Issues

### Issue 1: Qt Not Found
```yaml
# Add this step before Configure CMake
- name: Set Qt Path
  run: echo "$Qt5_DIR/bin" >> $GITHUB_PATH
```

### Issue 2: Build Timeout
```yaml
# Add timeout to job
jobs:
  build-linux:
    timeout-minutes: 15  # Default is 6 hours
```

### Issue 3: Tests Fail in CI but Pass Locally
```yaml
# Enable debug output
- name: Run Tests
  run: ctest --output-on-failure --verbose -VV
```

---

## Advanced: Matrix Builds

**Test multiple Qt versions:**

```yaml
strategy:
  matrix:
    qt-version: [5.15.2, 5.12.10]
    os: [ubuntu-latest, macos-latest]

runs-on: ${{ matrix.os }}

steps:
  - uses: jurplel/install-qt-action@v3
    with:
      version: ${{ matrix.qt-version }}
```

**Why?**
- Tests compatibility
- Shows thorough testing mindset
- Impressive for recruiters

---

## Summary: CI/CD Value Proposition

| Feature | Benefit |
|---------|---------|
| **Automated Builds** | Catches build errors immediately |
| **Automated Tests** | Prevents regressions |
| **Code Quality Checks** | Maintains clean codebase |
| **Status Badges** | Professional appearance |
| **Branch Protection** | Enforces quality standards |
| **Coverage Reports** | Tracks test completeness |

**Bottom Line:** GitHub Actions transforms your project from "it works on my machine" to "production-ready with automated quality gates."

---

## Next Steps After CI/CD Setup

1. Add unit tests (see UNIT_TESTING_STRATEGY.md)
2. Enable branch protection
3. Add status badges to README
4. Consider adding Codecov for coverage tracking
5. Set up pre-commit hooks locally (matches CI checks)

**Result:** Professional-grade development workflow that impresses recruiters!
