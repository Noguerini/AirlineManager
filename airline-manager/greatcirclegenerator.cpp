#include "greatcirclegenerator.h"
#include <cmath>

GreatCircleGenerator::GreatCircleGenerator(QObject *parent)
    : QObject(parent) {}

double GreatCircleGenerator::toRadians(double degrees)
{
    return degrees * PI / 180.0;
}

double GreatCircleGenerator::toDegrees(double radians)
{
    return radians * 180.0 / PI;
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
