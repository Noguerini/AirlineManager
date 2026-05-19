#pragma once

#include <QObject>
#include <QGeoCoordinate>
#include <QList>
#include <QHash>
#include <QString>
#include <QStringList>
#include <QVariantMap>

struct AircraftSpec {
    QString name;
    double cruise_speed_kmh = 0.0;
    double fuel_burn_kgh = 0.0;
    int passengers = 0;
    double max_range_km = 0.0;
    double crew_cost_per_hour = 0.0;
};

class GreatCircleGenerator : public QObject {
    Q_OBJECT

public:
    explicit GreatCircleGenerator(QObject *parent = nullptr);

    Q_INVOKABLE QList<QGeoCoordinate> calculatePath(QGeoCoordinate start, QGeoCoordinate end, int numPoints) const;
    Q_INVOKABLE QVariantMap calculateRouteDetails(QGeoCoordinate start, QGeoCoordinate end, const QString &aircraft) const;
    Q_INVOKABLE QStringList availableAircraft() const;

private:
    static constexpr double PI = 3.14159265358979323846;
    static constexpr double EARTH_RADIUS_KM = 6371.0;
    static constexpr double CO2_PER_KG_FUEL = 3.16;
    static constexpr double TAXI_AND_OVERHEAD_HOURS = 0.5;
    static constexpr double FUEL_PRICE_PER_KG = 0.85;
    static constexpr double NAV_COST_PER_KM = 0.6;
    static constexpr double TICKET_PER_PAX_PER_KM = 0.12;

    static double toRadians(double degrees);
    static double toDegrees(double radians);
    static double greatCircleDistanceKm(QGeoCoordinate start, QGeoCoordinate end);

    void loadAircraftData(const QString &path);

    QHash<QString, AircraftSpec> m_aircraft;
};
