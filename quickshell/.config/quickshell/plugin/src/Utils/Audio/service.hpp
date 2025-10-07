/**
 * Base class for reference-counted services
 *
 * Provides lifecycle management for services that should only run when
 * actively referenced. Services start when first referenced and stop
 * when the last reference is removed.
 *
 * Used by: AudioCollector, AudioProvider (and their subclasses)
 */
#pragma once

#include <qobject.h>
#include <qset.h>

namespace utils::audio {

/**
 * Reference-counted service base class
 *
 * Manages service lifecycle based on active references. Child classes
 * must implement start() and stop() to define service behavior.
 */
class Service : public QObject {
    Q_OBJECT

public:
    explicit Service(QObject* parent = nullptr);

    /**
     * Add a reference to this service
     * Starts the service if this is the first reference
     */
    void ref(QObject* sender);

    /**
     * Remove a reference from this service
     * Stops the service if this was the last reference
     */
    void unref(QObject* sender);

private:
    QSet<QObject*> m_refs; // Set of active references

    virtual void start() = 0; // Start the service (implemented by child)
    virtual void stop() = 0;  // Stop the service (implemented by child)
};

} // namespace utils::audio
