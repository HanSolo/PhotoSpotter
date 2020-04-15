//
//  UIButton+imagealign.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 14.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public extension UIButton {

    func alignTextUnderImage(spacing: CGFloat = 6.0) {
      guard let image = imageView?.image, let label = titleLabel,
        let string = label.text else { return }

        titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0.0)
        let titleSize = string.size(withAttributes: [NSAttributedString.Key.font: label.font ?? UIFont.systemFont(ofSize: 17.0)])
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
    }
}
