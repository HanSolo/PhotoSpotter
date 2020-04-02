//
//  Orientation.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public enum Orientation: String {
    case landscape
    case portrait
    
    var name: String {
        switch self {
            case .landscape: return "Landscape"
            case .portrait : return "Portrait"
        }
    }

    var jsonString: String {
        var text : String = "{"
        text += "\"orientation\":\"\(self)\""
        text += "}"
        return text
    }
}
