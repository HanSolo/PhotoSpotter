//
//  ElevationChartView.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 07.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit
import MapKit


public class ElevationChartView: UIView {
    var cameraPin       : MKMapPoint?
    var distance        : CLLocationDistance = 0
    var minElevation    : Double             = 0
    var maxElevation    : Double             = 0
    var elevationDelta  : Double             = 0
    var elevationPoints : [ElevationPoint]   = [] { didSet {
        self.minElevation = (elevationPoints.min { $0.elevation < $1.elevation })?.elevation ?? 0
        self.maxElevation = (elevationPoints.max { $0.elevation < $1.elevation })?.elevation ?? 0
        self.elevationDelta = abs(self.maxElevation - self.minElevation)
        }
    }
    
    
    public override func draw(_ rect: CGRect) {        
        let offsetTop     : Double = 20
        let offsetRight   : Double = 20
        let offsetBottom  : Double = 20
        let offsetLeft    : Double = 20
        let elevationStep : Double = (Double(frame.size.height) - offsetTop - offsetBottom) / self.elevationDelta
        let distanceStep  : Double = (Double(frame.size.width) - offsetLeft - offsetRight) / self.distance
        
        if self.elevationPoints.isEmpty || self.elevationDelta == 0 { return }
        
        let ctx : CGContext? = UIGraphicsGetCurrentContext()
        
        ctx?.clear(self.frame)
        ctx?.setFillColor(UIColor.darkGray.withAlphaComponent(0.5).cgColor)
                
        ctx?.setStrokeColor(UIColor.white.cgColor)
                    
        let titleFont = UIFont.systemFont(ofSize: 13)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let text = NSAttributedString(string: "Elevation", attributes: [.font: titleFont, .foregroundColor: UIColor.white, .paragraphStyle: paragraph])
        text.draw(at: CGPoint(x: 10, y: 10))
        
        let font = UIFont.systemFont(ofSize: 10)
        var toggle : Bool = true
        ctx?.setLineWidth(0.5)
        ctx?.beginPath()
        ctx?.move(to: CGPoint(x: offsetLeft, y: Double(frame.size.height) - offsetBottom))
        for elevationPoint in elevationPoints {
            let dist : Double = cameraPin?.distance(to: MKMapPoint(CLLocationCoordinate2D(latitude: elevationPoint.latitude, longitude: elevationPoint.longitude))) ?? 0
            let x    : Double = offsetLeft + dist * distanceStep
            let y    : Double = Double(frame.size.height) - offsetBottom - (elevationPoint.elevation - minElevation) * elevationStep
            ctx?.setLineWidth(0.5)
            ctx?.strokeLineSegments(between: [CGPoint(x: x, y: y), CGPoint(x: x, y: Double(frame.size.height) - offsetBottom)])
            if (toggle) {
                let elevationText : NSAttributedString = NSAttributedString(string: String(format: "%.1fm", elevationPoint.elevation), attributes: [.font: font, .foregroundColor: UIColor.white, .paragraphStyle: paragraph])
                elevationText.draw(at: CGPoint(x: x - Double(elevationText.size().width * 0.5), y: y - 10))
                let distanceText  : NSAttributedString = NSAttributedString(string: String(format: "%.0fm", dist), attributes: [.font: font, .foregroundColor: UIColor.white, .paragraphStyle: paragraph])
                distanceText.draw(at: CGPoint(x: x - Double(distanceText.size().width * 0.5), y: Double(frame.size.height) - offsetBottom + 10))
            }
            toggle = !toggle
        }
        ctx?.strokePath()
        
        // Draw line
        ctx?.setLineWidth(1.0)
        ctx?.beginPath()
        ctx?.move(to: CGPoint(x: offsetLeft, y: Double(frame.size.height) - offsetBottom))
        for elevationPoint in elevationPoints {
            let dist : Double = cameraPin?.distance(to: MKMapPoint(CLLocationCoordinate2D(latitude: elevationPoint.latitude, longitude: elevationPoint.longitude))) ?? 0
            let x    : Double = offsetLeft + dist * distanceStep
            let y    : Double = Double(frame.size.height) - offsetBottom - (elevationPoint.elevation - minElevation) * elevationStep
            ctx?.addLine(to: CGPoint(x: x, y: y))
        }
        ctx?.addLine(to: CGPoint(x: Double(frame.size.width) - offsetRight, y: Double(frame.size.height) - offsetBottom))
        ctx?.strokePath()
    }
}
