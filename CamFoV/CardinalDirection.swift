//
//  CardinalDirection.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public enum CardinalDirection {
    case N
    case NNE
    case NE
    case ENE
    case E
    case ESE
    case SE
    case SSE
    case S
    case SSW
    case SW
    case WSW
    case W
    case WNW
    case NW
    case NNW

    public var direction: String {
        switch self {
            case .N  : return "North"
            case .NNE: return "North North-East"
            case .NE : return "North-East"
            case .ENE: return "East North-East"
            case .E  : return "East"
            case .ESE: return "East South-East"
            case .SE : return "South-East"
            case .SSE: return "South South-East"
            case .S  : return "South"
            case .SSW: return "South South-West"
            case .SW : return "South-West"
            case .WSW: return "West South-West"
            case .W  : return "West"
            case .WNW: return "West North-West"
            case .NW : return "North-West"
            case .NNW: return "North North-West"
        }
    }
    
    public var from: Double {
        switch self {
            case .N  : return 348.75
            case .NNE: return 11.25
            case .NE : return 33.75
            case .ENE: return 56.25
            case .E  : return 78.75
            case .ESE: return 101.25
            case .SE : return 123.75
            case .SSE: return 146.25
            case .S  : return 168.75
            case .SSW: return 191.25
            case .SW : return 213.75
            case .WSW: return 236.25
            case .W  : return 258.75
            case .WNW: return 281.25
            case .NW : return 303.75
            case .NNW: return 326.25
        }
    }
    
    public var to: Double {
        switch self {
            case .N  : return 11.25
            case .NNE: return 33.75
            case .NE : return 56.25
            case .ENE: return 78.75
            case .E  : return 101.25
            case .ESE: return 123.75
            case .SE : return 146.25
            case .SSE: return 168.75
            case .S  : return 191.25
            case .SSW: return 213.75
            case .SW : return 236.25
            case .WSW: return 258.75
            case .W  : return 281.25
            case .WNW: return 303.75
            case .NW : return 326.25
            case .NNW: return 348.75
        }
    }
}
