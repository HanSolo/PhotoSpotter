//
//  Helper.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit


public class Helper {
    public static let EARTH_RADIUS     : Double = 6_378_137 // in m
    public static let DEFAULT_POSITION : MKMapPoint = MKMapPoint(CLLocationCoordinate2D(latitude: 51.911821, longitude: 7.633703))
    public static let DEFAULT_CAMERA   : Camera = Camera(name: "DSLR", sensorFormat: SensorFormat.FULL_FORMAT)
    public static let DEFAULT_LENS     : Lens   = Lens(name: "24-70mm f2.8", minFocalLength: 24, maxFocalLength: 70, minAperture: 2.8, maxAperture: 22)
    public static let DEFAULT_VIEW     : View   = View(name: "View", description: "Default View",
                                                     cameraPoint: DEFAULT_POSITION,
                                                     motifPoint: MKMapPoint(CLLocationCoordinate2D(latitude: DEFAULT_POSITION.coordinate.latitude + 0.005, longitude: DEFAULT_POSITION.coordinate.longitude)),
                                                     camera: DEFAULT_CAMERA,
                                                     lens: DEFAULT_LENS,
                                                     focalLength: DEFAULT_LENS.minFocalLength + (DEFAULT_LENS.maxFocalLength - DEFAULT_LENS.minFocalLength) / 2,
                                                     aperture: DEFAULT_LENS.minAperture + (DEFAULT_LENS.maxAperture - DEFAULT_LENS.minAperture) / 2,
                                                     orientation: Orientation.LANDSCAPE)
    
    public static func toDegrees(radians: Double) -> Double {
        return radians * 180 / .pi
    }

    public static func toRadians(degrees: Double) -> Double {
        return degrees * .pi / 180
    }
    
    public static func clamp(min: Double, max: Double, value: Double) -> Double {
        if value < min { return min }
        if value > max { return max }
        return value
    }
    
    public static func distance(x1: Double, y1: Double, x2: Double, y2: Double) -> Double {
        let ac: Double = abs(y2 - y1)
        let cb: Double = abs(x2 - x1)
        return hypot(ac, cb)
    }
    
    public static func calc(camera: MKMapPoint, motif: MKMapPoint, focalLengthInMM: Double, aperture: Double,sensorFormat: SensorFormat, orientation: Orientation) throws -> Data {        
        let distance : Double = camera.distance(to: motif)
        
        if focalLengthInMM < 8 || focalLengthInMM > 2400 { throw FoVError.invalidArgument(message: "Error, focal length must be between 8mm and 2400mm") }
        if aperture < 0.7 || aperture > 99 { throw FoVError.invalidArgument(message: "Error, aperture must be between f/0.7 and f/99"); }
        if distance < 0.01 || distance > 9999 { throw FoVError.invalidArgument(message: "Error, distance must be between 0.01m and 9999m"); }

        let cropFactor: Double = sensorFormat.cropFactor

        // Do all calculations in metres (because that's sensible).
        let focalLength: Double = focalLengthInMM / 1000.0

        // Let the circle of confusion be 0.0290mm for 35mm film.
        let circleOfConfusion: Double = (0.0290 / 1000.0) / cropFactor

        let hyperFocal    : Double = (focalLength * focalLength) / (aperture * circleOfConfusion) + focalLength
        let nearLimit     : Double = ((hyperFocal - focalLength) * distance) / (hyperFocal + distance - 2 * focalLength);

        let infinite      : Bool   = (hyperFocal - distance) < 0.00000001

        let farLimit      : Double = ((hyperFocal - focalLength) * distance) / (hyperFocal - distance)
        let frontPercent  : Double = (distance - nearLimit) / (farLimit - nearLimit) * 100
        let behindPercent : Double = (farLimit - distance) / (farLimit - nearLimit) * 100
        let total         : Double = farLimit - nearLimit

        let d             : Double = sqrt((sensorFormat.width * sensorFormat.width) + (sensorFormat.height * sensorFormat.height))
        let diagonalAngle : Double = 2.0 * atan(d / (2.0 * focalLengthInMM))
        let diagonalLength: Double = ((distance * sin(diagonalAngle / 2.0)) / cos(diagonalAngle / 2.0)) * 2.0
        let phi           : Double = asin(2.0 / 3.605551)
        let fovWidth      : Double
        let fovHeight     : Double
        if Orientation.LANDSCAPE == orientation {
            fovWidth  = cos(phi) * diagonalLength
            fovHeight = sin(phi) * diagonalLength
        } else {
            fovWidth  = sin(phi) * diagonalLength
            fovHeight = cos(phi) * diagonalLength
        }

        let halfFovWidth  : Double = fovWidth * 0.5
        let halfFovHeight : Double = fovHeight * 0.5

        let fovWidthAngle : Double = 2 * asin(halfFovWidth / sqrt((distance * distance) + (halfFovWidth * halfFovWidth)))
        let fovHeightAngle: Double = 2 * asin(halfFovHeight / sqrt((distance * distance) + (halfFovHeight * halfFovHeight)))
        let radius        : Double = sqrt((halfFovWidth * halfFovWidth) + (distance * distance))

       
        return Data(camera: camera, motif: motif, focalLength: focalLengthInMM, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation, infinite: infinite, hyperFocal: hyperFocal, nearLimit: nearLimit, farLimit: farLimit, frontPercent: frontPercent, behindPercent: behindPercent, total: total, diagonalAngle: diagonalAngle, diagonalLength: diagonalLength, fovWidth: fovWidth, fovWidthAngle: fovWidthAngle, fovHeight: fovHeight, fovHeightAngle: fovHeightAngle, radius: radius)
    }
    
