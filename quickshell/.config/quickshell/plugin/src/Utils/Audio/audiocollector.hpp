/**
 * PipeWire audio capture service
 *
 * AudioCollector is a singleton service that captures system audio via PipeWire
 * and provides it to audio processors (like CavaProvider) in real-time.
 *
 * Architecture:
 *   PipeWire Stream (capture sink) → PipeWireWorker (thread) → Ring Buffer → Audio Processors
 *
 * Features:
 *   - Thread-safe lock-free ring buffer for audio samples
 *   - 44.1kHz sample rate, 512 sample chunks
 *   - Automatic stream management (starts/stops based on refs)
 *
 * Used by: CavaProvider (reads audio chunks for visualization)
 */
#pragma once

#include "service.hpp"
#include <atomic>
#include <pipewire/pipewire.h>
#include <qmutex.h>
#include <qqmlintegration.h>
#include <spa/param/audio/format-utils.h>
#include <stop_token>
#include <thread>
#include <vector>

namespace utils::audio {

// Audio capture constants
namespace ac {

constexpr quint32 SAMPLE_RATE = 44100; // Samples per second
constexpr quint32 CHUNK_SIZE = 512;    // Samples per chunk

} // namespace ac

class AudioCollector;

/**
 * PipeWire audio stream worker (runs on separate thread)
 *
 * Creates and manages PipeWire audio stream, capturing system audio
 * and feeding it to AudioCollector's ring buffer.
 */
class PipeWireWorker {
public:
    explicit PipeWireWorker(std::stop_token token, AudioCollector* collector);

    void run();

private:
    pw_main_loop* m_loop;   // PipeWire main loop
    pw_stream* m_stream;    // Audio capture stream
    spa_source* m_timer;    // Timeout timer for idle detection
    bool m_idle;            // Whether stream is currently idle

    std::stop_token m_token;      // Thread stop token
    AudioCollector* m_collector;  // Parent collector

    static void handleTimeout(void* data, uint64_t expirations);
    void streamStateChanged(pw_stream_state state);
    void processStream();  // Called by PipeWire when audio data available

    [[nodiscard]] unsigned int nextPowerOf2(unsigned int n);
};

/**
 * Audio collector singleton service
 *
 * Captures system audio via PipeWire and provides lock-free ring buffer
 * access for audio processors. Thread-safe for concurrent reads/writes.
 */
class AudioCollector : public Service {
    Q_OBJECT

public:
    AudioCollector(const AudioCollector&) = delete;
    AudioCollector& operator=(const AudioCollector&) = delete;

    static AudioCollector& instance();

    void clearBuffer();  // Zero out the audio buffer
    void loadChunk(const qint16* samples, quint32 count);  // Write samples (from PipeWire)
    quint32 readChunk(float* out, quint32 count = 0);      // Read as float (for Cava)
    quint32 readChunk(double* out, quint32 count = 0);     // Read as double

private:
    explicit AudioCollector(QObject* parent = nullptr);
    ~AudioCollector();

    std::jthread m_thread;  // PipeWire worker thread

    // Lock-free ring buffer (double buffering)
    std::vector<float> m_buffer1;
    std::vector<float> m_buffer2;
    std::atomic<std::vector<float>*> m_readBuffer;   // Current read buffer
    std::atomic<std::vector<float>*> m_writeBuffer;  // Current write buffer
    quint32 m_sampleCount;

    void reload();
    void start() override;  // Start PipeWire capture thread
    void stop() override;   // Stop PipeWire capture thread
};

} // namespace utils::audio
