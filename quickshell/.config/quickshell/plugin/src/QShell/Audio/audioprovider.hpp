/**
 * Base classes for audio processing services
 *
 * AudioProcessor - Base for processors that run on separate thread
 * AudioProvider - Service wrapper that manages processor lifecycle
 *
 * Architecture:
 *   AudioProvider (Service) → manages thread
 *   AudioProcessor → runs on thread, processes audio at 60 FPS
 *   Child classes implement process() to do actual work
 *
 * Used by: CavaProvider (audio visualization)
 */
#pragma once

#include "service.hpp"
#include <qqmlintegration.h>
#include <qtimer.h>

namespace caelestia::services {

/**
 * Base audio processor (runs on separate thread)
 *
 * Provides timer-driven processing at 60 FPS. Child classes
 * implement process() to handle audio data each frame.
 */
class AudioProcessor : public QObject {
    Q_OBJECT

public:
    explicit AudioProcessor(QObject* parent = nullptr);
    ~AudioProcessor();

    void init();

public slots:
    void start();  // Start processing timer
    void stop();   // Stop processing timer

protected:
    virtual void process() = 0;  // Called 60 times/sec (implemented by child)

private:
    QTimer* m_timer;  // 60 FPS processing timer
};

/**
 * Audio provider service base class
 *
 * Manages AudioProcessor lifecycle on separate thread.
 * Ensures processor starts/stops with ref-counting.
 */
class AudioProvider : public Service {
    Q_OBJECT

public:
    explicit AudioProvider(QObject* parent = nullptr);
    ~AudioProvider();

protected:
    AudioProcessor* m_processor;  // Processor instance (created by child)

    void init();  // Initialize processor on thread

private:
    QThread* m_thread;  // Processing thread

    void start() override;  // Start processor thread
    void stop() override;   // Stop processor thread
};

} // namespace caelestia::services
