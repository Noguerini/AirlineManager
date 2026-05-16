#pragma once

#include <QObject>
#include <QGeoCoordinate>
#include <QList>

class GreatCircleGenerator : public QObject {
    Q_OBJECT

public:
    explicit GreatCircleGenerator(QObject *parent = nullptr);

    Q_INVOKABLE QList<QGeoCoordinate> calculatePath(QGeoCoordinate start, QGeoCoordinate end, int numPoints) const;

private:
    static constexpr double PI = 3.14159265358979323846;

    static double toRadians(double degrees);
    static double toDegrees(double radians);
};
