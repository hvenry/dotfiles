/**
 * ServiceRef implementation
 *
 * Manages QML-side service references with automatic lifecycle handling.
 */
#include "serviceref.hpp"

#include "service.hpp"

namespace utils::audio {

/**
 * Constructor - automatically refs the service
 */
ServiceRef::ServiceRef(Service* service, QObject* parent)
    : QObject(parent)
    , m_service(service) {
    if (m_service) {
        m_service->ref(this);
    }
}

/**
 * Get the referenced service
 */
Service* ServiceRef::service() const {
    return m_service;
}

/**
 * Set a new service to reference
 *
 * Unrefs old service and refs new service.
 * Called when QML property binding changes.
 */
void ServiceRef::setService(Service* service) {
    if (m_service == service) {
        return;
    }

    // Unref old service
    if (m_service) {
        m_service->unref(this);
    }

    m_service = service;
    emit serviceChanged();

    // Ref new service
    if (m_service) {
        m_service->ref(this);
    }
}

} // namespace utils::audio
