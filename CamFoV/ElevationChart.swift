//
//  ElevationChart.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 06.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

class ElevationChart : UIView {
   
    override func draw(_ rect: CGRect) {
       UIColor(red: 103/255, green: 146/255, blue: 195/255, alpha: 1).set()
       let line = UIBezierPath()
       line.move(to: CGPoint(x: 10, y:5))
       line.addLine(to: CGPoint(x: 90, y:5))
       line.lineWidth = 2
       line.stroke()

       UIColor(red: 163/255, green: 189/255, blue: 218/255, alpha: 1).setFill()

       let origins = [CGPoint(x: 10, y: 1),
                      CGPoint(x: 50, y: 1),
                      CGPoint(x: 90, y: 1)]

       let size = CGSize(width: 8, height: 8)

       for origin in origins {
           let quad = UIBezierPath.init(roundedRect: CGRect(origin: origin, size: size), cornerRadius: 2)
           quad.fill()
           quad.stroke()
       }
   }
}
