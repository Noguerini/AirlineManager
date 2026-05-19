#include "greatcirclegenerator.h"
#include <QFile>
#include <QTextStream>
#include <cmath>

GreatCircleGenerator::GreatCircleGenerator(QObject *parent)
    : QObject(parent)
{
    loadAircraftData(":/qt/qml/airline-manager/aircraft.csv");
}

double GreatCircleGenerator::toRadians(double degrees)
{
    return degrees * PI / 180.0;
}

double GreatCircleGenerator::toDegrees(double radians)
{
    return radians * 180.0 / PI;
}

double GreatCircleGenerator::greatCircleDistanceKm(QGeoCoordinate start, QGeoCoordinate end)
{
    double lat1 = toRadians(start.latitude());
    double lon1 = toRadians(start.longitude());
    double lat2 = toRadians(end.latitude());
    double lon2 = toRadians(end.longitude());

    double a = std::pow(std::sin((lat2 - lat1) / 2.0), 2) +
               std::cos(lat1) * std::cos(lat2) * std::pow(std::sin((lon2 - lon1) / 2.0), 2);
    double d = 2.0 * std::asin(std::sqrt(a));

    return d * EARTH_RADIUS_KM;
}

QList<QGeoCoordinate> GreatCircleGenerator::calculatePath(QGeoCoordinate start, QGeoCoordinate end, int numPoints) const
{
    QList<QGeoCoordinate> points;

    if (numPoints <= 0) return points;
    if (numPoints == 1) {
        points.push_back(start);
        return points;
    }

    double lat1 = toRadians(start.latitude());
    double lon1 = toRadians(start.longitude());
    double lat2 = toRadians(end.latitude());
    double lon2 = toRadians(end.longitude());

    double a = std::pow(std::sin((lat2 - lat1) / 2.0), 2) +
               std::cos(lat1) * std::cos(lat2) * std::pow(std::sin((lon2 - lon1) / 2.0), 2);
    double d = 2.0 * std::asin(std::sqrt(a));

    if (d < 1e-10) {
        for (int i = 0; i < numPoints; ++i)
            points.push_back(start);
        return points;
    }

    for (int i = 0; i < numPoints; ++i) {
        double f = static_cast<double>(i) / (numPoints - 1);

        double A = std::sin((1.0 - f) * d) / std::sin(d);
        double B = std::sin(f * d) / std::sin(d);

        double x = A * std::cos(lat1) * std::cos(lon1) + B * std::cos(lat2) * std::cos(lon2);
        double y = A * std::cos(lat1) * std::sin(lon1) + B * std::cos(lat2) * std::sin(lon2);
        double z = A * std::sin(lat1) + B * std::sin(lat2);

        double lat_i = std::atan2(z, std::sqrt(x * x + y * y));
        double lon_i = std::atan2(y, x);

        points.push_back({ toDegrees(lat_i), toDegrees(lon_i) });
    }

    return points;
}

void GreatCircleGenerator::loadAircraftData(const QString &path)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Cannot open" << path;
        return;
    }
    QTextStream in(&f);
    bool header = true;
    while (!in.atEnd()) {
        const QString line = in.readLine();
        if (header) { header = false; continue; }
        if (line.trimmed().isEmpty()) continue;
        const QStringList c = line.split(',');
        if (c.size() < 6) continue;
        AircraftSpec a;
        a.name = c[0].trimmed();
        a.cruise_speed_kmh = c[1].toDouble();
        a.fuel_burn_kgh = c[2].toDouble();
        a.passengers = c[3].toInt();
        a.max_range_km = c[4].toDouble();
        a.crew_cost_per_hour = c[5].toDouble();
        m_aircraft.insert(a.name, a);
    }
}

QStringList GreatCircleGenerator::availableAircraft() const
{
    QStringList names = m_aircraft.keys();
    names.sort();
    return names;
}

QVariantMap GreatCircleGenerator::calculateRouteDetails(QGeoCoordinate start, QGeoCoordinate end, const QString &aircraft) const
{
    QVariantMap result;
    if (!m_aircraft.contains(aircraft)) return result;
    const AircraftSpec &a = m_aircraft.value(aircraft);

    const double distance = greatCircleDistanceKm(start, end);
    const double total_time = distance / a.cruise_speed_kmh + TAXI_AND_OVERHEAD_HOURS;
    const double fuel_quantity = a.fuel_burn_kgh * total_time;
    const double fuel_cost = fuel_quantity * FUEL_PRICE_PER_KG;
    const double emissions = fuel_quantity * CO2_PER_KG_FUEL;
    const double nav_cost = distance * NAV_COST_PER_KM;
    const double crew_cost = total_time * a.crew_cost_per_hour;
    const double revenue = a.passengers * TICKET_PER_PAX_PER_KM * distance;
    const double cost = fuel_cost + nav_cost + crew_cost;
    const double profit = revenue - cost;

    result["aircraft"] = a.name;
    result["passengers"] = a.passengers;
    result["in_range"] = distance <= a.max_range_km;
    result["distance"] = distance;
    result["total_time"] = total_time;
    result["fuel_quantity"] = fuel_quantity;
    result["fuel_cost"] = fuel_cost;
    result["emissions"] = emissions;
    result["navigation_services_cost"] = nav_cost;
    result["crew_cost"] = crew_cost;
    result["revenue"] = revenue;
    result["cost"] = cost;
    result["profit"] = profit;
    return result;
}
