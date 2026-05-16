#include "airportmodel.h"
#include <QFile>
#include <QTextStream>
#include <iostream>

using namespace std;

AirportModel::AirportModel(QObject* parent) : QAbstractListModel(parent) {
    loadFromResource(":/qt/qml/airline-manager/airports.csv");
    rebuildVisible();
}

void AirportModel::loadFromResource(const QString& path) {
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Cannot open" << path;
        return;
    }
    QTextStream in(&f);
    bool header = true;
    while (!in.atEnd()) {
        const QString line = in.readLine();
        if (header) { header = false; continue; }      // skip "name,type,..."
        const QStringList c = line.split(',');
        if (c.size() < 5) continue;
        Airport a;
        auto unquote = [](QString s) { s.remove('"'); return s.trimmed(); };
        a.name = unquote(c[3]);
        a.iata = unquote(c[13]);
        a.coord = QGeoCoordinate(c[4].toDouble(), c[5].toDouble());
        a.size = unquote(c[2]);
        m_all.push_back(a);
    }
}

void AirportModel::rebuildVisible() {
    beginResetModel();
    m_visible.clear();
    for (const auto& a : m_all)
        if (m_sizeFilter.isEmpty() || a.size == m_sizeFilter)
            m_visible.push_back(a);
    endResetModel();
}

void AirportModel::setSizeFilter(const QString& f) {
    if (f == m_sizeFilter) return;
    m_sizeFilter = f;
    emit sizeFilterChanged();
    rebuildVisible();
}

int AirportModel::rowCount(const QModelIndex&) const { return m_visible.size(); }

QVariant AirportModel::data(const QModelIndex& idx, int role) const {
    if (!idx.isValid() || idx.row() >= m_visible.size()) return {};
    const Airport& a = m_visible[idx.row()];
    switch (role) {
    case NameRole:       return a.name;
    case IataRole:       return a.iata;
    case CoordinateRole: return QVariant::fromValue(a.coord);
    case SizeRole:       return a.size;
    }
    return {};
}

QHash<int, QByteArray> AirportModel::roleNames() const {
	cout << "AirportModel::roleNames() called" << endl;
    return { {NameRole, "name"}, {IataRole, "iata"},
             {CoordinateRole, "coordinate"}, {SizeRole, "size"} };
}

QStringList AirportModel::allIataCodes() const {
    QStringList list;
    for (const auto& a : m_visible)
        list.append(a.iata);
    return list;
}

QStringList AirportModel::allNames() const {
    QStringList list;
    for (const auto& a : m_visible)
        list.append(a.name);
    return list;
}

QGeoCoordinate AirportModel::coordinateFromIATA(const QString &iata_code) const {
    for (const auto& a : m_visible) {
        if (a.iata == iata_code)
            return a.coord;
    }
    return {};
}