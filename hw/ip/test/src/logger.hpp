// Copyleft
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

#ifndef _LOGGERKLSLLS_DSPOWE_H_
#define _LOGGERKLSLLS_DSPOWE_H_

// C++ Header File(s)
#include <fstream>
#include <iostream>
#include <ostream>
#include <sstream>
#include <string>

template <typename T>
class TD;
/***
detected the type of a variable
auto numbers = std::vector<int>{ 0, 2, -3, 5, -1, 6, 8, -4, 9 };
 TD<decltype(numbers) > h; <- hover over it, the type is revealed in the error
messsage
                           <- compile it, generates a compiler error, the type
is revealed in that error messsage
**/

#ifdef WIN32
// Win Socket Header File(s)
#include <Windows.h>
#include <process.h>
#else
// POSIX Socket Header File(s)
#include <errno.h>
#include <pthread.h>
#endif

namespace isolde {

// forward declaration
template <typename T>
class Logger;
struct LoggerInterface;

#define DECLARE_LOGGER(class, fileName)           \
    namespace {                                   \
    struct class##_LogFile {                      \
        static constexpr char name[] = fileName; \
    };                                            \
    using class = isolde::Logger<class##_LogFile>; \
    };

struct LoggerInterface {
    virtual void info(const char *file, int line, std::string &text) = 0;
    virtual void info(const char *text) = 0;
    virtual void info(const char *file, int line, const char *text = 0) = 0;
    virtual void info(std::ostringstream &stream) = 0;
    virtual int lock() = 0;
    virtual int unlock() = 0;
};

template <typename T>
class Logger : public LoggerInterface {
   public:
    static Logger<T> &getInstance() {
        static Logger<T> theLogger;
        return theLogger;
    };

    void header(std::ostringstream &stream) {
        static bool hasHeader = false;
        if (!hasHeader) {
            hasHeader = true;
            info(stream);
        }
    }

    struct filestream : private std::ofstream {
        filestream() : lockCounter(0) {}

        void flush() {
            std::ofstream &of = reinterpret_cast<std::ofstream &>(*this);
            of.flush();
        }

        void open(const char *__s, ios_base::openmode __mode = ios_base::out) {
            std::ofstream &of = reinterpret_cast<std::ofstream &>(*this);
            of.open(__s, __mode);
        }

        void close() {
            std::ofstream &of = reinterpret_cast<std::ofstream &>(*this);
            of.close();
        }

        template <typename OpType>
        filestream &operator<<(OpType op) {
            std::ofstream &of = reinterpret_cast<std::ofstream &>(*this);
            if (0 == lockCounter) of << op;
            return *this;
        }

        filestream &operator<<(std::string &op) {
            std::ofstream &of = reinterpret_cast<std::ofstream &>(*this);
            if (0 == lockCounter) of << op;
            return *this;
        }
        unsigned int lockCounter;
        unsigned int lock() {
            lockCounter += 1;
            return lockCounter;
        }
        unsigned int ulock() {
            if (lockCounter) lockCounter -= 1;
            return lockCounter;
        }
    };

    struct Lock {
        Logger<T> &_logger;
        Lock(Logger<T> &logger) : _logger(logger) {
#ifdef WIN32
            EnterCriticalSection(&m_Mutex);
#else
            pthread_mutex_lock(&_logger.m_Mutex);
#endif
        }

        ~Lock() {
#ifdef WIN32
            LeaveCriticalSection(&m_Mutex);
#else
            pthread_mutex_unlock(&_logger.m_Mutex);
#endif
        }
    };

    // Interface for Info Log
    int lock() override final { return m_File.lock(); }
    int unlock() override final { return m_File.ulock(); }
    void info(const char *file, int line, std::string &text) override {
        Lock l(*this);
        trace(file, line, text.c_str());
        m_File << text << "   " << file << ":" << line << "\n";
        m_File.flush();
    }
    // Interface for Info Log
    void info(const char *file, int line, const char *text = 0) override {
        Lock l(*this);
        trace(file, line, text);
        m_File << "#" << file << ":" << line << " ";
        if (text) std::cout << text;
        m_File << "\n";
        m_File.flush();
    }
    void info(const char *text) override {
        Lock l(*this);
        m_File << text << "\n";
        m_File.flush();
    };
    void info(std::string &text) {
        Lock l(*this);
        m_File << text << "\n";
        m_File.flush();
    };
    void info(std::ostringstream &stream) override {
        std::string text = stream.str();
        Lock l(*this);
        // m_File<<text<< "\n";
        m_File << text;
        m_File.flush();
    }

    // Interface for Trace log
    void trace(const char *file, int line, const char *text = 0) {
        Lock l(*this);
        std::cout << file << ":" << line << "** ";
        if (text) std::cout << text;
        std::cout << "\n";
    }

    void trace(const char *file, const char *line, std::string &text) {
        Lock l(*this);
        std::cout << file << ":" << line << "** ";
        std::cout << text;
        std::cout << "\n";
    }

    void trace(const char *file, const char *line, std::ostringstream &stream) {
        Lock l(*this);
        std::cout << file << ":" << line << "** ";
        std::cout << stream.str();
        std::cout << "\n";
    }

    // Interface for Debug log

   protected:
    Logger() {
        std::string logFileName(T::name);
        m_File.open(logFileName.c_str(), std::ios::out | std::ios::trunc);
// Initialize mutex
#ifdef WIN32
        InitializeCriticalSection(&m_Mutex);
#else
        int ret = 0;
        ret = pthread_mutexattr_settype(&m_Attr, PTHREAD_MUTEX_ERRORCHECK_NP);
        if (ret != 0) {
            printf("Logger::Logger() -- Mutex attribute not initialize!!\n");
            exit(0);
        }
        ret = pthread_mutex_init(&m_Mutex, &m_Attr);
        if (ret != 0) {
            printf("Logger::Logger() -- Mutex not initialize!!\n");
            exit(0);
        }
#endif
    }
    ~Logger() {
        m_File.close();
#ifdef WIN32
        DeleteCriticalSection(&m_Mutex);
#else
        pthread_mutexattr_destroy(&m_Attr);
        pthread_mutex_destroy(&m_Mutex);
#endif
    }
    friend struct Lock;

   protected:
    filestream m_File;
#ifdef WIN32
    CRITICAL_SECTION m_Mutex;
#else
    pthread_mutexattr_t m_Attr;
    pthread_mutex_t m_Mutex;
#endif
};

}  // namespace isolde

#endif  // End of _LOGGER_H_