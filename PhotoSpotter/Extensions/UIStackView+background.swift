//
//  UIStackView+background.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 30.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit


extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor    = color
        subView.layer.cornerRadius = 5
        subView.autoresizingMask   = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
