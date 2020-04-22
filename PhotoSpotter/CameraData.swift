//
//  CameraData.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 20.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public struct CameraData: Codable {
    let name          : String?
    let sensorFormat  : String?
    
    
    init(name: String, sensorFormat: String) {
        self.name         = name
        self.sensorFormat = sensorFormat
    }
    init(dictionary: Dictionary<String, String>) throws {
        self = try JSONDecoder().decode(CameraData.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}
