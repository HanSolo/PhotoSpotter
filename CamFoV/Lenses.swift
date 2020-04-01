//
//  Lenses.swift
//  FoV
//
//  Created by Gerrit Grunwald on 20.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

public class Lenses {
    var lenses : [String:Lens] = [
        "TAMRON_SP_15_30"   : Lens(name: "Tamron SP 15-30mm f2.8", minFocalLength: 15, maxFocalLength: 30, minAperture: 2.8, maxAperture: 22),
        "TAMRON_SP_24_70"   : Lens(name: "Tamron SP 24-70mm f2.8", minFocalLength: 24, maxFocalLength: 70, minAperture: 2.8, maxAperture: 22),
        "TAMRON_SP_35"      : Lens(name: "Tamron SP 35mm f1.8", focalLength: 35, minAperture: 1.8, maxAperture: 22),
        "TAMRON_SP_90_MACRO": Lens(name: "Tamron SP 90mm f2.8 Macro", focalLength: 90, minAperture: 2.8, maxAperture: 32),
        "SIGMA_14"          : Lens(name: "Sigma 14mm f1.8 ART", focalLength: 14, minAperture: 1.8, maxAperture: 22),
        "SIGMA_105"         : Lens(name: "Sigma 105mm f1.4 ART", focalLength: 105, minAperture: 1.4, maxAperture: 22),
        "TOKINA_50"         : Lens(name: "Tokina 50mm f1.4 Opera", focalLength: 50, minAperture: 1.4, maxAperture: 22),
        "NIKON_85"          : Lens(name: "Nikon 85mm f1.8", focalLength: 85, minAperture: 1.8, maxAperture: 22),
        "NIKON_24_70"       : Lens(name: "Nikon 24-70mm f2.8", minFocalLength: 24, maxFocalLength: 70, minAperture: 2.8, maxAperture: 22),
        "NIKON_70_200"      : Lens(name: "Nikon 70-200mm f2.8", minFocalLength: 70, maxFocalLength: 200, minAperture: 2.8, maxAperture: 22),
        "NIKON_200_500"     : Lens(name: "Nikon 200-500mm f5.6", minFocalLength: 200, maxFocalLength: 500, minAperture: 5.6, maxAperture: 22),
        "IRIX_11"           : Lens(name: "Irix 11mm f4", focalLength: 11, minAperture: 4, maxAperture: 22),
        "MAK_1000"          : Lens(name: "MAK 1000", focalLength: 1000, minAperture: 10, maxAperture: 10)
    ]
}
