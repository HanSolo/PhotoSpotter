//
//  Spot.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 04.05.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit


public class Spot: Equatable, Hashable {
    var name        : String
    var description : String
    var point       : MKMapPoint
    var country     : String
    var tags        : Int32
    
    
    init(name: String, description: String, point: MKMapPoint, country: String, tags: Int32? = 0) {
        self.name        = name
        self.description = description
        self.point       = point
        self.country     = country
        self.tags        = tags ?? 0
    }
    
    init(dictionary: Dictionary<String, String>) throws {
        let spotData : SpotData = try SpotData(dictionary: dictionary)
        self.name        = spotData.name!
        self.description = spotData.description!
        self.point       = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((spotData.lat! as NSString).doubleValue), longitude: CLLocationDegrees((spotData.lon! as NSString).doubleValue)))
        self.country     = spotData.country!
        self.tags        = Int32(spotData.tags ?? "0") ?? 0
    }
    
    init(spotData: SpotData) {
        self.name        = spotData.name!
        self.description = spotData.description!
        self.point       = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees((spotData.lat! as NSString).doubleValue), longitude: CLLocationDegrees((spotData.lon! as NSString).doubleValue)))
        self.country     = spotData.country!
        self.tags        = Int32(spotData.tags ?? "0") ?? 0
    }
    
    init(name: String, description: String, lat: Double, lon: Double, country: String, tags: Int32) {
        self.name        = name
        self.description = description
        self.point       = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)))
        self.country     = country
        self.tags        = tags
    }
    
    public static func ==(lhs: Spot, rhs: Spot) -> Bool {
        return lhs.name == rhs.name &&
               lhs.description == rhs.description &&
               lhs.tags == rhs.tags
    }
    
    func toJsonString() -> String {
        var jsonString : String = "{"
        jsonString += "\"name\":\"\(name)\","
        jsonString += "\"description\":\"\(description)\","
        jsonString += "\"lat\":\"\(point.coordinate.latitude)\","
        jsonString += "\"lon\":\"\(point.coordinate.longitude)\","
        jsonString += "\"country\":\"\(country)\","
        jsonString += "\"tags\":\"\(tags)\""
        jsonString += "}"
        return jsonString
    }
    
    func toFlatJsonString() -> String {
        var jsonString : String = "{"
        jsonString += "\"name\":\"\(name)\","
        jsonString += "\"description\":\"\(description)\","
        jsonString += "\"lat\":\"\(point.coordinate.latitude)\","
        jsonString += "\"lon\":\"\(point.coordinate.longitude)\","
        jsonString += "\"country\":\"\(country)\","
        jsonString += "\"tags\":\"\(tags)\""
        jsonString += "}"
        return jsonString
    }
    
    public func clone() -> Spot {
        return Spot(name: self.name, description: self.description, lat: self.point.coordinate.latitude, lon: self.point.coordinate.longitude, country: self.country, tags: self.tags)
    }
    
    // Make sure the class conforms to hashable protocol
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(country)
        hasher.combine(tags)
    }
}
