//
//  Camera.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 01.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public class Camera: NSObject, NSCoding {
    var name        : String
    var sensorFormat: SensorFormat
    
    
    init(name: String, sensorFormat: SensorFormat) {
        self.name         = name
        self.sensorFormat = sensorFormat
    }
    public required init?(coder: NSCoder) {
        self.name         = coder.decodeObject(forKey: "name") as? String ?? ""
        self.sensorFormat = SensorFormat(rawValue: (coder.decodeObject( forKey: "sensorFormat" ) as! String)) ?? SensorFormat.FULL_FORMAT
    }
    
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.name,                   forKey: "name")
        coder.encode(self.sensorFormat.rawValue as String, forKey: "sensorFormat")
    }
    
    
    func description() -> String {
        var description = name
        description += " \(sensorFormat.name)"
        description += " \(String(format: "%.1f", sensorFormat.width))"
        description += " mm \(String(format: "%.1f", sensorFormat.height))"
        description += " mm \(String(format: "%.2f", sensorFormat.cropFactor))"
        return description
    }
    
    
    func toJsonString() -> String {
        var jsonString : String = "{"
        jsonString += "\"name\":\"\(name)\","        
        jsonString += "\"sensor\":"
        jsonString += sensorFormat.jsonString
        jsonString += "}"
        return jsonString
    }
}
