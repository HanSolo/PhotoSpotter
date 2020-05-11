//
//  InfoView.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 09.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit
import MapKit


public class InfoView: UIView {
    var fovData : FoVData?
    var sunMoon : SunMoon?
    var date    : Date = Date()
    
    
    public override func draw(_ rect: CGRect) {
        let offsetTop              : Double          = 20
        let offsetLeft             : Double          = 20
        let offsetLeftSecondColumn : Double          = 280
        let lineSpacing            : Double          = 28
        let numberFormatter        : NumberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator     = " "
        numberFormatter.groupingSize          = 3
        
        let ctx : CGContext? = UIGraphicsGetCurrentContext()
        
        ctx?.clear(self.frame)
        ctx?.setFillColor(Constants.TRANSLUCENT_GRAY.cgColor)
        ctx?.fill(rect)
        
        let font = UIFont.systemFont(ofSize: 16)
        let paragraphText = NSMutableParagraphStyle()
        paragraphText.alignment = .left
        
        let paragraphValue = NSMutableParagraphStyle()
        paragraphValue.alignment = .right
        
        let textAttributes = [NSAttributedString.Key.font: font,
                              NSAttributedString.Key.foregroundColor: Constants.YELLOW,
                              NSAttributedString.Key.paragraphStyle: paragraphText]
        
        let valueAttributes = [NSAttributedString.Key.font: font,
                               NSAttributedString.Key.foregroundColor: UIColor.lightText,
        NSAttributedString.Key.paragraphStyle: paragraphValue]
        
        // FoV Data
        if let data = fovData {
            let hyperfocalText = NSAttributedString(string: "Hyperfocal", attributes: textAttributes)
            hyperfocalText.draw(at: CGPoint(x: offsetLeft, y: offsetTop))
            let hyperfocalValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.hyperFocal))! + Constants.UNIT_LENGTH, attributes: valueAttributes)
            hyperfocalValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(hyperfocalValueText.size().width), y: offsetTop))
            
            let nearLimitText = NSAttributedString(string: "Near limit", attributes: textAttributes)
            nearLimitText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + lineSpacing))
            let nearLimitValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.nearLimit))! + Constants.UNIT_LENGTH, attributes: valueAttributes)
            nearLimitValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(nearLimitValueText.size().width), y: offsetTop + lineSpacing))
            
            let farLimitText = NSAttributedString(string: "Far limit", attributes: textAttributes)
            farLimitText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 2 * lineSpacing))
            let farLimitValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.farLimit))! + Constants.UNIT_LENGTH, attributes: valueAttributes)
            farLimitValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(farLimitValueText.size().width), y: offsetTop + 2 * lineSpacing))
            
            let inFrontText = NSAttributedString(string: "In front", attributes: textAttributes)
            inFrontText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 3 * lineSpacing))
            let inFrontValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.dofInFront))! + Constants.UNIT_LENGTH, attributes: valueAttributes)
            inFrontValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(inFrontValueText.size().width), y: offsetTop + 3 * lineSpacing))
            
            let behindText = NSAttributedString(string: "Behind", attributes: textAttributes)
            behindText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 4 * lineSpacing))
            let behindValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.dofBehind))! + Constants.UNIT_LENGTH, attributes: valueAttributes)
            behindValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(behindValueText.size().width), y: offsetTop + 4 * lineSpacing))
            
            let totalText = NSAttributedString(string: "Total", attributes: textAttributes)
            totalText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 5 * lineSpacing))
            let totalValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.total))! + Constants.UNIT_LENGTH, attributes: valueAttributes)
            totalValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(totalValueText.size().width), y: offsetTop + 5 * lineSpacing))
            
            // Sunrise / Sunset Data
            if let suncalc = sunMoon {
                let sunEvents : Dictionary<String, String> = suncalc.getSunEvents(date: date, lat: data.camera.coordinate.latitude, lon: data.camera.coordinate.longitude)
                let sunText = NSAttributedString(string: "Sunrise/Sunset", attributes: textAttributes)
                sunText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 6 * lineSpacing))
                let sunValueText = NSAttributedString(string: "\(sunEvents[Constants.EPD_SUNRISE]!) / \(sunEvents[Constants.EPD_SUNSET]!)", attributes: valueAttributes)
                sunValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(totalValueText.size().width), y: offsetTop + 6 * lineSpacing))
                
                let moonEvents : Dictionary<String, String> = suncalc.getMoonEvents(date: date, lat: data.camera.coordinate.latitude, lon: data.camera.coordinate.longitude)
                let moonText = NSAttributedString(string: "Moonrise/Moonset", attributes: textAttributes)
                moonText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 7 * lineSpacing))
                
                let moonValueText = NSAttributedString(string: "\(moonEvents[Constants.EPD_MOONRISE]!) / \(moonEvents[Constants.EPD_MOONSET]!)", attributes: valueAttributes)
                moonValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(totalValueText.size().width), y: offsetTop + 7 * lineSpacing))
            }
        }
    }
}
