//
//  StateController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 02.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation


class StateController {
    
    // Current spot
    private(set) var spot : Spot = Constants.DEFAULT_SPOT
    func setSpot(_ spot: Spot) {
        self.spot = spot.clone()
    }
    
    
    // Current view
    private(set) var view : View = Constants.DEFAULT_VIEW
    func setView(_ view: View) {
        self.view = view.clone()
    }
    
    
    // Last location
    private(set) var lastLocation : CLLocation = CLLocation(latitude: Constants.DEFAULT_POSITION.coordinate.latitude, longitude: Constants.DEFAULT_POSITION.coordinate.longitude)
    func setLastLocation(_ location: CLLocation) {
        self.lastLocation = location        
    }
    
    
    // Lenses
    private(set) var lenses : [Lens] = [
        Constants.DEFAULT_LENS
    ]
    func addLens(_ lens: Lens) {
        if isLensInLenses(lens: lens) {
            return
        } else {
            lenses.append(lens)
        }
    }
    func setLenses(_ lenses: [Lens]) {
        self.lenses = lenses
    }
    func removeLens(_ lens: Lens) {
        let lensesToRemove : [Lens] = lenses.filter({ $0.name           == lens.name &&
                                                      $0.minFocalLength == lens.minFocalLength &&
                                                      $0.maxFocalLength == lens.maxFocalLength &&
                                                      $0.minAperture    == lens.minAperture &&
                                                      $0.maxAperture    == lens.maxAperture &&
                                                      $0.sensorFormat   == lens.sensorFormat
        })
        lenses.removeAll(where: { lensesToRemove.contains($0) })
    }
    func isLensInLenses(lens: Lens) -> Bool {
        return lenses.filter({ $0.name == lens.name && $0.minFocalLength == lens.minFocalLength && $0.maxFocalLength == lens.maxFocalLength && $0.minAperture == lens.minAperture && $0.maxAperture == lens.maxAperture && $0.sensorFormat == lens.sensorFormat }).count >= 1
    }
    
    
    // Cameras
    private(set) var cameras : [Camera] = [
        Constants.DEFAULT_CAMERA
    ]
    func addCamera(_ camera: Camera) {
        if isCameraInCameras(camera: camera) {
            return
        } else {
            cameras.append(camera)
        }
    }
    func setCameras(_ cameras: [Camera]) {
        self.cameras = cameras
    }
    func removeCamera(_ camera: Camera) {
        //cameras.removeAll { $0 === camera }
        let camerasToRemove : [Camera] = cameras.filter({ $0.name         == camera.name &&
                                                          $0.sensorFormat == camera.sensorFormat })
        cameras.removeAll(where: { camerasToRemove.contains($0) })        
    }
    func isCameraInCameras(camera: Camera) -> Bool {
        return cameras.filter({ $0.name == camera.name && $0.sensorFormat == camera.sensorFormat }).count >= 1
    }
    
    
    // Spots
    private(set) var spots : [Spot] = []
    func addSpot(_ spot: Spot) {
        if isSpotInSpots(spot: spot) {
            return
        } else {
            spots.append(spot)
        }
    }
    func setSpots(_ spots: [Spot]) {
        self.spots = spots
    }
    func removeSpot(_ spot: Spot) {
        let spotsToRemove : [Spot] = spots.filter({ $0.name        == spot.name &&
                                                    $0.description == spot.description &&
                                                    $0.country     == spot.country &&
                                                    $0.tags        == spot.tags })
        spots.removeAll(where: { spotsToRemove.contains($0) })
    }
    func isSpotInSpots(spot: Spot) -> Bool {
        return spots.filter({ $0.name        == spot.name &&
                              $0.description == spot.description &&
                              $0.country     == spot.country &&
                              $0.tags        == spot.tags }).count >= 1
    }
    
    
    // Views
    private(set) var views : [View] = [
        Constants.DEFAULT_VIEW
    ]
    func addView(_ view: View) {
        if isViewInViews(view: view) {
            return
        } else {
            views.append(view)
        }
    }
    func setViews(_ views: [View]) {
        self.views = views
    }
    func removeView(_ view: View) {
        //views.removeAll { $0 === view }
        let viewsToRemove : [View] = views.filter({ $0.name        == view.name &&
                                                    $0.description == view.description &&
                                                    $0.focalLength == view.focalLength &&
                                                    $0.aperture    == view.aperture })
        views.removeAll(where: { viewsToRemove.contains($0) })
    }
    func isViewInViews(view: View) -> Bool {
        return views.filter({ $0.name == view.name && $0.description == view.description && $0.tags == view.tags && $0.equipment == view.equipment }).count >= 1
    }
    
    
    // Lenses CoreData
    var lensesCD : [NSManagedObject] = []
    func loadLensesFromCD(appDelegate: AppDelegate) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: Constants.LENS_CD)
        
        do {
            lensesCD = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch lenses from CoreData. \(error), \(error.userInfo)")
        }        
        
        mergeLenses(appDelegate: appDelegate)
    }
    func storeLensesToCD(appDelegate: AppDelegate) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity         = NSEntityDescription.entity(forEntityName: Constants.LENS_CD, in: managedContext)!
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: Constants.LENS_CD)
        
        for lens in lenses {
            let predicateName           = NSPredicate(format: "%K == %@", Constants.NAME_CD,             lens.name)
            //let predicateSensorFormat   = NSPredicate(format: "%K == %@", Constants.SENSOR_FORMAT_CD,    lens.sensorFormat)
            //let predicateMinAperture    = NSPredicate(format: "%K == %@", Constants.MIN_APERTURE_CD,     lens.minAperture)
            //let predicateMaxAperture    = NSPredicate(format: "%K == %@", Constants.MAX_APERTURE_CD,     lens.maxAperture)
            //let predicateMinFocalLength = NSPredicate(format: "%K == %@", Constants.MIN_FOCAL_LENGTH_CD, lens.minFocalLength)
            //let predicateMaxFocalLength = NSPredicate(format: "%K == %@", Constants.MAX_FOCAL_LENGTH_CD, lens.maxFocalLength)
            //let compoundPredicate       = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateMinAperture, predicateMaxAperture, predicateMinFocalLength, predicateMaxFocalLength])
            
            //fetchRequest.predicate = compoundPredicate
            fetchRequest.predicate = predicateName
            do {
                let fetchResult = try managedContext.fetch(fetchRequest).first
                if fetchResult != nil {
                    // Update
                    let lensCD = fetchResult!
                    lensCD.setValue(lens.minFocalLength, forKeyPath: Constants.MIN_FOCAL_LENGTH_CD)
                    lensCD.setValue(lens.maxFocalLength, forKeyPath: Constants.MAX_FOCAL_LENGTH_CD)
                    lensCD.setValue(lens.minAperture,    forKeyPath: Constants.MIN_APERTURE_CD)
                    lensCD.setValue(lens.maxAperture,    forKeyPath: Constants.MAX_APERTURE_CD)
                    lensCD.setValue(lens.sensorFormat,   forKeyPath: Constants.SENSOR_FORMAT_CD)
                } else {
                    // Insert
                    let lensCD = NSManagedObject(entity: entity, insertInto: managedContext)
                    lensCD.setValue(lens.name,           forKeyPath: Constants.NAME_CD)
                    lensCD.setValue(lens.minFocalLength, forKeyPath: Constants.MIN_FOCAL_LENGTH_CD)
                    lensCD.setValue(lens.maxFocalLength, forKeyPath: Constants.MAX_FOCAL_LENGTH_CD)
                    lensCD.setValue(lens.minAperture,    forKeyPath: Constants.MIN_APERTURE_CD)
                    lensCD.setValue(lens.maxAperture,    forKeyPath: Constants.MAX_APERTURE_CD)
                    lensCD.setValue(lens.sensorFormat,   forKeyPath: Constants.SENSOR_FORMAT_CD)
                }
            } catch let error as NSError {
                print("Error fetching lens from CoreData. \(error), \(error.userInfo)")
            }
        }
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store lens to CoreData. \(error), \(error.userInfo)")
        }
    }
    func addLensToCD(appDelegate: AppDelegate, lens: Lens) -> Void {
        let managedContext          = appDelegate.persistentContainer.viewContext
        let entity                  = NSEntityDescription.entity(forEntityName: Constants.LENS_CD, in: managedContext)!
        let fetchRequest            = NSFetchRequest<NSManagedObject>(entityName: Constants.LENS_CD)
        let predicateName           = NSPredicate(format: "%K == %@", Constants.NAME_CD,             lens.name)
        //let predicateMinAperture    = NSPredicate(format: "%K == %@", Constants.MIN_APERTURE_CD,     lens.minAperture)
        //let predicateMaxAperture    = NSPredicate(format: "%K == %@", Constants.MAX_APERTURE_CD,     lens.maxAperture)
        //let predicateMinFocalLength = NSPredicate(format: "%K == %@", Constants.MIN_FOCAL_LENGTH_CD, lens.minFocalLength)
        //let predicateMaxFocalLength = NSPredicate(format: "%K == %@", Constants.MAX_FOCAL_LENGTH_CD, lens.maxFocalLength)
        //let compoundPredicate       = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateMinAperture, predicateMaxAperture, predicateMinFocalLength, predicateMaxFocalLength])
        
        //fetchRequest.predicate = compoundPredicate
        fetchRequest.predicate = predicateName
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                return
            } else {
                let lensCD         = NSManagedObject(entity: entity, insertInto: managedContext)
                lensCD.setValue(lens.name,           forKeyPath: Constants.NAME_CD)
                lensCD.setValue(lens.minFocalLength, forKeyPath: Constants.MIN_FOCAL_LENGTH_CD)
                lensCD.setValue(lens.maxFocalLength, forKeyPath: Constants.MAX_FOCAL_LENGTH_CD)
                lensCD.setValue(lens.minAperture,    forKeyPath: Constants.MIN_APERTURE_CD)
                lensCD.setValue(lens.maxAperture,    forKeyPath: Constants.MAX_APERTURE_CD)
                lensCD.setValue(lens.sensorFormat,   forKeyPath: Constants.SENSOR_FORMAT_CD)
            }
        } catch let error as NSError {
            print("Error fetching lens from CoreData. \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store lens to CoreData. \(error), \(error.userInfo)")
        }
    }
    func updateLensInCD(appDelegate: AppDelegate, lens: Lens) -> Void {
        let managedContext          = appDelegate.persistentContainer.viewContext
        let fetchRequest            = NSFetchRequest<NSManagedObject>(entityName: Constants.LENS_CD)
        let predicateName           = NSPredicate(format: "%K == %@", Constants.NAME_CD,             lens.name)
        let predicateMinAperture    = NSPredicate(format: "%K == %@", Constants.MIN_APERTURE_CD,     lens.minAperture)
        let predicateMaxAperture    = NSPredicate(format: "%K == %@", Constants.MAX_APERTURE_CD,     lens.maxAperture)
        let predicateMinFocalLength = NSPredicate(format: "%K == %@", Constants.MIN_FOCAL_LENGTH_CD, lens.minFocalLength)
        let predicateMaxFocalLength = NSPredicate(format: "%K == %@", Constants.MAX_FOCAL_LENGTH_CD, lens.maxFocalLength)
        let compoundPredicate       = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateMinAperture, predicateMaxAperture, predicateMinFocalLength, predicateMaxFocalLength])
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                let lensCD = fetchResult!
                lensCD.setValue(lens.minFocalLength, forKeyPath: Constants.MIN_FOCAL_LENGTH_CD)
                lensCD.setValue(lens.maxFocalLength, forKeyPath: Constants.MAX_FOCAL_LENGTH_CD)
                lensCD.setValue(lens.minAperture,    forKeyPath: Constants.MIN_APERTURE_CD)
                lensCD.setValue(lens.maxAperture,    forKeyPath: Constants.MAX_APERTURE_CD)
            } else {
                return
            }
        } catch let error as NSError {
            print("Error fetching lens from CoreData. \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store lens to CoreData. \(error), \(error.userInfo)")
        }
    }
    func removeLensFromCD(appDelegate: AppDelegate, lens: Lens) -> Void {
        if lens.name == Constants.DEFAULT_LENS.name { return }
        
        let managedContext          = appDelegate.persistentContainer.viewContext
        let fetchRequest            = NSFetchRequest<NSManagedObject>(entityName: Constants.LENS_CD)
        let predicateName           = NSPredicate(format: "%K == %@", Constants.NAME_CD,             lens.name)
        let predicateMinAperture    = NSPredicate(format: "%K == %@", Constants.MIN_APERTURE_CD,     lens.minAperture)
        let predicateMaxAperture    = NSPredicate(format: "%K == %@", Constants.MAX_APERTURE_CD,     lens.maxAperture)
        let predicateMinFocalLength = NSPredicate(format: "%K == %@", Constants.MIN_FOCAL_LENGTH_CD, lens.minFocalLength)
        let predicateMaxFocalLength = NSPredicate(format: "%K == %@", Constants.MAX_FOCAL_LENGTH_CD, lens.maxFocalLength)
        let compoundPredicate       = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateMinAperture, predicateMaxAperture, predicateMinFocalLength, predicateMaxFocalLength])
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                managedContext.delete(fetchResult!)
                try managedContext.save()
            } else {
                return
            }
        } catch let error as NSError {
            print("Error fetching lens from CoreData. \(error), \(error.userInfo)")
        }
    }
    func isLensInCD(appDelegate: AppDelegate, lens: Lens) -> Bool {
        let managedContext          = appDelegate.persistentContainer.viewContext
        let fetchRequest            = NSFetchRequest<NSManagedObject>(entityName: Constants.LENS_CD)
        let predicateName           = NSPredicate(format: "%K == %@", Constants.NAME_CD,             lens.name)
        //let predicateMinAperture    = NSPredicate(format: "%K == %@", Constants.MIN_APERTURE_CD,     lens.minAperture)
        //let predicateMaxAperture    = NSPredicate(format: "%K == %@", Constants.MAX_APERTURE_CD,     lens.maxAperture)
        //let predicateMinFocalLength = NSPredicate(format: "%K == %@", Constants.MIN_FOCAL_LENGTH_CD, lens.minFocalLength)
        //let predicateMaxFocalLength = NSPredicate(format: "%K == %@", Constants.MAX_FOCAL_LENGTH_CD, lens.maxFocalLength)
        //let compoundPredicate       = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateMinAperture, predicateMaxAperture, predicateMinFocalLength, predicateMaxFocalLength])
        
        //fetchRequest.predicate = compoundPredicate
        fetchRequest.predicate = predicateName
        do {
            if (try managedContext.fetch(fetchRequest).first) != nil {
                return true
            } else {
                return false
            }
        } catch {
            print("Error checking core data for lens.\(error)")
        }
        return false
    }
    func mergeLenses(appDelegate: AppDelegate) -> Void {
        var lensesInCoreData : [Lens] = []
        for lensCD in lensesCD {
            let lens = Lens(name          : lensCD.value(forKey: Constants.NAME_CD)             as! String,
                            minFocalLength: lensCD.value(forKey: Constants.MIN_FOCAL_LENGTH_CD) as! Double,
                            maxFocalLength: lensCD.value(forKey: Constants.MAX_FOCAL_LENGTH_CD) as! Double,
                            minAperture   : lensCD.value(forKey: Constants.MIN_APERTURE_CD)     as! Double,
                            maxAperture   : lensCD.value(forKey: Constants.MAX_APERTURE_CD)     as! Double,
                            sensorFormat  : lensCD.value(forKey: Constants.SENSOR_FORMAT_CD)    as! Int64)
            lensesInCoreData.append(lens)
        }
        for lens in lensesInCoreData {
            if !isLensInLenses(lens: lens) {
                addLens(lens)
            }
        }
        for lens in lenses {
            if !isLensInCD(appDelegate: appDelegate, lens: lens) {                
                addLensToCD(appDelegate: appDelegate, lens: lens)
            }
        }
    }
    
    
    // Cameras CoreData
    var camerasCD : [NSManagedObject] = []
    func loadCamerasFromCD(appDelegate: AppDelegate) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: Constants.CAMERA_CD)
        
        do {
            camerasCD = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch cameras from CoreData. \(error), \(error.userInfo)")
        }
        
        mergeCameras(appDelegate: appDelegate)
    }
    func storeCamerasToCD(appDelegate: AppDelegate) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity         = NSEntityDescription.entity(forEntityName: Constants.CAMERA_CD, in: managedContext)!
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: Constants.CAMERA_CD)
        
        for camera in cameras {
            let predicateName         = NSPredicate(format: "%K == %@", Constants.NAME_CD,          camera.name)
            //let predicateSensorFormat = NSPredicate(format: "%K == %@", Constants.SENSOR_FORMAT_CD, camera.sensorFormat)
            //let compoundPredicate     = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateSensorFormat])
            
            fetchRequest.predicate = predicateName
            do {
                let fetchResult = try managedContext.fetch(fetchRequest).first
                if fetchResult != nil {
                    // Update
                    let cameraCD = fetchResult!
                    cameraCD.setValue(camera.sensorFormat, forKeyPath: Constants.SENSOR_FORMAT_CD)
                } else {
                    // Insert
                    let cameraCD = NSManagedObject(entity: entity, insertInto: managedContext)
                    cameraCD.setValue(camera.name,         forKeyPath: Constants.NAME_CD)
                    cameraCD.setValue(camera.sensorFormat, forKeyPath: Constants.SENSOR_FORMAT_CD)
                }
            } catch let error as NSError {
                print("Error fetching camera from CoreData. \(error), \(error.userInfo)")
            }
        }
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store cameras to CoreData. \(error), \(error.userInfo)")
        }
    }
    func addCameraToCD(appDelegate: AppDelegate, camera: Camera) -> Void {
        let managedContext        = appDelegate.persistentContainer.viewContext
        let entity                = NSEntityDescription.entity(forEntityName: Constants.CAMERA_CD, in: managedContext)!
        let fetchRequest          = NSFetchRequest<NSManagedObject>(entityName: Constants.CAMERA_CD)
        let predicateName         = NSPredicate(format: "%K == %@", Constants.NAME_CD,          camera.name)
        //let predicateSensorFormat = NSPredicate(format: "%K == %@", Constants.SENSOR_FORMAT_CD, camera.sensorFormat)
        //let compoundPredicate     = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateSensorFormat])
        
        fetchRequest.predicate = predicateName
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                return
            } else {
                let cameraCD = NSManagedObject(entity: entity, insertInto: managedContext)
                cameraCD.setValue(camera.name,         forKeyPath: Constants.NAME_CD)
                cameraCD.setValue(camera.sensorFormat, forKeyPath: Constants.SENSOR_FORMAT_CD)
            }
        } catch let error as NSError {
            print("Error fetching camera from CoreData. \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store camera to CoreData. \(error), \(error.userInfo)")
        }
    }
    func updateCameraInCD(appDelegate: AppDelegate, camera: Camera) -> Void {
        let managedContext        = appDelegate.persistentContainer.viewContext
        let fetchRequest          = NSFetchRequest<NSManagedObject>(entityName: Constants.CAMERA_CD)
        let predicateName         = NSPredicate(format: "%K == %@", Constants.NAME_CD,          camera.name)
        //let predicateSensorFormat = NSPredicate(format: "%K == %@", Constants.SENSOR_FORMAT_CD, camera.sensorFormat)
        //let compoundPredicate     = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateSensorFormat])
        
        fetchRequest.predicate = predicateName
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                let cameraCD = fetchResult!
                cameraCD.setValue(camera.sensorFormat, forKeyPath: Constants.SENSOR_FORMAT_CD)
            } else {
                return
            }
        } catch let error as NSError {
            print("Error fetching camera from CoreData. \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store camera to CoreData. \(error), \(error.userInfo)")
        }
    }
    func removeCameraFromCD(appDelegate: AppDelegate, camera: Camera) -> Void {
        if camera.name == Constants.DEFAULT_CAMERA.name { return }
        
        let managedContext        = appDelegate.persistentContainer.viewContext
        let fetchRequest          = NSFetchRequest<NSManagedObject>(entityName: Constants.CAMERA_CD)
        let predicateName         = NSPredicate(format: "%K == %@", Constants.NAME_CD,          camera.name)
        //let predicateSensorFormat = NSPredicate(format: "%K == %@", Constants.SENSOR_FORMAT_CD, camera.sensorFormat)
        //let compoundPredicate     = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateSensorFormat])
        
        fetchRequest.predicate = predicateName
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                managedContext.delete(fetchResult!)
                try managedContext.save()
            } else {
                return
            }
        } catch let error as NSError {
            print("Error fetching camera from CoreData. \(error), \(error.userInfo)")
        }
    }
    func isCameraInCD(appDelegate: AppDelegate, camera: Camera) -> Bool {
        let managedContext        = appDelegate.persistentContainer.viewContext
        let fetchRequest          = NSFetchRequest<NSManagedObject>(entityName: Constants.CAMERA_CD)
        let predicateName         = NSPredicate(format: "%K == %@", Constants.NAME_CD,          camera.name)
        //let predicateSensorFormat = NSPredicate(format: "%K == %@", Constants.SENSOR_FORMAT_CD, camera.sensorFormat)
        //let compoundPredicate     = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateSensorFormat])
        
        fetchRequest.predicate = predicateName
        do {
            if (try managedContext.fetch(fetchRequest).first) != nil {
                return true
            } else {
                return false
            }
        } catch {
            print("Error checking core data for camera.\(error)")
        }
        return false
    }
    func mergeCameras(appDelegate: AppDelegate) -> Void {
        var camerasInCoreData : [Camera] = []
        for cameraCD in camerasCD {
            let camera = Camera(name        : cameraCD.value(forKey: Constants.NAME_CD) as! String,
                                sensorFormat: cameraCD.value(forKey: Constants.SENSOR_FORMAT_CD) as! Int64)
            camerasInCoreData.append(camera)
        }
        
        for camera in camerasInCoreData {
            if !isCameraInCameras(camera: camera) {
                addCamera(camera)
            }
        }
        for camera in cameras {
            if !isCameraInCD(appDelegate: appDelegate, camera: camera) {
                addCameraToCD(appDelegate: appDelegate, camera: camera)
            }
        }
    }
    
    
    // Spots CoreData
    var spotsCD : [NSManagedObject] = []
    func loadSpotsFromCD(appDelegate: AppDelegate) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: Constants.SPOT_CD)
        
        do {
            spotsCD = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch spots from CoreData. \(error), \(error.userInfo)")
        }
        mergeSpots(appDelegate: appDelegate)
    }
    func storeSpotsToCD(appDelegate: AppDelegate) -> Void {
        print("Store Spots to CoreData")
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity         = NSEntityDescription.entity(forEntityName: Constants.SPOT_CD, in: managedContext)!
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: Constants.SPOT_CD)
        
        for spot in spots {
            if spot.country.isEmpty {
                Helper.getCountryForSpot(spot: spot)
            }
            
            let predicateName       = NSPredicate(format: "%K == %@", Constants.NAME_CD,        spot.name)
            let predicateDesc       = NSPredicate(format: "%K == %@", Constants.DESCRIPTION_CD, spot.description)
            let predicateCountry    = NSPredicate(format: "%K == %@", Constants.COUNTRY_CD,     spot.country)
            let compoundPredicate   = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateCountry])
            
            fetchRequest.predicate = compoundPredicate
            do {
                let fetchResult = try managedContext.fetch(fetchRequest).first
                if fetchResult != nil {
                    // Update
                    let spotCD = fetchResult!
                    spotCD.setValue(spot.description,                forKeyPath: Constants.DESCRIPTION_CD)
                    spotCD.setValue(spot.point.coordinate.latitude,  forKeyPath: Constants.LAT_CD)
                    spotCD.setValue(spot.point.coordinate.longitude, forKeyPath: Constants.LON_CD)
                    spotCD.setValue(spot.country,                    forKeyPath: Constants.COUNTRY_CD)
                    spotCD.setValue(spot.tags,                       forKeyPath: Constants.TAGS_CD)
                } else {
                    // Insert
                    let spotCD = NSManagedObject(entity: entity, insertInto: managedContext)
                    spotCD.setValue(spot.name,                       forKeyPath: Constants.NAME_CD)
                    spotCD.setValue(spot.description,                forKeyPath: Constants.DESCRIPTION_CD)
                    spotCD.setValue(spot.point.coordinate.latitude,  forKeyPath: Constants.LAT_CD)
                    spotCD.setValue(spot.point.coordinate.longitude, forKeyPath: Constants.LON_CD)
                    spotCD.setValue(spot.country,                    forKeyPath: Constants.COUNTRY_CD)
                    spotCD.setValue(spot.tags,                       forKeyPath: Constants.TAGS_CD)
                }
            } catch let error as NSError {
                print("Error fetching spot from CoreData. \(error), \(error.userInfo)")
            }
        }
                
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store spots to CoreData. \(error), \(error.userInfo)")
        }
    }
    func addSpotToCD(appDelegate: AppDelegate, spot: Spot) -> Void {
        let managedContext      = appDelegate.persistentContainer.viewContext
        let entity              = NSEntityDescription.entity(forEntityName:   Constants.SPOT_CD, in: managedContext)!
        let fetchRequest        = NSFetchRequest<NSManagedObject>(entityName: Constants.SPOT_CD)
        let predicateName       = NSPredicate(format: "%K == %@",             Constants.NAME_CD,        spot.name)
        let predicateDesc       = NSPredicate(format: "%K == %@",             Constants.DESCRIPTION_CD, spot.description)
        let predicateCountry    = NSPredicate(format: "%K == %@",             Constants.COUNTRY_CD,     spot.country)
        let compoundPredicate   = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateCountry])
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                return
            } else {
                let spotCD = NSManagedObject(entity: entity, insertInto: managedContext)
                spotCD.setValue(spot.name,                       forKeyPath: Constants.NAME_CD)
                spotCD.setValue(spot.description,                forKeyPath: Constants.DESCRIPTION_CD)
                spotCD.setValue(spot.point.coordinate.latitude,  forKeyPath: Constants.LAT_CD)
                spotCD.setValue(spot.point.coordinate.longitude, forKeyPath: Constants.LON_CD)
                spotCD.setValue(spot.country,                    forKeyPath: Constants.COUNTRY_CD)
                spotCD.setValue(spot.tags,                       forKeyPath: Constants.TAGS_CD)
            }
        } catch let error as NSError {
            print("Error fetching spot from CoreData. \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store spots to CoreData. \(error), \(error.userInfo)")
        }
    }
    func updateSpotInCD(appDelegate: AppDelegate, spot: Spot) -> Void {
        let managedContext       = appDelegate.persistentContainer.viewContext
        let fetchRequest         = NSFetchRequest<NSManagedObject>(entityName: Constants.SPOT_CD)
        let predicateName        = NSPredicate(format: "%K == %@", Constants.NAME_CD,         spot.name)
        let predicateDesc        = NSPredicate(format: "%K == %@", Constants.DESCRIPTION_CD,  spot.description)
        let compoundPredicate    = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc])
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                let spotCD = fetchResult!
                spotCD.setValue(spot.description,                forKeyPath: Constants.DESCRIPTION_CD)
                spotCD.setValue(spot.point.coordinate.latitude,  forKeyPath: Constants.LAT_CD)
                spotCD.setValue(spot.point.coordinate.longitude, forKeyPath: Constants.LON_CD)
                spotCD.setValue(spot.country,                    forKeyPath: Constants.COUNTRY_CD)
                spotCD.setValue(spot.tags,                       forKeyPath: Constants.TAGS_CD)
            } else {
                return
            }
        } catch let error as NSError {
            print("Error fetching spot from CoreData. \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not store spots to CoreData. \(error), \(error.userInfo)")
        }
    }
    func removeSpotFromCD(appDelegate: AppDelegate, spot: Spot) -> Void {
        let managedContext      = appDelegate.persistentContainer.viewContext
        let fetchRequest        = NSFetchRequest<NSManagedObject>(entityName: Constants.SPOT_CD)
        let predicateName       = NSPredicate(format: "%K == %@",   Constants.NAME_CD,        spot.name)
        let predicateDesc       = NSPredicate(format: "%K == %@",   Constants.DESCRIPTION_CD, spot.description)
        let predicateCountry    = NSPredicate(format: "%K == %@",   Constants.COUNTRY_CD,     spot.country)
        let compoundPredicate   = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateCountry])
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                managedContext.delete(fetchResult!)
                try managedContext.save()
            } else {
                return
            }
        } catch let error as NSError {
            print("Error fetching spot from CoreData. \(error), \(error.userInfo)")
        }
    }
    func isSpotInCD(appDelegate: AppDelegate, spot: Spot) -> Bool {
        let managedContext      = appDelegate.persistentContainer.viewContext
        let fetchRequest        = NSFetchRequest<NSManagedObject>(entityName: Constants.SPOT_CD)
        let predicateName       = NSPredicate(format: "%K == %@", Constants.NAME_CD,        spot.name)
        let predicateDesc       = NSPredicate(format: "%K == %@", Constants.DESCRIPTION_CD, spot.description)
        let predicateCountry    = NSPredicate(format: "%K == %@", Constants.COUNTRY_CD,     spot.country)
        let compoundPredicate   = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateCountry])
        
        fetchRequest.predicate = compoundPredicate
        do {
            if (try managedContext.fetch(fetchRequest).first) != nil {
                return true
            } else {
                return false
            }
        } catch {
            print("Error checking core data for spot.\(error)")
        }
        return false
    }
    func mergeSpots(appDelegate: AppDelegate) -> Void {
        var spotsInCoreData : [Spot] = []
        for spotCD in spotsCD {
            let spot = Spot(name        : spotCD.value(forKey: Constants.NAME_CD)        as! String,
                            description : spotCD.value(forKey: Constants.DESCRIPTION_CD) as! String,
                            lat         : spotCD.value(forKey: Constants.LAT_CD)         as! Double,
                            lon         : spotCD.value(forKey: Constants.LON_CD)         as! Double,
                            country     : spotCD.value(forKey: Constants.COUNTRY_CD)     as? String ?? "",
                            tags        : spotCD.value(forKey: Constants.TAGS_CD)        as! Int32)
            spotsInCoreData.append(spot)
        }
        
        for spot in spotsInCoreData {
            if !isSpotInSpots(spot: spot) {
                addSpot(spot)
            }
        }
        for spot in spots {
            if !isSpotInCD(appDelegate: appDelegate, spot: spot) {
                addSpotToCD(appDelegate: appDelegate, spot: spot)
            }
        }
    }
    
    
    // Views CoreData
    var viewsCD : [NSManagedObject] = []
    func loadViewsFromCD(appDelegate: AppDelegate) -> Void {
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: Constants.VIEW_CD)
        
        do {
            viewsCD = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch views from CoreData. \(error), \(error.userInfo)")
        }
        
        mergeViews(appDelegate: appDelegate)
    }
    func storeViewsToCD(appDelegate: AppDelegate) -> Void {
        print("Store Views to CoreData")
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity         = NSEntityDescription.entity(forEntityName: Constants.VIEW_CD, in: managedContext)!
        let fetchRequest   = NSFetchRequest<NSManagedObject>(entityName: Constants.VIEW_CD)
        
        for view in views {
            if view.country.isEmpty {
                Helper.getCountryForView(view: view)
            }
            
            let predicateName       = NSPredicate(format: "%K == %@", Constants.NAME_CD,        view.name)
            let predicateDesc       = NSPredicate(format: "%K == %@", Constants.DESCRIPTION_CD, view.description)
            let predicateCountry    = NSPredicate(format: "%K == %@", Constants.COUNTRY_CD,     view.country)
            let predicateCameraName = NSPredicate(format: "%K == %@", Constants.CAMERA_NAME_CD, view.camera.name)
            let predicateLensName   = NSPredicate(format: "%K == %@", Constants.LENS_NAME_CD,   view.lens.name)
            let compoundPredicate   = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateCountry, predicateCameraName, predicateLensName])
            
            fetchRequest.predicate = compoundPredicate
            do {
                let fetchResult = try managedContext.fetch(fetchRequest).first
                if fetchResult != nil {
                    // Update
                    let viewCD = fetchResult!
                    viewCD.setValue(view.description,                         forKeyPath: Constants.DESCRIPTION_CD)
                    viewCD.setValue(view.cameraPoint.coordinate.latitude,     forKeyPath: Constants.CAMERA_LAT_CD)
                    viewCD.setValue(view.cameraPoint.coordinate.longitude,    forKeyPath: Constants.CAMERA_LON_CD)
                    viewCD.setValue(view.motifPoint.coordinate.latitude,      forKeyPath: Constants.MOTIF_LAT_CD)
                    viewCD.setValue(view.motifPoint.coordinate.longitude,     forKeyPath: Constants.MOTIF_LON_CD)
                    viewCD.setValue(view.camera.name,                         forKeyPath: Constants.CAMERA_NAME_CD)
                    viewCD.setValue(view.camera.sensorFormat,                 forKeyPath: Constants.SENSOR_FORMAT_CD)
                    viewCD.setValue(view.lens.name,                           forKeyPath: Constants.LENS_NAME_CD)
                    viewCD.setValue(view.lens.minFocalLength,                 forKeyPath: Constants.MIN_FOCAL_LENGTH_CD)
                    viewCD.setValue(view.lens.maxFocalLength,                 forKeyPath: Constants.MAX_FOCAL_LENGTH_CD)
                    viewCD.setValue(view.lens.minAperture,                    forKeyPath: Constants.MIN_APERTURE_CD)
                    viewCD.setValue(view.lens.maxAperture,                    forKeyPath: Constants.MAX_APERTURE_CD)
                    viewCD.setValue(view.focalLength,                         forKeyPath: Constants.FOCAL_LENGTH_CD)
                    viewCD.setValue(view.aperture,                            forKeyPath: Constants.APERTURE_CD)
                    viewCD.setValue(view.orientation.rawValue,                forKeyPath: Constants.ORIENTATION_CD)
                    viewCD.setValue(view.country,                             forKeyPath: Constants.COUNTRY_CD)
                    viewCD.setValue(view.mapRect.origin.coordinate.latitude,  forKeyPath: Constants.ORIGIN_LAT_CD)
                    viewCD.setValue(view.mapRect.origin.coordinate.longitude, forKeyPath: Constants.ORIGIN_LON_CD)
                    viewCD.setValue(view.mapRect.size.width,                  forKeyPath: Constants.MAP_WIDTH_CD)
                    viewCD.setValue(view.mapRect.size.height,                 forKeyPath: Constants.MAP_HEIGHT_CD)
                    viewCD.setValue(view.tags,                                forKeyPath: Constants.TAGS_CD)
                    viewCD.setValue(view.equipment,                           forKeyPath: Constants.EQUIPMENT_CD)
                    viewCD.setValue(view.times,                               forKeyPath: Constants.TIMES_CD)
                } else {
                    // Insert
                    let viewCD = NSManagedObject(entity: entity, insertInto: managedContext)
                    viewCD.setValue(view.name,                                forKeyPath: Constants.NAME_CD)
                    viewCD.setValue(view.description,                         forKeyPath: Constants.DESCRIPTION_CD)
                    viewCD.setValue(view.cameraPoint.coordinate.latitude,     forKeyPath: Constants.CAMERA_LAT_CD)
                    viewCD.setValue(view.cameraPoint.coordinate.longitude,    forKeyPath: Constants.CAMERA_LON_CD)
                    viewCD.setValue(view.motifPoint.coordinate.latitude,      forKeyPath: Constants.MOTIF_LAT_CD)
                    viewCD.setValue(view.motifPoint.coordinate.longitude,     forKeyPath: Constants.MOTIF_LON_CD)
                    viewCD.setValue(view.camera.name,                         forKeyPath: Constants.CAMERA_NAME_CD)
                    viewCD.setValue(view.camera.sensorFormat,                 forKeyPath: Constants.SENSOR_FORMAT_CD)
                    viewCD.setValue(view.lens.name,                           forKeyPath: Constants.LENS_NAME_CD)
                    viewCD.setValue(view.lens.minFocalLength,                 forKeyPath: Constants.MIN_FOCAL_LENGTH_CD)
                    viewCD.setValue(view.lens.maxFocalLength,                 forKeyPath: Constants.MAX_FOCAL_LENGTH_CD)
                    viewCD.setValue(view.lens.minAperture,                    forKeyPath: Constants.MIN_APERTURE_CD)
                    viewCD.setValue(view.lens.maxAperture,                    forKeyPath: Constants.MAX_APERTURE_CD)
                    viewCD.setValue(view.focalLength,                         forKeyPath: Constants.FOCAL_LENGTH_CD)
                    viewCD.setValue(view.aperture,                            forKeyPath: Constants.APERTURE_CD)
                    viewCD.setValue(view.orientation.rawValue,                forKeyPath: Constants.ORIENTATION_CD)
                    viewCD.setValue(view.country,                             forKeyPath: Constants.COUNTRY_CD)
                    viewCD.setValue(view.mapRect.origin.coordinate.latitude,  forKeyPath: Constants.ORIGIN_LAT_CD)
                    viewCD.setValue(view.mapRect.origin.coordinate.longitude, forKeyPath: Constants.ORIGIN_LON_CD)
                    viewCD.setValue(view.mapRect.size.width,                  forKeyPath: Constants.MAP_WIDTH_CD)
                    viewCD.setValue(view.mapRect.size.height,                 forKeyPath: Constants.MAP_HEIGHT_CD)
                    viewCD.setValue(view.tags,                                forKeyPath: Constants.TAGS_CD)
                    viewCD.setValue(view.equipment,                           forKeyPath: Constants.EQUIPMENT_CD)
                    viewCD.setValue(view.times,                               forKeyPath: Constants.TIMES_CD)
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
        let managedContext      = appDelegate.persistentContainer.viewContext
        let entity              = NSEntityDescription.entity(forEntityName: Constants.VIEW_CD, in: managedContext)!
        let fetchRequest        = NSFetchRequest<NSManagedObject>(entityName: Constants.VIEW_CD)
        let predicateName       = NSPredicate(format: "%K == %@", Constants.NAME_CD,        view.name)
        let predicateDesc       = NSPredicate(format: "%K == %@", Constants.DESCRIPTION_CD, view.description)
        let predicateCountry    = NSPredicate(format: "%K == %@", Constants.COUNTRY_CD,     view.country)
        let predicateCameraName = NSPredicate(format: "%K == %@", Constants.CAMERA_NAME_CD, view.camera.name)
        let predicateLensName   = NSPredicate(format: "%K == %@", Constants.LENS_NAME_CD,   view.lens.name)
        let compoundPredicate   = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateCountry, predicateCameraName, predicateLensName])
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                return
            } else {
                let viewCD = NSManagedObject(entity: entity, insertInto: managedContext)
                viewCD.setValue(view.name,                                forKeyPath: Constants.NAME_CD)
                viewCD.setValue(view.description,                         forKeyPath: Constants.DESCRIPTION_CD)
                viewCD.setValue(view.cameraPoint.coordinate.latitude,     forKeyPath: Constants.CAMERA_LAT_CD)
                viewCD.setValue(view.cameraPoint.coordinate.longitude,    forKeyPath: Constants.CAMERA_LON_CD)
                viewCD.setValue(view.motifPoint.coordinate.latitude,      forKeyPath: Constants.MOTIF_LAT_CD)
                viewCD.setValue(view.motifPoint.coordinate.longitude,     forKeyPath: Constants.MOTIF_LON_CD)
                viewCD.setValue(view.camera.name,                         forKeyPath: Constants.CAMERA_NAME_CD)
                viewCD.setValue(view.camera.sensorFormat,                 forKeyPath: Constants.SENSOR_FORMAT_CD)
                viewCD.setValue(view.lens.name,                           forKeyPath: Constants.LENS_NAME_CD)
                viewCD.setValue(view.lens.minFocalLength,                 forKeyPath: Constants.MIN_FOCAL_LENGTH_CD)
                viewCD.setValue(view.lens.maxFocalLength,                 forKeyPath: Constants.MAX_FOCAL_LENGTH_CD)
                viewCD.setValue(view.lens.minAperture,                    forKeyPath: Constants.MIN_APERTURE_CD)
                viewCD.setValue(view.lens.maxAperture,                    forKeyPath: Constants.MAX_APERTURE_CD)
                viewCD.setValue(view.focalLength,                         forKeyPath: Constants.FOCAL_LENGTH_CD)
                viewCD.setValue(view.aperture,                            forKeyPath: Constants.APERTURE_CD)
                viewCD.setValue(view.orientation.rawValue,                forKeyPath: Constants.ORIENTATION_CD)
                viewCD.setValue(view.country,                             forKeyPath: Constants.COUNTRY_CD)
                viewCD.setValue(view.mapRect.origin.coordinate.latitude,  forKeyPath: Constants.ORIGIN_LAT_CD)
                viewCD.setValue(view.mapRect.origin.coordinate.longitude, forKeyPath: Constants.ORIGIN_LON_CD)
                viewCD.setValue(view.mapRect.size.width,                  forKeyPath: Constants.MAP_WIDTH_CD)
                viewCD.setValue(view.mapRect.size.height,                 forKeyPath: Constants.MAP_HEIGHT_CD)
                viewCD.setValue(view.tags,                                forKeyPath: Constants.TAGS_CD)
                viewCD.setValue(view.equipment,                           forKeyPath: Constants.EQUIPMENT_CD)
                viewCD.setValue(view.times,                               forKeyPath: Constants.TIMES_CD)
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
        let managedContext       = appDelegate.persistentContainer.viewContext
        let fetchRequest         = NSFetchRequest<NSManagedObject>(entityName: Constants.VIEW_CD)
        let predicateName        = NSPredicate(format: "%K == %@", Constants.NAME_CD,         view.name)
        let predicateDesc        = NSPredicate(format: "%K == %@", Constants.DESCRIPTION_CD,  view.description)
        let predicateFocalLength = NSPredicate(format: "%K == %@", Constants.FOCAL_LENGTH_CD, view.description)
        let predicateAperture    = NSPredicate(format: "%K == %@", Constants.APERTURE_CD,     view.aperture)
        let compoundPredicate    = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateFocalLength, predicateAperture])
        
        fetchRequest.predicate = compoundPredicate
        do {
            let fetchResult = try managedContext.fetch(fetchRequest).first
            if fetchResult != nil {
                let viewCD = fetchResult!
                viewCD.setValue(view.description,                         forKeyPath: Constants.DESCRIPTION_CD)
                viewCD.setValue(view.cameraPoint.coordinate.latitude,     forKeyPath: Constants.CAMERA_LAT_CD)
                viewCD.setValue(view.cameraPoint.coordinate.longitude,    forKeyPath: Constants.CAMERA_LON_CD)
                viewCD.setValue(view.motifPoint.coordinate.latitude,      forKeyPath: Constants.MOTIF_LAT_CD)
                viewCD.setValue(view.motifPoint.coordinate.longitude,     forKeyPath: Constants.MOTIF_LON_CD)
                viewCD.setValue(view.camera.name,                         forKeyPath: Constants.CAMERA_NAME_CD)
                viewCD.setValue(view.camera.sensorFormat,                 forKeyPath: Constants.SENSOR_FORMAT_CD)
                viewCD.setValue(view.lens.name,                           forKeyPath: Constants.LENS_NAME_CD)
                viewCD.setValue(view.lens.minFocalLength,                 forKeyPath: Constants.MIN_FOCAL_LENGTH_CD)
                viewCD.setValue(view.lens.maxFocalLength,                 forKeyPath: Constants.MAX_FOCAL_LENGTH_CD)
                viewCD.setValue(view.lens.minAperture,                    forKeyPath: Constants.MIN_APERTURE_CD)
                viewCD.setValue(view.lens.maxAperture,                    forKeyPath: Constants.MAX_APERTURE_CD)
                viewCD.setValue(view.focalLength,                         forKeyPath: Constants.FOCAL_LENGTH_CD)
                viewCD.setValue(view.aperture,                            forKeyPath: Constants.APERTURE_CD)
                viewCD.setValue(view.orientation.rawValue,                forKeyPath: Constants.ORIENTATION_CD)
                viewCD.setValue(view.country,                             forKeyPath: Constants.COUNTRY_CD)
                viewCD.setValue(view.mapRect.origin.coordinate.latitude,  forKeyPath: Constants.ORIGIN_LAT_CD)
                viewCD.setValue(view.mapRect.origin.coordinate.longitude, forKeyPath: Constants.ORIGIN_LON_CD)
                viewCD.setValue(view.mapRect.size.width,                  forKeyPath: Constants.MAP_WIDTH_CD)
                viewCD.setValue(view.mapRect.size.height,                 forKeyPath: Constants.MAP_HEIGHT_CD)
                viewCD.setValue(view.tags,                                forKeyPath: Constants.TAGS_CD)
                viewCD.setValue(view.equipment,                           forKeyPath: Constants.EQUIPMENT_CD)
                viewCD.setValue(view.times,                               forKeyPath: Constants.TIMES_CD)
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
        
        let managedContext      = appDelegate.persistentContainer.viewContext
        let fetchRequest        = NSFetchRequest<NSManagedObject>(entityName: Constants.VIEW_CD)
        let predicateName       = NSPredicate(format: "%K == %@",   Constants.NAME_CD,        view.name)
        let predicateDesc       = NSPredicate(format: "%K == %@",   Constants.DESCRIPTION_CD, view.description)
        let predicateCountry    = NSPredicate(format: "%K == %@",   Constants.COUNTRY_CD,     view.country)
        let predicateCameraName = NSPredicate(format: "%K == %@", Constants.CAMERA_NAME_CD,   view.camera.name)
        let predicateLensName   = NSPredicate(format: "%K == %@",   Constants.LENS_NAME_CD,   view.lens.name)
        let compoundPredicate   = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateCountry, predicateCameraName, predicateLensName])
        
        fetchRequest.predicate = compoundPredicate
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
    func isViewInCD(appDelegate: AppDelegate, view: View) -> Bool {
        let managedContext      = appDelegate.persistentContainer.viewContext
        let fetchRequest        = NSFetchRequest<NSManagedObject>(entityName: Constants.VIEW_CD)
        let predicateName       = NSPredicate(format: "%K == %@", Constants.NAME_CD,        view.name)
        let predicateDesc       = NSPredicate(format: "%K == %@", Constants.DESCRIPTION_CD, view.description)
        let predicateCountry    = NSPredicate(format: "%K == %@", Constants.COUNTRY_CD,     view.country)
        let predicateCameraName = NSPredicate(format: "%K == %@", Constants.CAMERA_NAME_CD, view.camera.name)
        let predicateLensName   = NSPredicate(format: "%K == %@", Constants.LENS_NAME_CD,   view.lens.name)
        let compoundPredicate   = NSCompoundPredicate(type: .and, subpredicates: [predicateName, predicateDesc, predicateCountry, predicateCameraName, predicateLensName])
        
        fetchRequest.predicate = compoundPredicate
        do {
            if (try managedContext.fetch(fetchRequest).first) != nil {
                return true
            } else {
                return false
            }
        } catch {
            print("Error checking core data for view.\(error)")
        }
        return false
    }
    func mergeViews(appDelegate: AppDelegate) -> Void {
        var viewsInCoreData : [View] = []
        for viewCD in viewsCD {
            let view = View(name          : viewCD.value(forKey: Constants.NAME_CD)             as! String,
                            description   : viewCD.value(forKey: Constants.DESCRIPTION_CD)      as! String,
                            cameraLat     : viewCD.value(forKey: Constants.CAMERA_LAT_CD)       as! Double,
                            cameraLon     : viewCD.value(forKey: Constants.CAMERA_LON_CD)       as! Double,
                            motifLat      : viewCD.value(forKey: Constants.MOTIF_LAT_CD)        as! Double,
                            motifLon      : viewCD.value(forKey: Constants.MOTIF_LON_CD)        as! Double,
                            cameraName    : viewCD.value(forKey: Constants.CAMERA_NAME_CD)      as! String,
                            sensorFormat  : viewCD.value(forKey: Constants.SENSOR_FORMAT_CD)    as! Int64,
                            lensName      : viewCD.value(forKey: Constants.LENS_NAME_CD)        as! String,
                            minFocalLength: viewCD.value(forKey: Constants.MIN_FOCAL_LENGTH_CD) as! Double,
                            maxFocalLength: viewCD.value(forKey: Constants.MAX_FOCAL_LENGTH_CD) as! Double,
                            minAperture   : viewCD.value(forKey: Constants.MIN_APERTURE_CD)     as! Double,
                            maxAperture   : viewCD.value(forKey: Constants.MAX_APERTURE_CD)     as! Double,
                            focalLength   : viewCD.value(forKey: Constants.FOCAL_LENGTH_CD)     as! Double,
                            aperture      : viewCD.value(forKey: Constants.APERTURE_CD)         as! Double,
                            orientation   : viewCD.value(forKey: Constants.ORIENTATION_CD)      as! String,
                            country       : viewCD.value(forKey: Constants.COUNTRY_CD)          as? String ?? "",
                            originLat     : viewCD.value(forKey: Constants.ORIGIN_LAT_CD)       as! Double,
                            originLon     : viewCD.value(forKey: Constants.ORIGIN_LON_CD)       as! Double,
                            mapWidth      : viewCD.value(forKey: Constants.MAP_WIDTH_CD)        as! Double,
                            mapHeight     : viewCD.value(forKey: Constants.MAP_HEIGHT_CD)       as! Double,
                            tags          : viewCD.value(forKey: Constants.TAGS_CD)             as! Int32,
                            equipment     : viewCD.value(forKey: Constants.EQUIPMENT_CD)        as! Int32,
                            times         : viewCD.value(forKey: Constants.TIMES_CD)            as! Int32)
            viewsInCoreData.append(view)
        }
        for view in viewsInCoreData {
            if !isViewInViews(view: view) {
                addView(view)
            }
        }
        for view in views {
            if !isViewInCD(appDelegate: appDelegate, view: view) {
                addViewToCD(appDelegate: appDelegate, view: view)
            }
        }
        
        // Make sure cameras and lenses used in views are also stored in cameras and lenses
        for view in views {
            // check lens against lenses
            let lens = view.lens
            if !isLensInLenses(lens: lens) {
                addLens(lens)
            }
            if !isLensInCD(appDelegate: appDelegate, lens: lens) {
                addLensToCD(appDelegate: appDelegate, lens: lens)
            }
            
            // check camera against cameras
            let camera      = view.camera
            if !isCameraInCameras(camera: camera) {
                addCamera(camera)
            }
            if !isCameraInCD(appDelegate: appDelegate, camera: camera) {
                addCameraToCD(appDelegate: appDelegate, camera: camera)
            }
        }
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
    
    
    // Store to CoreData
    func storeToCoreData(appDelegate: AppDelegate) {
        storeLensesToCD(appDelegate: appDelegate)
        storeCamerasToCD(appDelegate: appDelegate)
        storeSpotsToCD(appDelegate: appDelegate)
        storeViewsToCD(appDelegate: appDelegate)
    }
    
    // Retrieve from CoreDate
    func retrieveFromCoreData(appDelegate: AppDelegate) {
        loadLensesFromCD(appDelegate: appDelegate)
        loadCamerasFromCD(appDelegate: appDelegate)
        loadSpotsFromCD(appDelegate: appDelegate)
        loadViewsFromCD(appDelegate: appDelegate)
    }
    
    
    // Store to UserDefaults
    func storeLocationToUserDefaults() {
        let defaults = UserDefaults.standard
        do {
            let encodedLocation = try NSKeyedArchiver.archivedData(withRootObject: self.lastLocation, requiringSecureCoding: false)
            defaults.set(encodedLocation, forKey: "lastLocation")
        } catch {
            print("Error saving last location. \(error)")
        }
    }

    func storeCameraAndLensToUserDefaults() {
        let defaults = UserDefaults.standard
        do {
            let cameraData = try NSKeyedArchiver.archivedData(withRootObject: self.view.camera, requiringSecureCoding: false)
            defaults.set(cameraData, forKey: "camera")
            
            let lensData = try NSKeyedArchiver.archivedData(withRootObject: self.view.lens, requiringSecureCoding: false)
            defaults.set(lensData, forKey: "lens")
        } catch {
            print("Error storing camera and lens to user defaults. \(error)")
        }
    }
    
    func storeToUserDefaults() {
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
    func retrieveLocationFromUserDefaults() {
        let defaults = UserDefaults.standard
        if let previousLocationEncoded = defaults.object(forKey: "lastLocation") as? Data {
            do {
                if let location = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(previousLocationEncoded) as? CLLocation {
                    setLastLocation(location)
                }
            } catch {
                print("Error retrieving last location from UserDefaults. \(error)")
            }
        }
    }
    
    func retrieveCameraAndLensFromUserDefaults() {
        let defaults = UserDefaults.standard
        if let cameraData = defaults.data(forKey: "camera") {
            do {
                if let camera = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(cameraData) as? Camera {
                    print("Camera loaded from user defaults: \(camera.name)")
                    view.camera = camera
                }
            } catch {
                print("Error loading camera from UserDefaults. \(error)")
            }
        }
        if let lensData = defaults.data(forKey: "lens") {
            do {
                if let lens = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(lensData) as? Lens {
                    print("Lens loaded from user defaults: \(lens.name)")
                    view.lens = lens
                }
            } catch {
                print("Error loading camera from UserDefaults. \(error)")
            }
        }
    }
    
    func retrieveFromUserDefaults() {
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
