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
        let offsetLeft    : Double = 100
        let elevationStep : Double = (Double(frame.size.height) - offsetTop - offsetBottom) / self.elevationDelta
        let distanceStep  : Double = (Double(frame.size.width) - offsetLeft - offsetRight) / self.distance
        
        if self.elevationPoints.isEmpty || self.elevationDelta == 0 { return }
        
        let ctx : CGContext? = UIGraphicsGetCurrentContext()
        
        ctx?.clear(self.frame)
        ctx?.setFillColor(UIColor.darkGray.withAlphaComponent(0.75).cgColor)
        ctx?.fill(rect)
        
        let font = UIFont.systemFont(ofSize: 10)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let textAttributes = [NSAttributedString.Key.font: font,
                              NSAttributedString.Key.foregroundColor: Constants.YELLOW,
                              NSAttributedString.Key.paragraphStyle: paragraph]
        
        let minY : Double = Double(frame.size.height) - offsetBottom
        let maxY : Double = Double(frame.size.height) - offsetBottom - (maxElevation - minElevation) * elevationStep
        
        // Min- and MaxElevation
        let minElevationText = NSAttributedString(string: String(format: "%.1fm", minElevation), attributes: textAttributes)
        minElevationText.draw(at: CGPoint(x: 40 - Double(minElevationText.size().width * 0.5), y: minY))
        let maxElevationText = NSAttributedString(string: String(format: "%.1fm", maxElevation), attributes: textAttributes)
        maxElevationText.draw(at: CGPoint(x: 40 - Double(maxElevationText.size().width * 0.5), y: maxY))
      
        ctx?.setLineWidth(1.0)
        ctx?.setStrokeColor(Constants.YELLOW.cgColor)
        ctx?.strokeLineSegments(between: [CGPoint(x: 40, y: minY - 5), CGPoint(x: 40, y: maxY + 15)])
        ctx?.strokeLineSegments(between: [CGPoint(x: 40, y: minY - 5), CGPoint(x: 36, y: minY - 10)])
        ctx?.strokeLineSegments(between: [CGPoint(x: 40, y: minY - 5), CGPoint(x: 44, y: minY - 10)])
        ctx?.strokeLineSegments(between: [CGPoint(x: 40, y: maxY + 15), CGPoint(x: 36, y: maxY + 20)])
        ctx?.strokeLineSegments(between: [CGPoint(x: 40, y: maxY + 15), CGPoint(x: 44, y: maxY + 20)])
        
        // Chart
        var toggle : Bool = true
        ctx?.setLineWidth(0.5)
        ctx?.beginPath()
        ctx?.move(to: CGPoint(x: offsetLeft, y: Double(frame.size.height) - offsetBottom))
        for elevationPoint in elevationPoints {
            let dist : Double = cameraPin?.distance(to: MKMapPoint(CLLocationCoordinate2D(latitude: elevationPoint.latitude, longitude: elevationPoint.longitude))) ?? 0
            let x    : Double = offsetLeft + dist * distanceStep
            let y    : Double = Double(frame.size.height) - offsetBottom - (elevationPoint.elevation - minElevation) * elevationStep
            ctx?.setStrokeColor(UIColor.white.cgColor)
            ctx?.strokeLineSegments(between: [CGPoint(x: x, y: y), CGPoint(x: x, y: Double(frame.size.height) - offsetBottom)])
            if (toggle) {
                let elevationText : NSAttributedString = NSAttributedString(string: String(format: "%.1fm", elevationPoint.elevation), attributes: textAttributes)
                elevationText.draw(at: CGPoint(x: x - Double(elevationText.size().width * 0.5), y: y - 15))
                let distanceText  : NSAttributedString = NSAttributedString(string: String(format: "%.0fm", dist), attributes: textAttributes)
                distanceText.draw(at: CGPoint(x: x - Double(distanceText.size().width * 0.5), y: Double(frame.size.height) - offsetBottom + 2))
            }
            toggle = !toggle
        }
        ctx?.strokePath()
        
        // Draw line
        ctx?.setStrokeColor(UIColor.white.cgColor)
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
