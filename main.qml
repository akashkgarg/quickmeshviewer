import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import QtQuick3D.Helpers
import QuickMeshViewer

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    color: "#848895"

    View3D {
        id: v3d
        anchors.fill: parent
        camera: camera

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 0, 600)
            pivot: Qt.vector3d(0, 0, 0)
        }

        DirectionalLight {
            position: Qt.vector3d(-500, 500, -100)
            color: Qt.rgba(0.4, 0.2, 0.6, 1.0)
            ambientColor: Qt.rgba(0.1, 0.1, 0.1, 1.0)
        }

        PointLight {
            position: Qt.vector3d(0, 0, 100)
            color: Qt.rgba(0.1, 1.0, 0.1, 1.0)
            ambientColor: Qt.rgba(0.2, 0.2, 0.2, 1.0)
        }

        Model {
            visible: radioGridGeom.checked
            scale: Qt.vector3d(100, 100, 100)
            geometry: GridGeometry {
                id: grid
                horizontalLines: 20
                verticalLines: 20
            }
            materials: [
                DefaultMaterial {
                    lineWidth: sliderLineWidth.value
                }
            ]
        }

        //! [model triangle]
        Model {
            visible: radioCustGeom.checked
            scale: Qt.vector3d(100, 100, 100)
            geometry: ExampleTriangleGeometry {
                normals: cbNorm.checked
                normalXY: sliderNorm.value
                uv: cbUV.checked
                uvAdjust: sliderUV.value
            }
            materials: [
                DefaultMaterial {
                    Texture {
                        id: baseColorMap
                        source: "qt_logo_rect.png"
                    }
                    cullMode: DefaultMaterial.NoCulling
                    diffuseMap: cbTexture.checked ? baseColorMap : null
                    specularAmount: 0.5
                }
            ]
        }
        //! [model triangle]

        Model {
            visible: true
            scale: Qt.vector3d(100, 100, 100)
            geometry: TriangleGeometry {
            }
            materials: [
                CustomMaterial {
                    property TextureInput tex: TextureInput {
                        enabled: true
                        texture: Texture { source: "chrome.png" }
                    }
                    shadingMode: CustomMaterial.Unshaded
                    cullMode: CustomMaterial.BackFaceCulling
                    vertexShader: "matcap.vert"
                    fragmentShader: "matcap.frag"
                }
            ]
        }

        Model {
            visible: radioPointGeom.checked
            scale: Qt.vector3d(100, 100, 100)
            geometry: ExamplePointGeometry { }
            materials: [
                DefaultMaterial {
                    lighting: DefaultMaterial.NoLighting
                    cullMode: DefaultMaterial.NoCulling
                    diffuseColor: "yellow"
                    pointSize: sliderPointSize.value
                }
            ]
        }

        AxisHelper {
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            propagateComposedEvents: true
            property real lastX: 0
            property real lastY: 0
            property real diffX: 0
            property real diffY: 0

            function orbit(cam, diff_x, diff_y) {
                var dist = (cam.pivot.minus(cam.position)).length()
                cam.position = cam.pivot
                cam.rotate(-diff_x, Qt.vector3d(0, 1, 0), Node.Local)
                cam.rotate(-diff_y, Qt.vector3d(1, 0, 0), Node.Local)
                cam.position = cam.forward.times(-dist)
            }

            onPressed: (mouse) => {
                //console.log("clicked!");
                lastX = mouseX;
                lastY = mouseY;
            }
            onPositionChanged: (mouse) => {
                if (pressed) {
                    diffX = mouseX - lastX
                    diffY = mouseY - lastY
                    lastX = mouseX
                    lastY = mouseY
                    orbit(camera, diffX, diffY)
                    //console.log("pos " + camera.position + " diffX = " + diffX + " diffY " + diffY)
                }
            }
        }

    }

    /* WasdController { */
    /*     controlledObject: camera */
    /* } */

    ColumnLayout {
        DebugView {
            source: v3d
        }
        ButtonGroup {
            buttons: [ radioGridGeom, radioCustGeom, radioPointGeom ]
        }
        RadioButton {
            id: radioGridGeom
            text: "GridGeometry"
            checked: true
            focusPolicy: Qt.NoFocus
        }
        RadioButton {
            id: radioCustGeom
            text: "Custom geometry from application (triangle)"
            checked: false
            focusPolicy: Qt.NoFocus
        }
        RadioButton {
            id: radioPointGeom
            text: "Custom geometry from application (points)"
            checked: false
            focusPolicy: Qt.NoFocus
        }
        RowLayout {
            visible: radioGridGeom.checked
            ColumnLayout {
                Button {
                    text: "More X cells"
                    onClicked: grid.verticalLines += 1
                    focusPolicy: Qt.NoFocus
                }
                Button  {
                    text: "Fewer X cells"
                    onClicked: grid.verticalLines -= 1
                    focusPolicy: Qt.NoFocus
                }
            }
            ColumnLayout {
                Button {
                    text: "More Y cells"
                    onClicked: grid.horizontalLines += 1
                    focusPolicy: Qt.NoFocus
                }
                Button  {
                    text: "Fewer Y cells"
                    onClicked: grid.horizontalLines -= 1
                    focusPolicy: Qt.NoFocus
                }
            }
        }
        RowLayout {
            visible: radioGridGeom.checked
            Label {
                text: "Line width (if supported)"
            }
            Slider {
                id: sliderLineWidth
                from: 1.0
                to: 10.0
                stepSize: 0.5
                value: 1.0
                focusPolicy: Qt.NoFocus
            }
        }
        RowLayout {
            visible: radioCustGeom.checked
            CheckBox {
                id: cbNorm
                text: "provide normals in geometry"
                checked: false
                focusPolicy: Qt.NoFocus
            }
            RowLayout {
                Label {
                    text: "manual adjust"
                }
                Slider {
                    id: sliderNorm
                    from: 0.0
                    to: 1.0
                    stepSize: 0.01
                    value: 0.0
                    focusPolicy: Qt.NoFocus
                }
            }
        }
        RowLayout {
            visible: radioCustGeom.checked
            CheckBox {
                id: cbTexture
                text: "enable base color map"
                checked: false
                focusPolicy: Qt.NoFocus
            }
            CheckBox {
                id: cbUV
                text: "provide UV in geometry"
                checked: false
                focusPolicy: Qt.NoFocus
            }
            RowLayout {
                Label {
                    text: "UV adjust"
                }
                Slider {
                    id: sliderUV
                    from: 0.0
                    to: 1.0
                    stepSize: 0.01
                    value: 0.0
                    focusPolicy: Qt.NoFocus
                }
            }
        }
        RowLayout {
            visible: radioPointGeom.checked
            ColumnLayout {
                RowLayout {
                    Label {
                        text: "Point size (if supported)"
                    }
                    Slider {
                        id: sliderPointSize
                        from: 1.0
                        to: 16.0
                        stepSize: 1.0
                        value: 1.0
                        focusPolicy: Qt.NoFocus
                    }
                }
            }
        }
        TextArea {
            id: infoText
            readOnly: true
        }
    }

}
