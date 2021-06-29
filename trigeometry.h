#pragma once

#include <QQuick3DGeometry>

#include <Eigen/Core>

//! [triangle geometry]
class TriangleGeometry : public QQuick3DGeometry
{
    Q_OBJECT
    QML_NAMED_ELEMENT(TriangleGeometry)

public:
    TriangleGeometry();

public slots:
    void load(const QUrl &fileurl);

signals:
    void geometryUpdated();

private:
    void updateData();

    Eigen::MatrixXf m_v;
    Eigen::MatrixXf m_n;
    Eigen::MatrixXi m_f;
};
//! [triangle geometry]
