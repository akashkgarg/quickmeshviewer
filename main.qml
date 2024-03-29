import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick3D
import QtQuick3D.Helpers
import QuickMeshViewer
import Qt.labs.platform

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    color: "#848895"

    component MatcapMaterial : CustomMaterial {
        property TextureInput tex: TextureInput {
            enabled: true
            texture: Texture {
                source: "gold-phong.png"
            }
        }
        shadingMode: CustomMaterial.Unshaded
        cullMode: CustomMaterial.BackFaceCulling
        vertexShader: "matcap.vert"
        fragmentShader: "matcap.frag"
    }

    FileDialog {
        id: openDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        nameFilters: ["OBJ/OFF files (*.obj *.off)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: triGeom.load(file)
    }

    FileDialog {
        id: matcapOpenDialog
        fileMode: FileDialog.OpenFile
        selectedNameFilter.index: 1
        nameFilters: ["PNG files (*.png)"]
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        onAccepted: {
            mainMaterial.tex.texture.source = file
            secondMaterial.tex.texture.source = file
        }
    }

    View3D {
        id: v3d
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: parent.height
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
            visible: true
            scale: Qt.vector3d(100, 100, 100)
            geometry: TriangleGeometry {
                id: triGeom

                // Load geometry from CLI
                Component.onCompleted: {
                    if (Qt.application.arguments.length === 2)
                        load(Qt.application.arguments[1]);
                }

                onGeometryUpdated: {
                    // TODO: Center camera
                    camera.position = Qt.vector3d(0, 0, (100 * 2*boundingRadius) / Math.tan(camera.fieldOfView * 0.008726646259971648))
                    console.log("geometry updated! camera positioned to " + camera.position);
                }
            }
            materials: [
                MatcapMaterial {
                    id: mainMaterial
                }
            ]
        }

        AxisHelper {
            visible: cbDisplayAxis.checked
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
    View3D {
        id: v3d2
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        width: parent.width / 8
        height: parent.height / 8
        PerspectiveCamera {
            id: camera2
            position: Qt.vector3d(0, 0, 105)
            pivot: Qt.vector3d(0, 0, 0)
        }

        Model {
            visible: true
            source: "#Sphere"
            materials: [
                MatcapMaterial {
                    id: secondMaterial
                }
            ]
        }
    }
    /* WasdController { */
    /*     controlledObject: camera */
    /* } */

    ColumnLayout {
        DebugView {
            source: v3d
        }
        CheckBox {
            id: cbDisplayAxis
            text: "View Axis"
            checked: false
            focusPolicy: Qt.NoFocus
        }
        Button {
            text: "Load Model"
            onClicked: {
                openDialog.open();
            }
            focusPolicy: Qt.NoFocus
        }
        Button {
            text: "Load MatCap"
            onClicked: {
                matcapOpenDialog.open();
            }
            focusPolicy: Qt.NoFocus
        }
        TextArea {
            id: infoText
            readOnly: true
        }
    }

}
