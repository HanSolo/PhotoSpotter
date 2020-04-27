//
//  View.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 01.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit


public class View: Equatable, Hashable {
    var name        : String
    var description : String
    var cameraPoint : MKMapPoint
    var motifPoint  : MKMapPoint
    var camera      : Camera
    var lens        : Lens
    var focalLength : Double
    var aperture    : Double
    var orientation : Orientation
    var country     : String
    var mapRect     : MKMapRect
    var tags        : Int32
    var equipment   : Int32
    var times       : Int32
    
    
    init(name: String, description: String, cameraPoint: MKMapPoint, motifPoint: MKMapPoint, camera: Camera, lens: Lens, focalLength: Double, aperture: Double, orientation: Orientation, country: String, mapRect: MKMapRect, tags: Int32? = 0, equipment: Int32? = 0, times: Int32? = 0) {
        self.name        = name
        self.description = description
        self.cameraPoint = cameraPoint
        self.motifPoint  = motifPoint
        self.camera      = camera
        self.lens        = lens
        self.focalLength = focalLength
        self.aperture    = aperture
        self.orientation = orientation
        self.country     = country
        self.mapRect     = mapRect
        self.tags        = tags ?? 0
        self.equipment   = equipment ?? 0
        self.times       = times ?? 0
    }
    
