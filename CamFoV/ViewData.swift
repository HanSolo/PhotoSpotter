//
//  ViewData.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 01.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit

public struct ViewData: Codable {
    let name          : String?
    let description   : String?
    let cameraLat     : String?
    let cameraLon     : String?
    let motifLat      : String?
    let motifLon      : String?
    let cameraName    : String?
    let sensorName    : String?
    let lensName      : String?
    let minFocalLength: String?
    let maxFocalLength: String?
    let minAperture   : String?
    let maxAperture   : String?
    let focalLength   : String?
    let aperture      : String?
    let orientation   : String?
    let originLat     : String?
    let originLon     : String?
    let mapWidth      : String?
    let mapHeight     : String?
    
    
    init(dictionary: Dictionary<String, String>) throws {
        self = try JSONDecoder().decode(ViewData.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}
