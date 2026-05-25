import QtQuick

NumberAnimation {
    property string animType: "spatial"

    duration: {
        if (animType === "spatial")  return 350
        if (animType === "effect")   return 200
        if (animType === "standard") return 400
        if (animType === "progress") return 300
        return 200
    }

    easing.type: Easing.Bezier
    easing.bezierCurve: {
        if (animType === "spatial")  return [0.34, 1.56, 0.25, 1.0]
        if (animType === "effect")   return [0.34, 0.8,  0.34, 1.0]
        if (animType === "standard") return [0.20, 0.0,  0.0,  1.0]
        if (animType === "progress") return [0.31, 0.94, 0.34, 1.0]
        return [0.34, 0.8, 0.34, 1.0]
    }
}
