/**
 * Cava audio visualizer provider
 *
 * CavaProvider captures system audio and analyzes it using the Cava library
 * to produce frequency spectrum data for visual representation.
 *
 * Features:
 *   - FFT-based audio frequency analysis (Cava library)
 *   - Configurable number of frequency bars
 *   - Monstercat smoothing filter for visual appeal
 *   - 60 FPS updates for smooth animation
 *
 * QML Usage:
 *   CavaProvider {
 *       bars: 64
 *       values: [0.0, 0.1, 0.3, ...]  // Read-only, updates 60x/sec
 *   }
 *
 * Used by: modules/dashboard/Media.qml, modules/notch/Content.qml
 */
#pragma once

#include "audioprovider.hpp"
#include <cava/cavacore.h>
#include <qqmlintegration.h>

namespace utils::audio {

/**
 * Cava audio processor (runs on separate thread)
 *
 * Processes audio chunks from AudioCollector, runs FFT analysis via Cava,
 * and applies smoothing filters for visualization.
 */
class CavaProcessor : public AudioProcessor {
    Q_OBJECT

public:
    explicit CavaProcessor(QObject* parent = nullptr);
    ~CavaProcessor();

    void setBars(int bars);  // Set number of frequency bars

signals:
    void valuesChanged(QVector<double> values);  // Emitted when bars update

protected:
    void process() override;  // Called 60x/sec to analyze audio

private:
    struct cava_plan* m_plan;  // Cava FFT plan
    double* m_in;              // Input buffer (audio samples)
    double* m_out;             // Output buffer (frequency bars)

    int m_bars;                 // Number of frequency bars
    QVector<double> m_values;   // Current bar values (0.0-1.0)

    void reload();     // Reinitialize Cava plan
    void initCava();   // Create Cava FFT plan
    void cleanup();    // Free Cava resources
};

/**
 * Cava visualizer service (QML-exposed)
 *
 * Provides audio frequency spectrum data to QML for visualization.
 * Manages CavaProcessor lifecycle on separate thread.
 */
class CavaProvider : public AudioProvider {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int bars READ bars WRITE setBars NOTIFY barsChanged)
    Q_PROPERTY(QVector<double> values READ values NOTIFY valuesChanged)

public:
    explicit CavaProvider(QObject* parent = nullptr);

    [[nodiscard]] int bars() const;        // Get number of bars
    void setBars(int bars);                // Set number of bars

    [[nodiscard]] QVector<double> values() const;  // Get bar values (0.0-1.0)

signals:
    void barsChanged();     // Emitted when bar count changes
    void valuesChanged();   // Emitted when bar values update (60 FPS)

private:
    int m_bars;                 // Number of frequency bars
    QVector<double> m_values;   // Current bar values (cached for QML)

    void updateValues(QVector<double> values);  // Update from processor
};

} // namespace utils::audio
