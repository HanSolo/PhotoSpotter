//
//  Lens.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public class Lens {
    var name          : String
    var minFocalLength: Double
    var maxFocalLength: Double
    var minAperture   : Double
    var maxAperture   : Double
    var focalLength   : Double
    var aperture      : Double
    var isPrime       : Bool
    
    
    convenience init() {
        self.init(name: "Lens", minFocalLength: 8, maxFocalLength: 1000, minAperture: 0.7, maxAperture: 50)
    }
    convenience init(name: String, focalLength: Double, minAperture: Double, maxAperture: Double) {
        self.init(name: name, minFocalLength: focalLength, maxFocalLength: focalLength, minAperture: minAperture, maxAperture: maxAperture)
    }
    init(name: String, minFocalLength: Double, maxFocalLength: Double, minAperture: Double, maxAperture: Double) {
        self.name = name
        self.minFocalLength = minFocalLength
        self.maxFocalLength = maxFocalLength
        self.minAperture    = minAperture
        self.maxAperture    = maxAperture
        self.focalLength    = minFocalLength
        self.aperture       = minAperture
        self.isPrime        = minFocalLength == maxFocalLength
    }
    
    
    func toJsonString() -> String {
        var jsonString : String = "{"
        jsonString += "\"name\":\"\(name)\","
        jsonString += "\"minFocalLength\":\"\(minFocalLength)\","
        jsonString += "\"maxFocalLength\":\"\(maxFocalLength)\","
        jsonString += "\"minAperture\":\"\(minAperture)\","
        jsonString += "\"maxAperture\":\"\(maxAperture)\""
        jsonString += "}"
        return jsonString
    }
}
