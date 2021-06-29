#include "trigeometry.h"

#include <igl/read_triangle_mesh.h>
#include <igl/per_vertex_normals.h>

TriangleGeometry::TriangleGeometry()
{
    clear();
}

void TriangleGeometry::load(const QUrl &fileurl)
{
    std::cout << "loading file: " << fileurl.path().toStdString() << std::endl;
    igl::read_triangle_mesh(fileurl.path().toStdString(), m_v, m_f);
    igl::per_vertex_normals(m_v, m_f, m_n);
    std::cout << m_v.rows() << " " << m_f.rows() << std::endl;
    updateData();
}

//! [update data]
void TriangleGeometry::updateData()
{
    clear();

    int stride = 3 * sizeof(float); // positions
    stride += 3 * sizeof(float); // normals
    // if (m_hasUV)
    //     stride += 2 * sizeof(float);

    QByteArray indexData(3 * m_f.rows() * sizeof(uint32_t), Qt::Initialization::Uninitialized);
    QByteArray vertexData(m_v.rows() * stride, Qt::Initialization::Uninitialized);
    float *p = reinterpret_cast<float *>(vertexData.data());
    uint32_t *indices = reinterpret_cast<uint32_t*>(indexData.data());

    for (int i = 0; i < m_v.rows(); ++i) {
        auto v = m_v.row(i);
        auto n = m_n.row(i);
        *p++ = v[0];
        *p++ = v[1];
        *p++ = v[2];
        *p++ = n[0];
        *p++ = n[1];
        *p++ = n[2];
    }

    for (int i = 0; i < m_f.rows(); ++i) {
        auto f = m_f.row(i);
        for (int j = 0; j < 3; ++j) {
            *indices++ = f[j];
        }
    }

    // a triangle, front face = counter-clockwise
    // *p++ = -1.0f; *p++ = -1.0f; *p++ = 0.0f;
    // if (m_hasNormals) {
    //     *p++ = m_normalXY; *p++ = m_normalXY; *p++ = 1.0f;
    // }
    // if (m_hasUV) {
    //     *p++ = 0.0f + m_uvAdjust; *p++ = 0.0f + m_uvAdjust;
    // }
    // *p++ = 1.0f; *p++ = -1.0f; *p++ = 0.0f;
    // if (m_hasNormals) {
    //     *p++ = m_normalXY; *p++ = m_normalXY; *p++ = 1.0f;
    // }
    // if (m_hasUV) {
    //     *p++ = 1.0f - m_uvAdjust; *p++ = 0.0f + m_uvAdjust;
    // }
    // *p++ = 0.0f; *p++ = 1.0f; *p++ = 0.0f;
    // if (m_hasNormals) {
    //     *p++ = m_normalXY; *p++ = m_normalXY; *p++ = 1.0f;
    // }
    // if (m_hasUV) {
    //     *p++ = 1.0f - m_uvAdjust; *p++ = 1.0f - m_uvAdjust;
    // }

    setIndexData(indexData);
    setVertexData(vertexData);
    setStride(stride);

    setPrimitiveType(QQuick3DGeometry::PrimitiveType::Triangles);

    addAttribute(QQuick3DGeometry::Attribute::PositionSemantic,
                 0,
                 QQuick3DGeometry::Attribute::F32Type);
    addAttribute(QQuick3DGeometry::Attribute::NormalSemantic,
                 3 * sizeof(float),
                 QQuick3DGeometry::Attribute::F32Type);

    addAttribute(QQuick3DGeometry::Attribute::IndexSemantic,
                 0,
                 QQuick3DGeometry::Attribute::U32Type);

    // if (m_hasNormals) {
    //     addAttribute(QQuick3DGeometry::Attribute::NormalSemantic,
    //                  3 * sizeof(float),
    //                  QQuick3DGeometry::Attribute::F32Type);
    // }

    // if (m_hasUV) {
    //     addAttribute(QQuick3DGeometry::Attribute::TexCoordSemantic,
    //                  m_hasNormals ? 6 * sizeof(float) : 3 * sizeof(float),
    //                  QQuick3DGeometry::Attribute::F32Type);
    // }
    emit geometryUpdated();
    update();
}

float TriangleGeometry::boundingRadius() const
{
    auto min = m_v.colwise().minCoeff();
    auto max = m_v.colwise().maxCoeff();
    Eigen::Vector3f absdiff;
    for (int i = 0; i < 3; ++i) {
        absdiff[i] = std::max(fabs(min[i]), fabs(max[i]));
    }

    float r = absdiff.maxCoeff();
    return r;
}

//! [update data]
