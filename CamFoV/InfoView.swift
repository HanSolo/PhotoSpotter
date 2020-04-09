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
    
    
    public override func draw(_ rect: CGRect) {
        let offsetTop              : Double          = 20
        let offsetLeft             : Double          = 20
        let offsetLeftSecondColumn : Double          = 250
        let lineSpacing            : Double          = 28
        let unit                   : String          = " m"
        let numberFormatter        : NumberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator     = " "
        numberFormatter.groupingSize          = 3
        
        let ctx : CGContext? = UIGraphicsGetCurrentContext()
        
        ctx?.clear(self.frame)
        ctx?.setFillColor(UIColor.darkGray.withAlphaComponent(0.75).cgColor)
        ctx?.fill(rect)
        
        if let data = fovData {
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
            
            
            
            let hyperfocalText = NSAttributedString(string: "Hyperfocal", attributes: textAttributes)
            hyperfocalText.draw(at: CGPoint(x: offsetLeft, y: offsetTop))
            let hyperfocalValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.hyperFocal))! + unit, attributes: valueAttributes)
            hyperfocalValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(hyperfocalValueText.size().width), y: offsetTop))
            
            let nearLimitText = NSAttributedString(string: "Near limit", attributes: textAttributes)
            nearLimitText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + lineSpacing))
            let nearLimitValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.nearLimit))! + unit, attributes: valueAttributes)
            nearLimitValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(nearLimitValueText.size().width), y: offsetTop + lineSpacing))
            
            let farLimitText = NSAttributedString(string: "Far limit", attributes: textAttributes)
            farLimitText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 2 * lineSpacing))
            let farLimitValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.farLimit))! + unit, attributes: valueAttributes)
            farLimitValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(farLimitValueText.size().width), y: offsetTop + 2 * lineSpacing))
            
            let inFrontText = NSAttributedString(string: "In front", attributes: textAttributes)
            inFrontText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 3 * lineSpacing))
            let inFrontValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.dofInFront))! + unit, attributes: valueAttributes)
            inFrontValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(inFrontValueText.size().width), y: offsetTop + 3 * lineSpacing))
            
            let behindText = NSAttributedString(string: "Behind", attributes: textAttributes)
            behindText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 4 * lineSpacing))
            let behindValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.dofBehind))! + unit, attributes: valueAttributes)
            behindValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(behindValueText.size().width), y: offsetTop + 4 * lineSpacing))
            
            let totalText = NSAttributedString(string: "Total", attributes: textAttributes)
            totalText.draw(at: CGPoint(x: offsetLeft, y: offsetTop + 5 * lineSpacing))
            let totalValueText = NSAttributedString(string: numberFormatter.string(from: NSNumber(value: data.total))! + unit, attributes: valueAttributes)
            totalValueText.draw(at: CGPoint(x: offsetLeftSecondColumn - Double(totalValueText.size().width), y: offsetTop + 5 * lineSpacing))
        } else {
            
        }
    }
}
