//
//  Lens.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public class Lens: NSObject, NSCoding {
    var name          : String
    var minFocalLength: Double
    var maxFocalLength: Double
    var minAperture   : Double
    var maxAperture   : Double
    var isPrime       : Bool
    
    
    convenience override init() {
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
        self.isPrime        = minFocalLength == maxFocalLength
    }
    public required init?(coder: NSCoder) {
        self.name           = coder.decodeObject(forKey: "name") as? String ?? ""
        self.minFocalLength = coder.decodeDouble(forKey: "minFocalLength")
        self.maxFocalLength = coder.decodeDouble(forKey: "maxFocalLength")
        self.minAperture    = coder.decodeDouble(forKey: "minAperture")
        self.maxAperture    = coder.decodeDouble(forKey: "maxAperture")
        self.isPrime        = minFocalLength == maxFocalLength
    }
    
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.name,                     forKey: "name")
        coder.encode(self.minFocalLength as Double, forKey: "minFocalLength")
        coder.encode(self.maxFocalLength as Double, forKey: "maxFocalLength")
        coder.encode(self.minAperture    as Double, forKey: "minAperture")
        coder.encode(self.maxAperture    as Double, forKey: "maxAperture")
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
