# ============================================================================
# CrossCompile Template Makefile
# ============================================================================
# Usage:
#   make                - Cross-compile for ARM HF (debug, default)
#   make release        - Cross-compile for ARM HF (release/optimized)
#   make host           - Compile for host system (debug)
#   make host-release   - Compile for host system (release)
#   make help           - Show all available targets
# ============================================================================

# Project settings
PROJECT_NAME     := firmware
PROJECT_SOURCES  := $(wildcard src/*.cpp)
PROJECT_HEADERS  := $(wildcard include/*.h)

# Build mode: debug (default) or release
BUILD_MODE       ?= debug

# Output directories
BUILD_DIR        := build
DEBUG_DIR        := $(BUILD_DIR)/debug
RELEASE_DIR      := $(BUILD_DIR)/release

# Output binaries
TARGET_BINARY    := $(PROJECT_NAME).bin
HOST_BINARY      := program.bin
CROSS_BINARY     := $(PROJECT_NAME)_$(CROSS_ARCH).bin

# Compiler flags
INCLUDES         := -Iinclude
LDFLAGS          += -Llib
COMMON_FLAGS     := -Wall -Wextra -Wpedantic -std=c++17

# Debug flags: full debug info, no optimization
DEBUG_FLAGS      := -g3 -O0 -DDEBUG

# Release flags: optimized, no debug
RELEASE_FLAGS    := -O2 -DNDEBUG -s

# Select flags based on BUILD_MODE
ifeq ($(BUILD_MODE),release)
    CFLAGS       := $(COMMON_FLAGS) $(RELEASE_FLAGS)
    BUILD_TYPE   := Release
else
    CFLAGS       := $(COMMON_FLAGS) $(DEBUG_FLAGS)
    BUILD_TYPE   := Debug
endif

# Static linking (uncomment if needed for standalone binaries)
# CFLAGS += -static-libgcc -static-libstdc++ -static

# ============================================================================
# Cross-compiler settings (ARM Hard Float - default)
# ============================================================================
TARGET_CPP       := arm-linux-gnueabihf-g++
TARGET_CC        := arm-linux-gnueabihf-gcc
TARGET_AR        := arm-linux-gnueabihf-ar
TARGET_RANLIB    := arm-linux-gnueabihf-ranlib
TARGET_LD        := arm-linux-gnueabihf-ld

# ============================================================================
# Alternative cross-compilers (uncomment as needed)
# ============================================================================

# ARM 64-bit (aarch64) - Raspberry Pi 4/5, modern ARM boards
# TARGET_CPP     := aarch64-linux-gnu-g++
# TARGET_CC      := aarch64-linux-gnu-gcc
# TARGET_AR      := aarch64-linux-gnu-ar
# TARGET_RANLIB  := aarch64-linux-gnu-ranlib
# TARGET_LD      := aarch64-linux-gnu-ld

# ARM Soft Float (armel) - Older ARM devices
# TARGET_CPP     := arm-linux-gnueabi-g++
# TARGET_CC      := arm-linux-gnueabi-gcc
# TARGET_AR      := arm-linux-gnueabi-ar
# TARGET_RANLIB  := arm-linux-gnueabi-ranlib
# TARGET_LD      := arm-linux-gnueabi-ld

# RISC-V 64-bit
# TARGET_CPP     := riscv64-linux-gnu-g++
# TARGET_CC      := riscv64-linux-gnu-gcc
# TARGET_AR      := riscv64-linux-gnu-ar
# TARGET_RANLIB  := riscv64-linux-gnu-ranlib
# TARGET_LD      := riscv64-linux-gnu-ld

# Custom Linaro toolchain (for glibc compatibility)
# TARGET_CPP     := ../gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-g++
# TARGET_CC      := ../gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc
# TARGET_AR      := ../gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-ar
# TARGET_RANLIB  := ../gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-ranlib
# TARGET_LD      := ../gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-ld

# Host compiler settings
HOST_CPP         := g++
HOST_CC          := gcc

# ============================================================================
# Build targets
# ============================================================================

.PHONY: all debug release host host-debug host-release cross_compile clean clean_all help info

# Default target: cross-compile for ARM HF (debug)
all: $(TARGET_BINARY)

# Explicit debug build for target
debug: clean-bin
	@$(MAKE) BUILD_MODE=debug $(TARGET_BINARY)

# Release build for target
release: clean-bin
	@$(MAKE) BUILD_MODE=release $(TARGET_BINARY)

$(TARGET_BINARY): $(PROJECT_SOURCES) $(PROJECT_HEADERS)
	@echo "==> Cross-compiling for ARM HF [$(BUILD_TYPE)]..."
	@echo "    Flags: $(CFLAGS)"
	$(TARGET_CPP) $(CFLAGS) -DTARGET $(LDFLAGS) -o $@ $(PROJECT_SOURCES) $(INCLUDES) $(LIB_NAME) $(LDLIBS)
	@echo "==> Built: $@ [$(BUILD_TYPE)]"

# Host compilation targets
host: host-debug

host-debug: clean-bin
	@$(MAKE) BUILD_MODE=debug host_compile

host-release: clean-bin
	@$(MAKE) BUILD_MODE=release host_compile

host_compile: $(HOST_BINARY)

$(HOST_BINARY): $(PROJECT_SOURCES) $(PROJECT_HEADERS)
	@echo "==> Compiling for host system [$(BUILD_TYPE)]..."
	@echo "    Flags: $(CFLAGS)"
	$(HOST_CPP) $(CFLAGS) -DHOST $(HOST_LDFLAGS) -o $@ $(PROJECT_SOURCES) $(INCLUDES) $(LIB_NAME) $(LDLIBS)
	@echo "==> Built: $@ [$(BUILD_TYPE)]"

# Generic cross-compile (set CROSS_ARCH and CPP environment variables)
cross_compile: $(CROSS_BINARY)

cross-debug:
	@$(MAKE) BUILD_MODE=debug cross_compile

cross-release:
	@$(MAKE) BUILD_MODE=release cross_compile

$(CROSS_BINARY): $(PROJECT_SOURCES) $(PROJECT_HEADERS)
	@echo "==> Cross-compiling for $(CROSS_ARCH) [$(BUILD_TYPE)]..."
	@echo "    Flags: $(CFLAGS)"
	$(CPP) $(CFLAGS) -D$(CROSS_ARCH) $(LDFLAGS) -o $@ $(PROJECT_SOURCES) $(INCLUDES) $(LIB_NAME) $(LDLIBS)
	@echo "==> Built: $@ [$(BUILD_TYPE)]"

# Clean only binary files (used internally)
clean-bin:
	@rm -f *.bin

# Clean build artifacts
clean:
	@echo "==> Cleaning build artifacts..."
	rm -f *.bin *.o *.elf
	rm -rf $(BUILD_DIR)
	@echo "==> Clean complete"

# Clean everything including libraries
clean_all: clean
	@echo "==> Cleaning all generated files..."
	rm -rf lib/* host/lib/* host/include/*
	@echo "==> Full clean complete"

# Show build information
info:
	@echo "============================================="
	@echo "Project:        $(PROJECT_NAME)"
	@echo "Build Mode:     $(BUILD_TYPE)"
	@echo "Sources:        $(PROJECT_SOURCES)"
	@echo "Target Binary:  $(TARGET_BINARY)"
	@echo "Host Binary:    $(HOST_BINARY)"
	@echo "Cross Compiler: $(TARGET_CPP)"
	@echo "Host Compiler:  $(HOST_CPP)"
	@echo "CFLAGS:         $(CFLAGS)"
	@echo "============================================="

# Help target
help:
	@echo "============================================="
	@echo "CrossCompile Template - Available Targets"
	@echo "============================================="
	@echo ""
	@echo "Target (ARM HF) builds:"
	@echo "  make              Build for ARM HF (debug, default)"
	@echo "  make debug        Build for ARM HF (debug, explicit)"
	@echo "  make release      Build for ARM HF (release/optimized)"
	@echo ""
	@echo "Host builds:"
	@echo "  make host         Build for host system (debug)"
	@echo "  make host-debug   Build for host system (debug, explicit)"
	@echo "  make host-release Build for host system (release/optimized)"
	@echo ""
	@echo "Cross-compile for other architectures:"
	@echo "  make cross-debug CROSS_ARCH=<arch> CPP=<compiler>"
	@echo "  make cross-release CROSS_ARCH=<arch> CPP=<compiler>"
	@echo ""
	@echo "Utility:"
	@echo "  make clean        Remove binary files"
	@echo "  make clean_all    Remove all generated files"
	@echo "  make info         Show build configuration"
	@echo "  make help         Show this help message"
	@echo ""
	@echo "Build flags:"
	@echo "  Debug:   $(DEBUG_FLAGS)"
	@echo "  Release: $(RELEASE_FLAGS)"
	@echo ""
	@echo "Supported CROSS_ARCH values:"
	@echo "  arm64, armhf, armel, riscv64, amd64, i386"
	@echo ""
	@echo "Examples:"
	@echo "  make release"
	@echo "  make host-release"
	@echo "  make cross-release CROSS_ARCH=arm64 CPP=aarch64-linux-gnu-g++"
	@echo "============================================="