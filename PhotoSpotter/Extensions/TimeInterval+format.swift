//
//  TimeInterval+format.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 26.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

extension TimeInterval {
    func format(using units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits           = units
        formatter.unitsStyle             = .abbreviated
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: self)
    }
}
