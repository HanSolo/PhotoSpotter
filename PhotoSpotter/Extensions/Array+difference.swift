//
//  Array+difference.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 21.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    func diff(from other: [Element]) -> [Element] {
        let thisSet  = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
