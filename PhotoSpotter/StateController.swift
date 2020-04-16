//
//  StateController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 02.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import CoreData


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
    func removeLens(_ atIndex: Int) {
        if lenses.count > atIndex {
            lenses.remove(at: atIndex)
        }
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
    func removeCamera(_ atIndex: Int) {
        if cameras.count > atIndex {
            cameras.remove(at: atIndex)
        }
    }
    
    
    // Views CoreData
    var viewsCD : [NSManagedObject] = []
    
    func loadViewsFromCD(appDelegate: AppDelegate) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: "ViewCD")
        
        do {
            viewsCD = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch views from CoreData. \(error), \(error.userInfo)")
        }
        
        updateViewsFromCD()
    }
    func storeViewsToCD(appDelegate: AppDelegate) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity         = NSEntityDescription.entity(forEntityName: "ViewCD", in: managedContext)!
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: "ViewCD")
        
        for view in views {
            let predicate = NSPredicate(format: "%K == %@", "name", view.name)
            fetchRequest.predicate = predicate
            do {
                let fetchResult = try managedContext.fetch(fetchRequest).first
                if fetchResult != nil {
                    // Update
                    let viewCD = fetchResult!
                    viewCD.setValue(view.description, forKeyPath: "desc")
                    viewCD.setValue(view.cameraPoint.coordinate.latitude, forKeyPath: "cameraLat")
                    viewCD.setValue(view.cameraPoint.coordinate.longitude, forKeyPath: "cameraLon")
                    viewCD.setValue(view.motifPoint.coordinate.latitude, forKeyPath: "motifLat")
                    viewCD.setValue(view.motifPoint.coordinate.longitude, forKeyPath: "motifLon")
                    viewCD.setValue(view.camera.name, forKeyPath: "cameraName")
                    viewCD.setValue(view.camera.sensorFormat.rawValue, forKeyPath: "sensorName")
                    viewCD.setValue(view.lens.name, forKeyPath: "lensName")
                    viewCD.setValue(view.lens.minFocalLength, forKeyPath: "minFocalLength")
                    viewCD.setValue(view.lens.maxFocalLength, forKeyPath: "maxFocalLength")
                    viewCD.setValue(view.lens.minAperture, forKeyPath: "minAperture")
                    viewCD.setValue(view.lens.maxAperture, forKeyPath: "maxAperture")
                    viewCD.setValue(view.focalLength, forKeyPath: "focalLength")
                    viewCD.setValue(view.aperture, forKeyPath: "aperture")
                    viewCD.setValue(view.orientation.rawValue, forKeyPath: "orientation")
                    viewCD.setValue(view.mapRect.origin.coordinate.latitude, forKeyPath: "originLat")
                    viewCD.setValue(view.mapRect.origin.coordinate.longitude, forKeyPath: "originLon")
                    viewCD.setValue(view.mapRect.size.width, forKeyPath: "mapWidth")
                    viewCD.setValue(view.mapRect.size.height, forKeyPath: "mapHeight")
                    viewCD.setValue(view.tags, forKeyPath: "tags")
                    viewCD.setValue(view.equipment, forKeyPath: "equipment")
                } else {
                    // Insert
                    let viewCD = NSManagedObject(entity: entity, insertInto: managedContext)
                    viewCD.setValue(view.name, forKeyPath: "name")
                    viewCD.setValue(view.description, forKeyPath: "desc")
                    viewCD.setValue(view.cameraPoint.coordinate.latitude, forKeyPath: "cameraLat")
                    viewCD.setValue(view.cameraPoint.coordinate.longitude, forKeyPath: "cameraLon")
                    viewCD.setValue(view.motifPoint.coordinate.latitude, forKeyPath: "motifLat")
                    viewCD.setValue(view.motifPoint.coordinate.longitude, forKeyPath: "motifLon")
                    viewCD.setValue(view.camera.name, forKeyPath: "cameraName")
                    viewCD.setValue(view.camera.sensorFormat.rawValue, forKeyPath: "sensorName")
                    viewCD.setValue(view.lens.name, forKeyPath: "lensName")
                    viewCD.setValue(view.lens.minFocalLength, forKeyPath: "minFocalLength")
                    viewCD.setValue(view.lens.maxFocalLength, forKeyPath: "maxFocalLength")
                    viewCD.setValue(view.lens.minAperture, forKeyPath: "minAperture")
                    viewCD.setValue(view.lens.maxAperture, forKeyPath: "maxAperture")
                    viewCD.setValue(view.focalLength, forKeyPath: "focalLength")
                    viewCD.setValue(view.aperture, forKeyPath: "aperture")
                    viewCD.setValue(view.orientation.rawValue, forKeyPath: "orientation")
                    viewCD.setValue(view.mapRect.origin.coordinate.latitude, forKeyPath: "originLat")
                    viewCD.setValue(view.mapRect.origin.coordinate.longitude, forKeyPath: "originLon")
                    viewCD.setValue(view.mapRect.size.width, forKeyPath: "mapWidth")
                    viewCD.setValue(view.mapRect.size.height, forKeyPath: "mapHeight")
                    viewCD.setValue(view.tags, forKeyPath: "tags")
                    viewCD.setValue(view.equipment, forKeyPath: "equipment")
                }
            } catch let error as NSError {
                print("Error fetching view from CoreData. \(error), \(error.userInfo)")
            }
        }
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store views to CoreData. \(error), \(error.userInfo)")
        }
    }
    
    func addViewToCD(appDelegate: AppDelegate, view: View) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity         = NSEntityDescription.entity(forEntityName: "ViewCD", in: managedContext)!
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: "ViewCD")
        let predicate = NSPredicate(format: "%K == %@", "name", view.name)
        fetchRequest.predicate = predicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                return
            } else {
                let viewCD         = NSManagedObject(entity: entity, insertInto: managedContext)
                viewCD.setValue(view.name, forKeyPath: "name")
                viewCD.setValue(view.description, forKeyPath: "desc")
                viewCD.setValue(view.cameraPoint.coordinate.latitude, forKeyPath: "cameraLat")
                viewCD.setValue(view.cameraPoint.coordinate.longitude, forKeyPath: "cameraLon")
                viewCD.setValue(view.motifPoint.coordinate.latitude, forKeyPath: "motifLat")
                viewCD.setValue(view.motifPoint.coordinate.longitude, forKeyPath: "motifLon")
                viewCD.setValue(view.camera.name, forKeyPath: "cameraName")
                viewCD.setValue(view.camera.sensorFormat.rawValue, forKeyPath: "sensorName")
                viewCD.setValue(view.lens.name, forKeyPath: "lensName")
                viewCD.setValue(view.lens.minFocalLength, forKeyPath: "minFocalLength")
                viewCD.setValue(view.lens.maxFocalLength, forKeyPath: "maxFocalLength")
                viewCD.setValue(view.lens.minAperture, forKeyPath: "minAperture")
                viewCD.setValue(view.lens.maxAperture, forKeyPath: "maxAperture")
                viewCD.setValue(view.focalLength, forKeyPath: "focalLength")
                viewCD.setValue(view.aperture, forKeyPath: "aperture")
                viewCD.setValue(view.orientation.rawValue, forKeyPath: "orientation")
                viewCD.setValue(view.mapRect.origin.coordinate.latitude, forKeyPath: "originLat")
                viewCD.setValue(view.mapRect.origin.coordinate.longitude, forKeyPath: "originLon")
                viewCD.setValue(view.mapRect.size.width, forKeyPath: "mapWidth")
                viewCD.setValue(view.mapRect.size.height, forKeyPath: "mapHeight")
                viewCD.setValue(view.tags, forKeyPath: "tags")
                viewCD.setValue(view.equipment, forKeyPath: "equipment")
            }
        } catch let error as NSError {
            print("Error fetching view from CoreData. \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store views to CoreData. \(error), \(error.userInfo)")
        }
    }
    
    func updateViewInCD(appDelegate: AppDelegate, view: View) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: "ViewCD")
        let predicate      = NSPredicate(format: "%K == %@", "name", view.name)
        fetchRequest.predicate = predicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                let viewCD = fetchResult!
                viewCD.setValue(view.description, forKeyPath: "desc")
                viewCD.setValue(view.cameraPoint.coordinate.latitude, forKeyPath: "cameraLat")
                viewCD.setValue(view.cameraPoint.coordinate.longitude, forKeyPath: "cameraLon")
                viewCD.setValue(view.motifPoint.coordinate.latitude, forKeyPath: "motifLat")
                viewCD.setValue(view.motifPoint.coordinate.longitude, forKeyPath: "motifLon")
                viewCD.setValue(view.camera.name, forKeyPath: "cameraName")
                viewCD.setValue(view.camera.sensorFormat.rawValue, forKeyPath: "sensorName")
                viewCD.setValue(view.lens.name, forKeyPath: "lensName")
                viewCD.setValue(view.lens.minFocalLength, forKeyPath: "minFocalLength")
                viewCD.setValue(view.lens.maxFocalLength, forKeyPath: "maxFocalLength")
                viewCD.setValue(view.lens.minAperture, forKeyPath: "minAperture")
                viewCD.setValue(view.lens.maxAperture, forKeyPath: "maxAperture")
                viewCD.setValue(view.focalLength, forKeyPath: "focalLength")
                viewCD.setValue(view.aperture, forKeyPath: "aperture")
                viewCD.setValue(view.orientation.rawValue, forKeyPath: "orientation")
                viewCD.setValue(view.mapRect.origin.coordinate.latitude, forKeyPath: "originLat")
                viewCD.setValue(view.mapRect.origin.coordinate.longitude, forKeyPath: "originLon")
                viewCD.setValue(view.mapRect.size.width, forKeyPath: "mapWidth")
                viewCD.setValue(view.mapRect.size.height, forKeyPath: "mapHeight")
                viewCD.setValue(view.tags, forKeyPath: "tags")
                viewCD.setValue(view.equipment, forKeyPath: "equipment")
            } else {
                return
            }
        } catch let error as NSError {
            print("Error fetching view from CoreData. \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store views to CoreData. \(error), \(error.userInfo)")
        }
    }
    
    func removeViewFromCD(appDelegate: AppDelegate, view: View) -> Void {
        if view.name == Constants.DEFAULT_VIEW.name { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: "ViewCD")
        let predicate      = NSPredicate(format: "%K == %@", "name", view.name)
        fetchRequest.predicate = predicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                managedContext.delete(fetchResult!)
                try managedContext.save()
            } else {
                return
            }
        } catch let error as NSError {
            print("Error fetching view from CoreData. \(error), \(error.userInfo)")
        }
    }
    
    func updateViewsFromCD() -> Void {
        views.removeAll()
        for viewCD in viewsCD {
            let view = View(name          : viewCD.value(forKey: "name") as! String,
                            description   : viewCD.value(forKey: "desc") as! String,
                            cameraLat     : viewCD.value(forKey: "cameraLat") as! Double,
                            cameraLon     : viewCD.value(forKey: "cameraLon") as! Double,
                            motifLat      : viewCD.value(forKey: "motifLat") as! Double,
                            motifLon      : viewCD.value(forKey: "motifLon") as! Double,
                            cameraName    : viewCD.value(forKey: "cameraName") as! String,
                            sensorName    : viewCD.value(forKey: "sensorName") as! String,
                            lensName      : viewCD.value(forKey: "lensName") as! String,
                            minFocalLength: viewCD.value(forKey: "minFocalLength") as! Double,
                            maxFocalLength: viewCD.value(forKey: "maxFocalLength") as! Double,
                            minAperture   : viewCD.value(forKey: "minAperture") as! Double,
                            maxAperture   : viewCD.value(forKey: "maxAperture") as! Double,
                            focalLength   : viewCD.value(forKey: "focalLength") as! Double,
                            aperture      : viewCD.value(forKey: "aperture") as! Double,
                            orientation   : viewCD.value(forKey: "orientation") as! String,
                            originLat     : viewCD.value(forKey: "originLat") as! Double,
                            originLon     : viewCD.value(forKey: "originLon") as! Double,
                            mapWidth      : viewCD.value(forKey: "mapWidth") as! Double,
                            mapHeight     : viewCD.value(forKey: "mapHeight") as! Double,
                            tags          : viewCD.value(forKey: "tags") as! Int32,
                            equipment     : viewCD.value(forKey: "equipment") as! Int32)
            views.append(view)
        }
        for view in views {
            // check lens against lenses
            let lens      = view.lens
            let lensFound = self.lenses.filter { $0.name == lens.name }
            if lensFound.isEmpty {
                self.lenses.append(lens)
            }
            
            // check camera against cameras
            let camera      = view.camera
            let cameraFound = self.cameras.filter { $0.name == camera.name }
            if cameraFound.isEmpty {
                self.cameras.append(camera)
            }
        }
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
    func removeView(_ atIndex: Int) {
        if views.count > atIndex {
            views.remove(at: atIndex)
        }
    }
    
    
    // Current view
    private(set) var view : View = Constants.DEFAULT_VIEW
    func setView(_ view: View) {
        self.view = view
    }
    
    
    // MapView Type
    private(set) var mapType : Int = 0
    func updateMapType(_ mapType: Int) {
        self.mapType = mapType
    }
    
    
    // Store views to documents
    func storeViews() -> Void {
        Helper.saveViewsToDocuments(views: views)
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
            
            defaults.set(true, forKey: "useCloud")
            
            /* Store views in UserDefaults
            var viewDict : [Dictionary<String,String>] = []
            for view in views {
                let dictionary : Dictionary<String,String> = Helper.viewToDictionary(view: view)
                viewDict.append(dictionary)
            }
            let viewsData = try NSKeyedArchiver.archivedData(withRootObject: viewDict, requiringSecureCoding: false)
            defaults.set(viewsData, forKey: "views")
            
            print("Cameras, Lenses and views stored to defaults")
            */
        } catch {
            print("Error saving cameras and lenses: \(error)")
        }
        
        let dictionary : Dictionary<String,String> = Helper.viewToDictionary(view: self.view)
        defaults.set(dictionary, forKey: "view")
        print("Current view stored to defaults")
        
        defaults.set(self.mapType, forKey: "mapType")
        print("MapType stored to defaults")
    }
    
    // Retrieve from UserDefaults
    func retrieve() {
        let defaults = UserDefaults.standard
        if let lensesData = defaults.data(forKey: "lenses") {
            do {
                if let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(lensesData) as? [Lens] {
                    setLenses(array)
                }
            } catch {
                print("Error loading lenses from UserDefaults. \(error)")
            }
        }
        if let camerasData = defaults.data(forKey: "cameras") {
            do {
                if let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(camerasData) as? [Camera] {
                    setCameras(array)
                }
            } catch {
                print("Error loading cameras from UserDefaults. \(error)")
            }
        }
        
        /* Retrieve views from User defaults
        if let viewsData = UserDefaults.standard.data(forKey: "views") {
            do {
                guard let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(viewsData) as? [Dictionary<String,String>] else {
                    fatalError("Error loading views form UserDefaults")
                }
                var loadedViews : [View] = []
                for dict in array {
                    let view : View = Helper.dictionaryToView(dictionary: dict, cameras: self.cameras, lenses: self.lenses)
                    loadedViews.append(view)
                }
                setViews(loadedViews)
            } catch {
                fatalError("load views - Can't encode data: \(error)")
            }
        }
        */
        
        /* Retrieve views from iCloud documents json file
        if defaults.dictionary(forKey: "view") != nil {
        let dictionary : Dictionary<String,String> = defaults.dictionary(forKey: "view")! as! Dictionary<String,String>
            setView(Helper.dictionaryToView(dictionary: dictionary, cameras: self.cameras, lenses: self.lenses))
        } else {
            print("No view found in UserDefaults")
        }        
        if defaults.integer(forKey: "mapType") != 0 {
            updateMapType(defaults.integer(forKey: "mapType"))
        } else {
            print("No mapType found in UserDefaults")
        }
        
        let iCloudViews : [View] = Helper.loadViewsFromDocuments()
        print("Views found on iCloud:")
        
        for view in iCloudViews {
            // check lens against lenses
            let lens      = view.lens
            let lensFound = self.lenses.filter { $0.name == lens.name }
            if lensFound.isEmpty {
                self.lenses.append(lens)
            }
            
            // check camera against cameras
            let camera      = view.camera
            let cameraFound = self.cameras.filter { $0.name == camera.name }
            if cameraFound.isEmpty {
                self.cameras.append(camera)
            }
            
            print("View: \(view.name)")
        }
        setViews(iCloudViews)
        */                
    }
}
