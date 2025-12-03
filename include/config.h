/**
 * @file config.h
 * @brief Project configuration and common definitions
 *
 * This header contains project-wide configuration macros,
 * version information, and common type definitions.
 */

#ifndef CONFIG_H
#define CONFIG_H

// Project version
#define PROJECT_VERSION_MAJOR 1
#define PROJECT_VERSION_MINOR 0
#define PROJECT_VERSION_PATCH 0
#define PROJECT_VERSION_STRING "1.0.0"

// Project name
#define PROJECT_NAME "CrossCompile Template"

// Debug configuration
#ifdef DEBUG
#define DEBUG_PRINT(fmt, ...) \
    fprintf(stderr, "[DEBUG] %s:%d: " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
#define DEBUG_PRINT(fmt, ...) ((void)0)
#endif

// Utility macros
#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
#define UNUSED(x) ((void)(x))

// Timing constants (in microseconds)
#define LOOP_DELAY_US (500 * 1000)  // 500ms

// String buffer sizes
#define MAX_USERNAME_LEN 256
#define MAX_HOSTNAME_LEN 256

#endif  // CONFIG_H
