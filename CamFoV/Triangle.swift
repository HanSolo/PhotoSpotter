//
//  Triangle.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit


public class Triangle {
    var p1: MKMapPoint
    var p2: MKMapPoint
    var p3: MKMapPoint
    
    
    convenience init() {
        self.init(p1: MKMapPoint(x: 0, y: 0), p2: MKMapPoint(x: 0, y: 0), p3: MKMapPoint(x: 0, y: 0))
    }
    init(p1: MKMapPoint, p2: MKMapPoint, p3: MKMapPoint) {
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }
    
    
    public func getPoints() -> [MKMapPoint] {
        var points : [MKMapPoint] = []
        points.append(p1)
        points.append(p2);
        points.append(p3);
        return points
    }
    
    public func toString() -> String {
        var text = "P1 [lat:\(p1.coordinate.latitude), lon:\(p1.coordinate.longitude)] -> [x:\(p1.x), y:\(p1.y)]" + "\n"
        text += "P2 [lat:\(p2.coordinate.latitude), lon:\(p2.coordinate.longitude)] -> [x:\(p2.x), y:\(p2.y)]" + "\n"
        text += "P3 [lat:\(p3.coordinate.latitude), lon:\(p3.coordinate.longitude)] -> [x:\(p3.x), y:\(p3.y)]"
        return text;
    }
}