    public static func updateTriangle(camera: MKMapPoint, motif: MKMapPoint, focalLengthInMM: Double, aperture: Double, sensorFormat: SensorFormat, orientation: Orientation, triangle: Triangle) -> Void {
        do {
            let data: Data = try calc(camera: camera, motif: motif, focalLengthInMM: focalLengthInMM, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation)
            let trianglePoints: [MKMapPoint] = calcTrianglePoints(data: data)
            triangle.p1 = trianglePoints[0]
            triangle.p2 = trianglePoints[1]
            triangle.p3 = trianglePoints[2]
        } catch {
            // Handle error here
        }
    }
    
    public static func calcTrianglePoints(data: Data) -> [MKMapPoint] {
        let halfFovWidthAngle: Double = data.fovWidthAngle / 2.0
        let p1: MKMapPoint = MKMapPoint(CLLocationCoordinate2D(latitude: Double(data.camera.coordinate.latitude), longitude: Double(data.camera.coordinate.longitude)))
        let p2: MKMapPoint = calcCoord(start: data.camera, distance: data.radius, bearing: -halfFovWidthAngle)
        let p3: MKMapPoint = calcCoord(start: data.camera, distance: data.radius, bearing: halfFovWidthAngle)
        return [p1, p2, p3]
    }
    
    public static func updateTrapezoid(camera: MKMapPoint, motif: MKMapPoint, focalLengthInMM: Double, aperture: Double, sensorFormat: SensorFormat, orientation: Orientation, trapezoid: Trapezoid) -> Void {
        do {
            let data: Data = try calc(camera: camera, motif: motif, focalLengthInMM: focalLengthInMM, aperture: aperture, sensorFormat: sensorFormat, orientation: orientation)
            let trapezoidPoints: [MKMapPoint] = calcTrapezoidPoints(data: data)
            trapezoid.p1 = trapezoidPoints[0]
            trapezoid.p2 = trapezoidPoints[1]
            trapezoid.p3 = trapezoidPoints[2]
            trapezoid.p4 = trapezoidPoints[3]
        } catch {
            // Handle error here
        }
    }
    
    public static func calcTrapezoidPoints(data: Data) -> [MKMapPoint] {
        let halfFovWidthAngle: Double = data.fovWidthAngle / 2.0
        let radius1          : Double = data.nearLimit / cos(halfFovWidthAngle)
        let radius2          : Double = data.farLimit / cos(halfFovWidthAngle)

        let p1: MKMapPoint = calcCoord(start: data.camera, distance: radius1, bearing: -halfFovWidthAngle)
        let p2: MKMapPoint = calcCoord(start: data.camera, distance: radius2, bearing: -halfFovWidthAngle)
        let p3: MKMapPoint = calcCoord(start: data.camera, distance: radius2, bearing: halfFovWidthAngle)
        let p4: MKMapPoint = calcCoord(start: data.camera, distance: radius1, bearing: halfFovWidthAngle)

        return  [ p1, p2, p3, p4 ]
    }
    
    public static func calculateBearing(location1: MKMapPoint, location2: MKMapPoint) -> Double {
        let lat1   : Double = toRadians(degrees: Double(location1.coordinate.latitude))
        let lon1   : Double = Double(location1.coordinate.longitude)
        let lat2   : Double = toRadians(degrees: Double(location2.coordinate.latitude))
        let lon2   : Double = Double(location2.coordinate.longitude)
        let dLon   : Double = toRadians(degrees: lon2 - lon1);
        let y      : Double = sin(dLon) * cos(lat2)
        let x      : Double = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing: Double = (toDegrees(radians: atan2(y, x)) + 360).truncatingRemainder(dividingBy: 360)
        return bearing
    }
    
    public static func calcCoord(start: MKMapPoint, distance: Double, bearing: Double) -> MKMapPoint {
        let lat1   = toRadians(degrees: Double(start.coordinate.latitude))
        let lon1   = toRadians(degrees: Double(start.coordinate.longitude))
        let radius = distance / EARTH_RADIUS

        let lat2 = asin(sin(lat1) * cos(radius) + cos(lat1) * sin(radius) * cos(bearing))
        var lon2 = lon1 + atan2(sin(bearing) * sin(radius) * cos(lat1), cos(radius) - sin(lat1) * sin(lat2))
        lon2 = (lon2 + 3 * .pi).truncatingRemainder(dividingBy: (2 * .pi)) - .pi

        return MKMapPoint(CLLocationCoordinate2D(latitude: toDegrees(radians: lat2), longitude: toDegrees(radians: lon2)))
    }
    
    public static func rotatePointAroundCenter(point: MKMapPoint, rotationCenter: MKMapPoint, rad: Double) -> MKMapPoint {
        let sinValue = sin(rad)
        let cosValue = cos(rad)
        let dx       = point.x - rotationCenter.x
        let dy       = point.y - rotationCenter.y
        return MKMapPoint(x: rotationCenter.x + (dx * cosValue) - (dy * sinValue), y: rotationCenter.y + (dx * sinValue) + (dy * cosValue))
    }
    
    public static func viewToDictionary(view: View) -> Dictionary<String,String> {
        let jsonString : String = view.toFlatJsonString()
        if let data = jsonString.data(using: String.Encoding.utf8) {
            do {
                let decoder = JSONDecoder()
                let jsonDictionary = try decoder.decode(Dictionary<String, String>.self, from: data)
                return jsonDictionary
            } catch {
                return Dictionary<String,String>()
            }
        }
        return Dictionary<String,String>()
    }
    
    public static func dictionaryToView(dictionary: Dictionary<String,String>, cameras: [Camera], lenses: [Lens]) -> View {
        do {
            return try View(dictionary: dictionary, cameras: cameras, lenses: lenses)
        } catch {
            return Helper.DEFAULT_VIEW
        }
    }
}
