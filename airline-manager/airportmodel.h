#pragma once
#include <QAbstractListModel>
#include <QGeoCoordinate>
#include <QVector>

struct Airport {
    QString name;
    QString iata;
    QGeoCoordinate coord;
    QString size;
};

class AirportModel : public QAbstractListModel {
    Q_OBJECT
        Q_PROPERTY(QString sizeFilter READ sizeFilter WRITE setSizeFilter NOTIFY sizeFilterChanged)
public:
    enum Roles { NameRole = Qt::UserRole + 1, IataRole, CoordinateRole, SizeRole };

    explicit AirportModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString sizeFilter() const { return m_sizeFilter; }
    void setSizeFilter(const QString& f);

signals:
    void sizeFilterChanged();

private:
    void loadFromResource(const QString& path);
    void rebuildVisible();

    QVector<Airport> m_all;
    QVector<Airport> m_visible;
    QString m_sizeFilter = "large_airport";
};