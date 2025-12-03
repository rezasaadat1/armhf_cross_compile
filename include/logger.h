/**
 * @file logger.h
 * @brief Simple logging class with formatted output
 *
 * Output format: YYYY-MM-DD HH:MM:SS LEVEL [function] [file:line] : message
 * Example: 2025-12-03 13:23:56 DEBUG [run] [PSApp.cpp:772] : pthread_create() for thread 6 returns: 0
 */

#ifndef LOGGER_H
#define LOGGER_H

#include <cstdio>
#include <cstdarg>
#include <ctime>
#include <cstring>

// Log levels
enum class LogLevel {
    LVL_TRACE = 0,
    LVL_DEBUG = 1,
    LVL_INFO  = 2,
    LVL_WARN  = 3,
    LVL_ERROR = 4,
    LVL_FATAL = 5
};

class Logger {
public:
    // Get singleton instance
    static Logger& getInstance() {
        static Logger instance;
        return instance;
    }

    // Set minimum log level
    void setLevel(LogLevel level) {
        minLevel_ = level;
    }

    // Set output file (default is stdout)
    void setOutput(FILE *output) {
        output_ = output;
    }

    // Main log function
    void log(LogLevel level, const char *func, const char *file, int line,
             const char *fmt, ...) {
        if (level < minLevel_) {
            return;
        }

        // Get timestamp
        char timestamp[32];
        getTimestamp(timestamp, sizeof(timestamp));

        // Get just the filename (not full path)
        const char *filename = getFilename(file);

        // Print header: timestamp + level + function + file:line
        fprintf(output_, "%s %s [%s] [%s:%d] : ",
                timestamp,
                levelToString(level),
                func,
                filename,
                line);

        // Print message
        va_list args;
        va_start(args, fmt);
        vfprintf(output_, fmt, args);
        va_end(args);

        fprintf(output_, "\n");
        fflush(output_);
    }

private:
    Logger() : minLevel_(LogLevel::LVL_DEBUG), output_(stdout) {}
    ~Logger() = default;

    // Non-copyable
    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;

    static const char* levelToString(LogLevel level) {
        switch (level) {
            case LogLevel::LVL_TRACE: return "TRACE";
            case LogLevel::LVL_DEBUG: return "DEBUG";
            case LogLevel::LVL_INFO:  return "INFO ";
            case LogLevel::LVL_WARN:  return "WARN ";
            case LogLevel::LVL_ERROR: return "ERROR";
            case LogLevel::LVL_FATAL: return "FATAL";
            default:                  return "?????";
        }
    }

    static void getTimestamp(char *buffer, size_t size) {
        time_t now = time(nullptr);
        struct tm *tm_info = localtime(&now);
        strftime(buffer, size, "%Y-%m-%d %H:%M:%S", tm_info);
    }

    static const char* getFilename(const char *path) {
        const char *slash = strrchr(path, '/');
        if (slash) {
            return slash + 1;
        }
        const char *backslash = strrchr(path, '\\');
        if (backslash) {
            return backslash + 1;
        }
        return path;
    }

    LogLevel minLevel_;
    FILE *output_;
};

// Convenience macros for logging
// Use __VA_OPT__ for C++20, or the GNU extension ##__VA_ARGS__ for older standards
#define LOG_TRACE(...) \
    Logger::getInstance().log(LogLevel::LVL_TRACE, __func__, __FILE__, __LINE__, __VA_ARGS__)

#define LOG_DEBUG(...) \
    Logger::getInstance().log(LogLevel::LVL_DEBUG, __func__, __FILE__, __LINE__, __VA_ARGS__)

#define LOG_INFO(...) \
    Logger::getInstance().log(LogLevel::LVL_INFO, __func__, __FILE__, __LINE__, __VA_ARGS__)

#define LOG_WARN(...) \
    Logger::getInstance().log(LogLevel::LVL_WARN, __func__, __FILE__, __LINE__, __VA_ARGS__)

#define LOG_ERROR(...) \
    Logger::getInstance().log(LogLevel::LVL_ERROR, __func__, __FILE__, __LINE__, __VA_ARGS__)

#define LOG_FATAL(...) \
    Logger::getInstance().log(LogLevel::LVL_FATAL, __func__, __FILE__, __LINE__, __VA_ARGS__)

#endif  // LOGGER_H
