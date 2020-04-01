//
//  SensorFormat.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public enum SensorFormat: String {
    case MEDIUM_FORMAT
    case FULL_FORMAT
    case APS_H
    case APS_C
    case APS_C_CANON
    case MICRO_FOUR_THIRDS
    
    var name: String {
        switch self {
            case .MEDIUM_FORMAT    : return "Medium Format"
            case .FULL_FORMAT      : return "Full Format"
            case .APS_H            : return "APS-H"
            case .APS_C            : return "APS-C"
            case .APS_C_CANON      : return "APS-C Canon"
            case .MICRO_FOUR_THIRDS: return "Micro 4/3"
        }
    }
    
    var width: Double {
        switch self {
            case .MEDIUM_FORMAT    : return 53.7
            case .FULL_FORMAT      : return 36
            case .APS_H            : return 27.9
            case .APS_C            : return 23.6
            case .APS_C_CANON      : return 22.2
            case .MICRO_FOUR_THIRDS: return 17.3
        }
    }
    
    var height: Double {
        switch self {
            case .MEDIUM_FORMAT    : return 40.2
            case .FULL_FORMAT      : return 23.9
            case .APS_H            : return 18.6
            case .APS_C            : return 15.8
            case .APS_C_CANON      : return 14.8
            case .MICRO_FOUR_THIRDS: return 13.0
        }
    }
    
    var cropFactor: Double {
        switch self {
            case .MEDIUM_FORMAT    : return 0.64
            case .FULL_FORMAT      : return 1.0
            case .APS_H            : return 1.29
            case .APS_C            : return 1.52
            case .APS_C_CANON      : return 1.6
            case .MICRO_FOUR_THIRDS: return 2.0
        }
    }
    
    var jsonString: String {
        var text: String = "{"
        text += "\"name\":\"\(self)\","
        text += "\"width\":\"\(width)\","
        text += "\"height\":\"\(height)\","
        text += "\"crop\":\"\(cropFactor)\""
        text += "}"
        return text
    }
}
