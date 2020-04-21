//
//  LensData.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 20.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public struct LensData: Codable {
    let name          : String?
    let minFocalLength: String?
    let maxFocalLength: String?
    let minAperture   : String?
    let maxAperture   : String?
    
    
    init(name: String, minFocalLength: String, maxFocalLength: String, minAperture: String, maxAperture: String) {
        self.name           = name
        self.minFocalLength = minFocalLength
        self.maxFocalLength = maxFocalLength
        self.minAperture    = minAperture
        self.maxAperture    = maxAperture
    }
    init(dictionary: Dictionary<String, String>) throws {
        self = try JSONDecoder().decode(LensData.self, from: JSONSerialization.data(withJSONObject: dictionary))
    }
}
