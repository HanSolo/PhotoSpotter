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
    func addLens(_ lens: Lens) {
        if lenses.contains(where: { $0.name == lens.name && $0.description() == lens.description() }) {
            return
        } else {
            lenses.append(lens)
        }
    }
    func setLenses(_ lenses: [Lens]) {
        self.lenses = lenses
    }
    func removeLens(_ lens: Lens) {
        lenses.removeAll { $0 === lens }
    }
    
    
    // Cameras
    private(set) var cameras : [Camera] = [
        Constants.DEFAULT_CAMERA
    ]
    func addCamera(_ camera: Camera) {
        if cameras.contains(where: { $0.name == camera.name && $0.sensorFormat == camera.sensorFormat }) {
            return
        } else {
            cameras.append(camera)
        }
    }
    func setCameras(_ cameras: [Camera]) {
        self.cameras = cameras
    }
    func removeCamera(_ camera: Camera) {
        cameras.removeAll { $0 === camera }
    }
    
    
    // Views
    private(set) var views : [View] = [
        Constants.DEFAULT_VIEW
    ]
    func addView(_ view: View) {
        if views.contains(where: { $0.name == view.name }) {
            return
        } else {
            views.append(view)
        }
    }
    func setViews(_ views: [View]) {
        self.views = views
    }
    func removeView(_ view: View) {
        views.removeAll { $0 === view }
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
            print("Cameras and Lenses stored to defaults")
        } catch {
            print("Error saving cameras and lenses: \(error)")
        }
        let dictionary : Dictionary<String,String> = Helper.viewToDictionary(view: self.view)
        defaults.set(dictionary, forKey: "view")
        print("Views stored to defaults")
        
        defaults.set(self.mapType, forKey: "mapType")
        print("MapType stored to defaults")
    }
    
    // Retrieve from UserDefaults
    func retrieve() {
        let defaults = UserDefaults.standard
        if let lensesData = UserDefaults.standard.data(forKey: "lenses") {
            do {
                guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(lensesData) as? [Lens] else {
                    fatalError("Error loading lenses form UserDefaults")
                }
                setLenses(array)
            } catch {
                fatalError("load lenses - Can't encode data: \(error)")
            }
        }
        if let camerasData = UserDefaults.standard.data(forKey: "cameras") {
            do {
                guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(camerasData) as? [Camera] else {
                    fatalError("Error loading cameras form UserDefaults")
                }
                setCameras(array)
            } catch {
                fatalError("load cameras - Can't encode data: \(error)")
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
