//
//  FoVViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 02.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

protocol FoVController {
    var stateController    : StateController? {get set}
    var sentViaSegueObject : FoVController? {get set}
}