    init(dictionary: Dictionary<String, String>, cameras: [Camera], lenses: [Lens]) throws {        
        let viewData : ViewData = try ViewData(dictionary: dictionary)
        self.name        = viewData.name!
        self.description = viewData.description!
        self.cameraPoint = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((viewData.cameraLat! as NSString).doubleValue), longitude: CLLocationDegrees((viewData.cameraLon! as NSString).doubleValue)))
        self.motifPoint  = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((viewData.motifLat! as NSString).doubleValue), longitude: CLLocationDegrees((viewData.motifLon! as NSString).doubleValue)))
        if let cameraFound = cameras.first(where: {$0.name == viewData.cameraName!}) {
            self.camera = cameraFound
        } else {
            self.camera = Constants.DEFAULT_CAMERA
        }
        if let lensFound = lenses.first(where: {$0.name == viewData.lensName!}) {
            self.lens = lensFound
        } else {
            self.lens = Constants.DEFAULT_LENS
        }
        self.focalLength = Double(viewData.focalLength!)!
        self.aperture    = Double(viewData.aperture!)!
        self.orientation = Orientation(rawValue: viewData.orientation!)!
        self.country     = viewData.country!
        
        let origin    : MKMapPoint = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((viewData.originLat! as NSString).doubleValue), longitude: CLLocationDegrees((viewData.originLon! as NSString).doubleValue)))
        let mapWidth  : Double     = (viewData.mapWidth! as NSString).doubleValue
        let mapHeight : Double     = (viewData.mapHeight! as NSString).doubleValue
        let size      : MKMapSize  = MKMapSize(width: mapWidth, height: mapHeight)
        self.mapRect = MKMapRect(origin: origin, size: size)
        
        self.tags      = Int32(viewData.tags ?? "0") ?? 0
        self.equipment = Int32(viewData.equipment ?? "0") ?? 0
        self.times     = Int32(viewData.times ?? "0") ?? 0
    }
    
    init(viewData: ViewData) {
        self.name          = viewData.name!
        self.description   = viewData.description!
        self.cameraPoint   = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((viewData.cameraLat! as NSString).doubleValue), longitude: CLLocationDegrees((viewData.cameraLon! as NSString).doubleValue)))
        self.motifPoint    = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((viewData.motifLat! as NSString).doubleValue), longitude: CLLocationDegrees((viewData.motifLon! as NSString).doubleValue)))
        
        let cameraName     = viewData.cameraName ?? Constants.DEFAULT_CAMERA.name
        let sensorFormat   = Constants.SENSOR_FORMATS.first(where: { $0.name == viewData.sensorName })
        self.camera        = Camera(name: cameraName, sensorFormat: sensorFormat ?? Constants.DEFAULT_CAMERA.sensorFormat)
        
        let lensName       = viewData.lensName ?? Constants.DEFAULT_LENS.name
        let minFocalLength = Double(viewData.minFocalLength!) ?? Constants.DEFAULT_LENS.minFocalLength
        let maxFocalLength = Double(viewData.maxFocalLength!) ?? Constants.DEFAULT_LENS.maxFocalLength
        let minAperture    = Double(viewData.minAperture!) ?? Constants.DEFAULT_LENS.minAperture
        let maxAperture    = Double(viewData.maxAperture!) ?? Constants.DEFAULT_LENS.maxAperture
        self.lens          = Lens(name: lensName, minFocalLength: minFocalLength, maxFocalLength: maxFocalLength, minAperture: minAperture, maxAperture: maxAperture)
            
        self.focalLength   = Double(viewData.focalLength!)!
        self.aperture      = Double(viewData.aperture!)!
        self.orientation   = Orientation(rawValue: viewData.orientation!)!
        self.country       = viewData.country!
        
        let origin    : MKMapPoint = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((viewData.originLat! as NSString).doubleValue), longitude: CLLocationDegrees((viewData.originLon! as NSString).doubleValue)))
        let mapWidth  : Double     = (viewData.mapWidth! as NSString).doubleValue
        let mapHeight : Double     = (viewData.mapHeight! as NSString).doubleValue
        let size      : MKMapSize  = MKMapSize(width: mapWidth, height: mapHeight)
        self.mapRect = MKMapRect(origin: origin, size: size)
        
        self.tags      = Int32(viewData.tags ?? "0") ?? 0
        self.equipment = Int32(viewData.equipment ?? "0") ?? 0
        self.times     = Int32(viewData.times ?? "0") ?? 0
    }
    
    init(name: String, description: String, cameraLat: Double, cameraLon: Double, motifLat: Double, motifLon: Double, cameraName: String, sensorName: String,
    lensName: String, minFocalLength: Double, maxFocalLength: Double, minAperture: Double, maxAperture: Double,
    focalLength: Double, aperture: Double, orientation: String, country: String, originLat: Double, originLon: Double, mapWidth: Double, mapHeight: Double, tags: Int32, equipment: Int32, times: Int32) {
        self.name          = name
        self.description   = description
        self.cameraPoint   = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees(cameraLat), longitude: CLLocationDegrees(cameraLon)))
        self.motifPoint    = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees(motifLat), longitude: CLLocationDegrees(motifLon)))
        let sensorFormat   = Constants.SENSOR_FORMATS.first(where: { $0.name == sensorName })
        self.camera        = Camera(name: cameraName, sensorFormat: sensorFormat ?? Constants.DEFAULT_CAMERA.sensorFormat)
        self.lens          = Lens(name: lensName, minFocalLength: minFocalLength, maxFocalLength: maxFocalLength, minAperture: minAperture, maxAperture: maxAperture)
        self.focalLength   = focalLength
        self.aperture      = aperture
        self.orientation   = Orientation(rawValue: orientation)!
        self.country       = country
        let origin         = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees(originLat), longitude: CLLocationDegrees(originLon)))
        let mapWidth       = mapWidth
        let mapHeight      = mapHeight
        let size           = MKMapSize(width: mapWidth, height: mapHeight)
        self.mapRect       = MKMapRect(origin: origin, size: size)
        self.tags          = tags
        self.equipment     = equipment
        self.times         = times
    }
    
    public static func ==(lhs: View, rhs: View) -> Bool {
        return lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.camera == rhs.camera &&
               lhs.lens == rhs.lens
    }
    
    func toJsonString() -> String {
        var jsonString : String = "{"
        jsonString += "\"name\":\"\(name)\","
        jsonString += "\"description\":\"\(description)\","
        jsonString += "\"cameraLat\":\"\(cameraPoint.coordinate.latitude)\","
        jsonString += "\"cameraLon\":\"\(cameraPoint.coordinate.longitude)\","
        jsonString += "\"motifLat\":\"\(motifPoint.coordinate.latitude)\","
        jsonString += "\"motifLon\":\"\(motifPoint.coordinate.longitude)\","
        jsonString += "\"camera\":"
        jsonString += camera.toJsonString()
        jsonString += ","
        jsonString += "\"lens\":"
        jsonString += lens.toJsonString()
        jsonString += ","
        jsonString += "\"focalLength\":\"\(focalLength)\","
        jsonString += "\"aperture\":\"\(aperture)\","
        jsonString += "\"orientation\":\"\(orientation.name.uppercased())\","
        jsonString += "\"country\":\"\(country)\","
        jsonString += "\"originLat\":\"\(mapRect.origin.coordinate.latitude)\","
        jsonString += "\"originLon\":\"\(mapRect.origin.coordinate.longitude)\","
        jsonString += "\"mapWidth\":\"\(mapRect.size.width)\","
        jsonString += "\"mapHeight\":\"\(mapRect.size.height)\","
        jsonString += "\"tags\":\"\(tags)\","
        jsonString += "\"equipment\":\"\(equipment)\","
        jsonString += "\"times\":\"\(times)\""
        jsonString += "}"
        return jsonString
    }
    
    func toFlatJsonString() -> String {
        var jsonString : String = "{"
        jsonString += "\"name\":\"\(name)\","
        jsonString += "\"description\":\"\(description)\","
        jsonString += "\"cameraLat\":\"\(cameraPoint.coordinate.latitude)\","
        jsonString += "\"cameraLon\":\"\(cameraPoint.coordinate.longitude)\","
        jsonString += "\"motifLat\":\"\(motifPoint.coordinate.latitude)\","
        jsonString += "\"motifLon\":\"\(motifPoint.coordinate.longitude)\","
        jsonString += "\"cameraName\":\"\(camera.name)\","
        jsonString += "\"sensorName\":\"\(camera.sensorFormat)\","
        jsonString += "\"lensName\":\"\(lens.name)\","
        jsonString += "\"minFocalLength\":\"\(lens.minFocalLength)\","
        jsonString += "\"maxFocalLength\":\"\(lens.maxFocalLength)\","
        jsonString += "\"minAperture\":\"\(lens.minAperture)\","
        jsonString += "\"maxAperture\":\"\(lens.maxAperture)\","
        jsonString += "\"focalLength\":\"\(focalLength)\","
        jsonString += "\"aperture\":\"\(aperture)\","
        jsonString += "\"orientation\":\"\(orientation)\","
        jsonString += "\"country\":\"\(country)\","
        jsonString += "\"originLat\":\"\(mapRect.origin.coordinate.latitude)\","
        jsonString += "\"originLon\":\"\(mapRect.origin.coordinate.longitude)\","
        jsonString += "\"mapWidth\":\"\(mapRect.size.width)\","
        jsonString += "\"mapHeight\":\"\(mapRect.size.height)\","
        jsonString += "\"tags\":\"\(tags)\","
        jsonString += "\"equipment\":\"\(equipment)\","
        jsonString += "\"times\":\"\(times)\""
        jsonString += "}"
        return jsonString
    }
    
    public func clone() -> View {
        return View(name: self.name, description: self.description,
                    cameraLat: self.cameraPoint.coordinate.latitude, cameraLon: self.cameraPoint.coordinate.longitude, motifLat: self.motifPoint.coordinate.latitude, motifLon: self.motifPoint.coordinate.longitude,
                    cameraName: self.camera.name, sensorName: self.camera.sensorFormat.rawValue, lensName: self.lens.name, minFocalLength: self.lens.minFocalLength, maxFocalLength: self.lens.maxFocalLength,
                    minAperture: self.lens.minAperture, maxAperture: self.lens.maxAperture, focalLength: self.focalLength, aperture: self.aperture, orientation: self.orientation.rawValue,
                    country: self.country, originLat: self.mapRect.origin.coordinate.latitude, originLon: self.mapRect.origin.coordinate.longitude, mapWidth: self.mapRect.width, mapHeight: self.mapRect.height,
                    tags: self.tags, equipment: self.equipment, times: self.times)
    }
    
    // Make sure the class conforms to hashable protocol
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(lens)
        hasher.combine(camera)
    }
}
