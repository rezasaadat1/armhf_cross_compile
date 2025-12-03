# CrossCompiling Template for C/C++ Embedded Linux

[![Dev Container CI](https://github.com/rezasaadat1/armhf_cross_compile/actions/workflows/devcontainer_ci.yml/badge.svg)](https://github.com/rezasaadat1/armhf_cross_compile/actions/workflows/devcontainer_ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

A production-ready template for cross-compiling C/C++ applications for embedded Linux targets. Supports multiple architectures with debug and release build configurations.

![Cross Compilation](images/cross_compilation.png)

### ✨ Features

- 🎯 **Multi-architecture support**: ARM64, ARMhf, ARMel, RISC-V, x86_64, i386
- 🔧 **Debug & Release builds**: Optimized builds with proper compiler flags
- 🐳 **Dev Container ready**: Consistent development environment
- 🚀 **GitHub Actions CI/CD**: Automated builds for all architectures
- 🐛 **Remote debugging**: GDB integration with VS Code
- 📝 **Built-in logging**: Configurable logger with timestamps

### 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/rezasaadat1/armhf_cross_compile.git
cd armhf_cross_compile

# Build for host (debug)
make host-debug

# Build for host (release)
make host-release

# Cross-compile for ARM HF (debug)
make debug

# Cross-compile for ARM HF (release)  
make release

# See all options
make help
```

### 📦 Build Targets

| Command | Description | Flags |
|---------|-------------|-------|
| `make` | ARM HF cross-compile (debug) | `-g3 -O0 -DDEBUG` |
| `make debug` | ARM HF cross-compile (debug) | `-g3 -O0 -DDEBUG` |
| `make release` | ARM HF cross-compile (release) | `-O2 -DNDEBUG -s` |
| `make host` | Host compile (debug) | `-g3 -O0 -DDEBUG` |
| `make host-release` | Host compile (release) | `-O2 -DNDEBUG -s` |
| `make cross-debug CROSS_ARCH=arm64 CPP=aarch64-linux-gnu-g++` | Custom arch (debug) | — |
| `make cross-release CROSS_ARCH=arm64 CPP=aarch64-linux-gnu-g++` | Custom arch (release) | — |

### 🏗️ Project Structure

```
├── .devcontainer/          # Dev Container configuration
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── postCreateCommand.sh
├── .github/workflows/      # GitHub Actions CI/CD
│   └── devcontainer_ci.yml
├── .vscode/                # VS Code configuration
│   ├── launch.json         # Debug configurations
│   ├── tasks.json          # Build tasks
│   └── settings.json       # Target settings
├── include/                # Header files
│   ├── config.h            # Project configuration
│   └── logger.h            # Logging utilities
├── src/                    # Source files
│   └── main.cpp
├── scripts/                # Utility scripts
│   └── test_build.sh       # Build verification
├── Makefile                # Build configuration
├── deploy.sh               # Remote deployment script
└── README.md
```

For a detailed explanation of cross-compilation concepts, visit [Cross Compilation Guide](https://www.codeinsideout.com/blog/c-cpp/cross-compilation/).

---

## Setting Up the Development Environment

### Option 1: Dev Container (Recommended)

The easiest way to get started is using Dev Containers, which provides a fully configured development environment.

**Prerequisites:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [OrbStack](https://orbstack.dev/) (macOS)
- [VS Code](https://code.visualstudio.com/) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

**Steps:**
1. Clone the repository
2. Open in VS Code
3. Click "Reopen in Container" when prompted (or use Command Palette: `Dev Containers: Reopen in Container`)
4. Wait for the container to build (~2-3 minutes first time)

### Option 2: Manual Setup

If you prefer a local setup on Ubuntu/Debian:

```bash
# Install required packages
sudo apt update
sudo apt install -y cmake make gdb-multiarch git sshpass curl build-essential

# Install cross-compilers for all supported architectures
sudo apt install -y \
    gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
    gcc-arm-linux-gnueabi g++-arm-linux-gnueabi \
    gcc-riscv64-linux-gnu g++-riscv64-linux-gnu
```

### VS Code Extensions

The Dev Container automatically installs these extensions, but for manual setup:

| Extension | Description |
|-----------|-------------|
| [C/C++ Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack) | IntelliSense, debugging, code browsing |
| [Makefile Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.makefile-tools) | Makefile support |
| [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) | Consistent code style |

---

## Supported Architectures

| Architecture | Compiler | Target Devices |
|--------------|----------|----------------|
| `arm64` | `aarch64-linux-gnu-g++` | Raspberry Pi 4/5, modern ARM64 boards |
| `armhf` | `arm-linux-gnueabihf-g++` | Raspberry Pi 3, BeagleBone, Allwinner H3 |
| `armel` | `arm-linux-gnueabi-g++` | Older ARM devices (Arietta, FOX G20) |
| `riscv64` | `riscv64-linux-gnu-g++` | Allwinner Nezha, RISC-V boards |
| `amd64` | `x86_64-linux-gnu-g++` | x86_64 Linux systems |
| `i386` | `i686-linux-gnu-g++` | 32-bit x86 systems |

---

## Debug vs Release Builds

### Debug Build (`-DDEBUG`)
- Full debug symbols (`-g3`)
- No optimization (`-O0`)
- `DEBUG` macro defined
- Verbose logging enabled
- ~100KB binary size

### Release Build (`-DNDEBUG`)
- Optimized (`-O2`)
- Stripped symbols (`-s`)
- `NDEBUG` macro defined  
- Minimal logging (INFO level)
- ~14KB binary size

### Using DEBUG in Code

```cpp
#ifdef DEBUG
    // This code only compiles in debug builds
    LOG_DEBUG("Detailed debug information: %d", value);
    performExpensiveValidation();
#endif

// Release builds skip debug code entirely
```

---

## GitHub Actions CI/CD

The project includes automated CI/CD that builds binaries for all architectures in both debug and release modes.

**Triggered by:**
- Push to tags matching `v*.*.*` (e.g., `v1.0.0`)
- Manual workflow dispatch

**Release artifacts (12 binaries):**
```
firmware_arm64_debug_v1.0.0.bin      firmware_arm64_release_v1.0.0.bin
firmware_armhf_debug_v1.0.0.bin      firmware_armhf_release_v1.0.0.bin
firmware_armel_debug_v1.0.0.bin      firmware_armel_release_v1.0.0.bin
firmware_riscv64_debug_v1.0.0.bin    firmware_riscv64_release_v1.0.0.bin
firmware_amd64_debug_v1.0.0.bin      firmware_amd64_release_v1.0.0.bin
firmware_i386_debug_v1.0.0.bin       firmware_i386_release_v1.0.0.bin
```

---

## Remote Debugging

### Configuration

Edit `.vscode/settings.json` with your target's details:

```json
{
    "TARGET_IP": "192.168.1.100",
    "DEBUG_PORT": "6666",
    "BINARY": "firmware.bin",
    "DEST_DIR": "/home/debian",
    "USER": "debian",
    "PASS": "your-password"
}
```

### Deploy and Debug

**Option 1: VS Code (F5)**
- Press `F5` to build, deploy, and start debugging
- Uses `launch.json` configurations

**Option 2: Manual deployment**
```bash
# Build
make release

# Deploy manually
./deploy.sh 192.168.1.100 6666 firmware.bin /home/debian debian password
```

---

## Apple Silicon Users

If you're using a Mac M1/M2, your environment architecture will be arm64, potentially causing issues when running x64 executables later on. To address this in your Docker environment, execute the following commands in your shell:

```bash
# Check the OS architecture; if it shows x86_64, skip the next steps.
lscpu

# Enable multi-architecture support.
sudo dpkg --add-architecture amd64

# Fix repositories.
echo 'deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
deb [arch=amd64,i386] http://us.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu jammy-security main restricted universe multiverse

deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-backports main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ jammy-security main restricted universe multiverse' | sudo tee /etc/apt/sources.list

# Install necessary libraries.
sudo apt update
```

## Advanced: GLIBC Compatibility

When cross-compiling, ensure your toolchain's glibc version is compatible with your target:

```bash
# Check your cross-compiler's glibc version
arm-linux-gnueabihf-ld --version

# Check target's glibc version (run on target)
ldd --version
```

> ⚠️ **Important**: The cross-compiler's glibc version must be **equal to or lower** than the target's glibc version.

### Custom Toolchains

If you face glibc compatibility issues, use prebuilt toolchains like [Linaro](https://releases.linaro.org/components/toolchain/binaries/):

```makefile
# In Makefile, update compiler paths:
TARGET_CPP := ../gcc-linaro-7.5.0/bin/arm-linux-gnueabihf-g++
TARGET_CC  := ../gcc-linaro-7.5.0/bin/arm-linux-gnueabihf-gcc
```

---

## Logger Usage

The template includes a built-in logger (`include/logger.h`):

```cpp
#include "logger.h"

LOG_TRACE("Trace message");
LOG_DEBUG("Debug value: %d", value);
LOG_INFO("Application started");
LOG_WARN("Warning: low memory");
LOG_ERROR("Failed to open file: %s", filename);
LOG_FATAL("Critical error, shutting down");
```

**Output format:**
```
2025-12-03 10:15:30 DEBUG [functionName] [file.cpp:42] : Your message here
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
