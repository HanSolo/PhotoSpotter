//
//  NetworkManager.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 06.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation


class NetworkManager {
    public static func loadElevationPoints(cameraPin: MapPin, motifPin: MapPin, withCompletion completion: @escaping ([ElevationPoint]?) -> Void) {
        var urlString = "https://api.elevationapi.com/api/Elevation/line/"
               urlString += String(format: "%.7f", Double((cameraPin.coordinate.latitude)))
               urlString += ","
               urlString += String(format: "%.7f", Double((cameraPin.coordinate.longitude)))
               urlString += "/"
               urlString += String(format: "%.7f", Double((motifPin.coordinate.latitude)))
               urlString += ","
               urlString += String(format: "%.7f", Double((motifPin.coordinate.longitude)))
               urlString += "?dataSet=SRTM_GL3&reduceResolution=0"
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let url = URL(string: urlString)!
        let task = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if error != nil {
                // Handle Error
                return
            }
            guard response != nil else {
                // Handle Empty Response
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            let wrapper = try? JSONDecoder().decode(Wrapper.self, from: data)
            completion(wrapper?.geoPoints)
        })
        task.resume()
    }
}

struct Wrapper: Decodable {
    let geoPoints: [ElevationPoint]
}


public struct ElevationPoint {
    let latitude                : Double
    let longitude               : Double
    let elevation               : Double
    let distanceFromOriginMeters: Double
}
extension ElevationPoint: Decodable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case elevation
        case distanceFromOriginMeters
    }
}
