/**
 * @file main.cpp
 * @brief Cross-compilation template - main entry point
 *
 * This example demonstrates a simple program that can be cross-compiled
 * for various embedded Linux targets (ARM, RISC-V, x86, etc.)
 *
 * Build modes:
 *   - Debug:   make host-debug   (includes debug symbols, DEBUG defined)
 *   - Release: make host-release (optimized, NDEBUG defined)
 */

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>
#include <sys/utsname.h>
#include <csignal>

#include "config.h"
#include "logger.h"

// Global flag for graceful shutdown
static volatile bool g_running = true;

/**
 * @brief Signal handler for graceful shutdown
 */
static void signalHandler(int signum) {
    LOG_WARN("Received signal %d (%s), shutting down...", signum,
             signum == SIGINT ? "SIGINT" : signum == SIGTERM ? "SIGTERM" : "UNKNOWN");
    g_running = false;
}

/**
 * @brief Get the build mode string
 * @return "Debug" or "Release" based on compile-time defines
 */
static const char *getBuildMode() {
#if defined(DEBUG)
    return "Debug";
#elif defined(NDEBUG)
    return "Release";
#else
    return "Unknown";
#endif
}

/**
 * @brief Get the architecture name based on compile-time defines
 * @return String describing the target architecture
 */
static const char *getArchitectureName() {
#if defined(arm64)
    return "arm64 (aarch64)";
#elif defined(armhf)
    return "armhf (ARM Hard Float)";
#elif defined(armel)
    return "armel (ARM Soft Float)";
#elif defined(riscv64)
    return "riscv64";
#elif defined(amd64)
    return "amd64 (x86_64)";
#elif defined(i386)
    return "i386 (x86)";
#elif defined(TARGET)
    return "ARM HF Target";
#elif defined(HOST)
    return "Host System";
#else
    return "Unknown";
#endif
}

/**
 * @brief Print build information (DEBUG-only)
 * This function demonstrates conditional compilation
 */
static void printBuildInfo() {
#ifdef DEBUG
    // This section only compiles in debug builds
    LOG_DEBUG("=== DEBUG BUILD INFORMATION ===");
    LOG_DEBUG("Compiled: %s %s", __DATE__, __TIME__);
    LOG_DEBUG("Compiler: %s", __VERSION__);
    LOG_DEBUG("C++ Standard: %ld", __cplusplus);
    LOG_DEBUG("File: %s", __FILE__);
    LOG_DEBUG("================================");
#endif
}

/**
 * @brief Demonstrate debug-only assertions and checks
 */
static void debugAssertDemo() {
#ifdef DEBUG
    // Debug-only validation
    int testValue = 42;
    if (testValue != 42) {
        LOG_FATAL("ASSERTION FAILED: testValue != 42");
    } else {
        LOG_DEBUG("Debug assertion passed: testValue == %d", testValue);
    }

    // Memory/pointer validation example (debug only)
    void *ptr = malloc(100);
    if (ptr) {
        LOG_DEBUG("Memory allocation test: %p (100 bytes)", ptr);
        memset(ptr, 0, 100);
        free(ptr);
        LOG_DEBUG("Memory freed successfully");
    }
#endif
}

/**
 * @brief Print system information
 */
static void printSystemInfo() {
    struct utsname sysinfo;

    if (uname(&sysinfo) == 0) {
        LOG_INFO("===========================================");
        LOG_INFO("  %s v%s [%s]", PROJECT_NAME, PROJECT_VERSION_STRING, getBuildMode());
        LOG_INFO("===========================================");
        LOG_INFO("System:       %s", sysinfo.sysname);
        LOG_INFO("Node:         %s", sysinfo.nodename);
        LOG_INFO("Release:      %s", sysinfo.release);
        LOG_INFO("Machine:      %s", sysinfo.machine);
        LOG_INFO("Build Target: %s", getArchitectureName());
        LOG_INFO("Build Mode:   %s", getBuildMode());
        LOG_INFO("===========================================");
    } else {
        LOG_ERROR("uname() failed");
    }
}

/**
 * @brief Print user information
 */
static void printUserInfo() {
    // Check if running as root
    if (geteuid() == 0) {
        LOG_WARN("Running as root");
    } else {
        LOG_DEBUG("Running as user (UID: %d)", geteuid());
    }

    // Get the current user's login name
    char *username = getlogin();
    if (username != nullptr) {
        LOG_INFO("User: %s", username);
    } else {
        // Fallback to environment variable
        username = getenv("USER");
        if (username != nullptr) {
            LOG_INFO("User: %s (from env)", username);
        } else {
            LOG_WARN("User: Unknown");
        }
    }
}

/**
 * @brief Main application loop
 */
static void mainLoop() {
    LOG_INFO("Starting main loop (Ctrl+C to exit)...");

    int counter = 0;
    while (g_running) {
        // In release builds, only show every 10th iteration to reduce output
#ifdef DEBUG
        LOG_DEBUG("Counter: %d", counter);
#else
        if (counter % 10 == 0) {
            LOG_INFO("Counter: %d (release mode - showing every 10th)", counter);
        }
#endif
        counter++;

        // Debug-only: detailed trace logging
#ifdef DEBUG
        if (counter % 10 == 0) {
            LOG_TRACE("Periodic trace at counter=%d", counter);
        }
#endif

        usleep(LOOP_DELAY_US);
    }

    LOG_INFO("Main loop exited after %d iterations", counter);
}

int main(int argc, char *argv[]) {
    UNUSED(argc);
    UNUSED(argv);

    // Setup signal handlers for graceful shutdown
    signal(SIGINT, signalHandler);
    signal(SIGTERM, signalHandler);

    // Configure logger based on build mode
#ifdef DEBUG
    Logger::getInstance().setLevel(LogLevel::LVL_DEBUG);
    LOG_DEBUG("Logger configured for DEBUG build (showing DEBUG and above)");
#else
    Logger::getInstance().setLevel(LogLevel::LVL_INFO);
    LOG_INFO("Logger configured for RELEASE build (showing INFO and above)");
#endif

    LOG_INFO("Application starting...");

    // Show build information (debug only)
    printBuildInfo();

    // Run debug-only checks
    debugAssertDemo();

    // Show system and user info
    printSystemInfo();
    printUserInfo();

    // Run main application loop
    mainLoop();

    LOG_INFO("Application terminated gracefully");
    return EXIT_SUCCESS;
}
