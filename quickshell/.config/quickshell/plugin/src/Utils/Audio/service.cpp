/**
 * Reference-counted service implementation
 *
 * Manages service lifecycle based on active references.
 * Automatically starts service on first reference and stops on last removal.
 */
#include "service.hpp"

#include <qdebug.h>
#include <qpointer.h>

namespace utils::audio {

Service::Service(QObject* parent)
    : QObject(parent) {}

/**
 * Add a reference to the service
 *
 * Starts the service if this is the first reference.
 * Connects to sender's destroyed signal to auto-cleanup.
 */
void Service::ref(QObject* sender) {
    // Start service on first reference
    if (m_refs.isEmpty()) {
        start();
    }

    // Auto-cleanup when sender is destroyed
    QObject::connect(sender, &QObject::destroyed, this, &Service::unref);
    m_refs << sender;
}

/**
 * Remove a reference from the service
 *
 * Stops the service if this was the last reference.
 */
void Service::unref(QObject* sender) {
    // Stop service when last reference removed
    if (m_refs.remove(sender) && m_refs.isEmpty()) {
        stop();
    }
}

} // namespace utils::audio
