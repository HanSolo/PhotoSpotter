//
//  Array+removeDuplicates.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 22.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
