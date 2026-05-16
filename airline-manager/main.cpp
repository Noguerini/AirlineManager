#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "airportmodel.h"
#include "greatcirclegenerator.h"

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN) && QT_VERSION_CHECK(5, 6, 0) <= QT_VERSION && QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    AirportModel airports;
    engine.rootContext()->setContextProperty("airportModel", &airports);

    GreatCircleGenerator gcgenerator;
    engine.rootContext()->setContextProperty("gcgeneratorModel", &gcgenerator);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/airline-manager/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
