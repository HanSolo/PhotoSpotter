//
//  Data.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit


public class FoVData {
    public let camera                    : MKMapPoint
    public let motif                     : MKMapPoint
    public let focalLength               : Double
    public let aperture                  : Double
    public let distance                  : Double
    public let sensorFormat              : SensorFormat
    public let orientation               : Orientation
    public let infinite                  : Bool
    public let hyperFocal                : Double
    public let nearLimit                 : Double
    public let farLimit                  : Double
    public let frontPercent              : Double
    public let behindPercent             : Double
    public let total                     : Double
    public let diagonalAngle             : Double
    public let diagonalLength            : Double
    public let fovWidth                  : Double
    public let fovWidthAngle             : Double
    public let fovHeight                 : Double
    public let fovHeightAngle            : Double
    public let radius                    : Double
    public let angleBetweenCameraAndMotif: Double
    public let dofInFront                : Double
    public let dofBehind                 : Double
    
    
    init(camera: MKMapPoint, motif: MKMapPoint, focalLength: Double, aperture: Double, sensorFormat: SensorFormat, orientation: Orientation,
         infinite: Bool, hyperFocal: Double, nearLimit: Double, farLimit: Double, frontPercent: Double, behindPercent: Double, total: Double,
         diagonalAngle: Double, diagonalLength: Double, fovWidth: Double, fovWidthAngle: Double, fovHeight: Double, fovHeightAngle: Double, radius: Double) {
        self.camera                     = camera
        self.motif                      = motif
        self.focalLength                = focalLength
        self.aperture                   = aperture
        self.distance                   = camera.distance(to: motif)
        self.sensorFormat               = sensorFormat
        self.orientation                = orientation
        self.infinite                   = infinite
        self.hyperFocal                 = hyperFocal
        self.nearLimit                  = nearLimit
        self.farLimit                   = infinite ? 10000 : farLimit
        self.frontPercent               = frontPercent
        self.behindPercent              = behindPercent
        self.total                      = infinite ? 10000 : total
        self.diagonalAngle              = diagonalAngle
        self.diagonalLength             = diagonalLength
        self.fovWidth                   = fovWidth
        self.fovWidthAngle              = fovWidthAngle
        self.fovHeight                  = fovHeight
        self.fovHeightAngle             = fovHeightAngle
        self.radius                     = radius
        self.angleBetweenCameraAndMotif = Helper.toRadians(degrees: Helper.calculateBearing(location1: camera, location2: motif))
        self.dofInFront                 = distance - nearLimit
        self.dofBehind                  = infinite ? 10000 : farLimit - distance
    }
    
    public func toString() -> String {
        var text: String = "Sensor      : \(sensorFormat.name)" + "\n"
        text += "Focal length: \(String(format: "%.0f", focalLength)) mm" + "\n"
        text += "Aperture    : \(String(format: "%.1f", aperture))" + "\n"
        text += "Orientation : \(orientation.name)" + "\n"
        text += "-----------------------------" + "\n"
        text += "Distance    : \(String(format: "%.2f", distance)) m" + "\n"
        text += "FoV width   : \(String(format: "%.2f", fovWidth)) m (" + "\(String(format: "%.2f", fovWidthAngle)) \u{00b0})" + "\n"
        text += "FoV height  : \(String(format: "%.2f", fovHeight)) m (" + "\(String(format: "%.2f", fovHeightAngle)) \u{00b0})" + "\n"
        text += "-----------------------------" + "\n"
        text += "Hyperfocal  : \(String(format: "%.2f", hyperFocal)) m" + "\n"
        text += "Near limit  : \(String(format: "%.2f", nearLimit)) m" + "\n"
        text += "Far  limit  : \(String(format: "%.2f", farLimit)) m" + "\n"
        text += "In front    : \(String(format: "%.2f", dofInFront)) m" + "\n"
        text += "Behind      : \(String(format: "%.2f", dofBehind)) m" + "\n"
        text += "Total       : \(String(format: "%.2f", total)) m" + "\n"
        text += "-----------------------------" + "\n"
        return text
    }
}
