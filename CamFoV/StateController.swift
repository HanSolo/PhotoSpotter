//
//  StateController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 02.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation


class StateController {
    
    // Lenses
    private(set) var lenses : [Lens] = [
        Constants.DEFAULT_LENS
    ]
    func updateLenses(_ lens: Lens) {
        for (index, old) in lenses.enumerated() {
            if old.name == lens.name {
                lenses[index] = lens
                break
            }
        }
    }
    func updateAllLenses(_ lenses: [Lens]) {
        self.lenses = lenses
    }
    
    
    // Cameras
    private(set) var cameras : [Camera] = [
        Constants.DEFAULT_CAMERA
    ]
    func updateCameras(_ camera: Camera) {
        for (index, old) in cameras.enumerated() {
            if old.name == camera.name {
                cameras[index] = camera
                break;
            }
        }
    }
    func updateAllCameras(_ cameras: [Camera]) {
        self.cameras = cameras
    }
    
    
    // Views
    private(set) var views : [View] = [
        Constants.DEFAULT_VIEW
    ]
    func updateViews(_ view: View) {
        for (index, old) in views.enumerated() {
            if old.name == view.name {
                views[index] = view
                break;
            }
        }
    }
    func updateAllViews(_ views: [View]) {
        self.views = views
    }
    
    
    // Current view
    private(set) var view : View = Constants.DEFAULT_VIEW
    func updateView(_ view: View) {
        self.view = view
    }
    
    
    // MapView Type
    private(set) var mapType : Int = 0
    func updateMapType(_ mapType: Int) {
        self.mapType = mapType
    }
    
    
    
    // Store to UserDefaults
    func store() {
        let defaults = UserDefaults.standard
        do {
            let camerasData = try NSKeyedArchiver.archivedData(withRootObject: self.cameras, requiringSecureCoding: false)
            defaults.set(camerasData, forKey: "cameras")
        
            let lensesData = try NSKeyedArchiver.archivedData(withRootObject: self.lenses, requiringSecureCoding: false)
            defaults.set(lensesData, forKey: "lenses")
        } catch {
            print(error)
        }
        let dictionary : Dictionary<String,String> = Helper.viewToDictionary(view: self.view)
        defaults.set(dictionary, forKey: "view")
        
        defaults.set(self.mapType, forKey: "mapType")
    }
    
    // Retrieve from UserDefaults
    func retrieve() {
        let defaults = UserDefaults.standard
        if let lensesData = UserDefaults.standard.data(forKey: "lenses") {
            do {
                guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(lensesData) as? [Lens] else {
                    fatalError("Error loading lenses form UserDefaults")
                }
                updateAllLenses(array)
            } catch {
                fatalError("load lenses - Can't encode data: \(error)")
            }
        }
        if let camerasData = UserDefaults.standard.data(forKey: "cameras") {
            do {
                guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(camerasData) as? [Camera] else {
                    fatalError("Error loading lenses form UserDefaults")
                }
                updateAllCameras(array)
            } catch {
                fatalError("load lenses - Can't encode data: \(error)")
            }
        }
        if defaults.dictionary(forKey: "view") != nil {
        let dictionary : Dictionary<String,String> = defaults.dictionary(forKey: "view")! as! Dictionary<String,String>
            updateView(Helper.dictionaryToView(dictionary: dictionary, cameras: self.cameras, lenses: self.lenses))
        } else {
            print("No view found in UserDefaults")
        }        
        if defaults.integer(forKey: "mapType") != 0 {
            updateMapType(defaults.integer(forKey: "mapType"))
        } else {
            print("No mapType found in UserDefaults")
        }
    }
}
