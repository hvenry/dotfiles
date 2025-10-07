/**
 * QML component for managing service lifecycle
 *
 * ServiceRef keeps a Service alive by maintaining a reference to it.
 * When a ServiceRef is created/visible, it refs the service (starting it).
 * When destroyed/hidden, it unrefs the service (stopping it if no other refs).
 *
 * Usage in QML:
 *   ServiceRef {
 *       service: Audio.cava  // Keeps Cava running while this exists
 *   }
 *
 * Used by: modules/dashboard/Media.qml, modules/notch/Content.qml
 */
#pragma once

#include "service.hpp"
#include <qpointer.h>
#include <qqmlintegration.h>

namespace utils::audio {

/**
 * QML-accessible service reference holder
 *
 * Automatically refs the service on construction and unrefs on destruction.
 * Provides QML property binding for dynamic service management.
 */
class ServiceRef : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(Service* service READ service WRITE setService NOTIFY serviceChanged)

public:
    explicit ServiceRef(Service* service = nullptr, QObject* parent = nullptr);

    [[nodiscard]] Service* service() const;
    void setService(Service* service);

signals:
    void serviceChanged();

private:
    QPointer<Service> m_service; // Weak pointer to service (auto-nulls if service destroyed)
};

} // namespace utils::audio
