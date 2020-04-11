//
//  View.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 01.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit


public class View: Equatable {
    var name        : String
    var description : String
    var cameraPoint : MKMapPoint
    var motifPoint  : MKMapPoint
    var camera      : Camera
    var lens        : Lens
    var focalLength : Double
    var aperture    : Double
    var orientation : Orientation
    var mapRect     : MKMapRect
    var tags        : Int
    var equipment   : Int
    
    
    init(name: String, description: String, cameraPoint: MKMapPoint, motifPoint: MKMapPoint, camera: Camera, lens: Lens, focalLength: Double, aperture: Double, orientation: Orientation, mapRect: MKMapRect, tags: Int? = 0, equipment: Int? = 0) {
        self.name        = name
        self.description = description
        self.cameraPoint = cameraPoint
        self.motifPoint  = motifPoint
        self.camera      = camera
        self.lens        = lens
        self.focalLength = focalLength
        self.aperture    = aperture
        self.orientation = orientation
        self.mapRect     = mapRect
        self.tags        = tags ?? 0
        self.equipment   = equipment ?? 0
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
        
        let origin    : MKMapPoint = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((viewData.originLat! as NSString).doubleValue), longitude: CLLocationDegrees((viewData.originLon! as NSString).doubleValue)))
        let mapWidth  : Double     = (viewData.mapWidth! as NSString).doubleValue
        let mapHeight : Double     = (viewData.mapHeight! as NSString).doubleValue
        let size      : MKMapSize  = MKMapSize(width: mapWidth, height: mapHeight)
        self.mapRect = MKMapRect(origin: origin, size: size)
        
        self.tags      = Int(viewData.tags ?? "0") ?? 0
        self.equipment = Int(viewData.equipment ?? "0") ?? 0
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
        jsonString += "\"originLat\":\"\(mapRect.origin.coordinate.latitude)\","
        jsonString += "\"originLon\":\"\(mapRect.origin.coordinate.longitude)\","
        jsonString += "\"mapWidth\":\"\(mapRect.size.width)\","
        jsonString += "\"mapHeight\":\"\(mapRect.size.height)\","
        jsonString += "\"tags\":\"\(tags)\","
        jsonString += "\"equipment\":\"\(equipment)\""
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
        jsonString += "\"originLat\":\"\(mapRect.origin.coordinate.latitude)\","
        jsonString += "\"originLon\":\"\(mapRect.origin.coordinate.longitude)\","
        jsonString += "\"mapWidth\":\"\(mapRect.size.width)\","
        jsonString += "\"mapHeight\":\"\(mapRect.size.height)\","
        jsonString += "\"tags\":\"\(tags)\","
        jsonString += "\"equipment\":\"\(equipment)\""
        jsonString += "}"
        return jsonString
    }
}
