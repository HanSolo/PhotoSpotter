//
//  SceneDelegate.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 27.03.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window          : UIWindow?
    let stateController : StateController = StateController()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        
        let rootViewController = self.window?.rootViewController
        if var mapViewController = rootViewController as? FoVController {
            mapViewController.stateController = self.stateController
        }        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stateController = stateController
        
        // Retrieve data from UserDefaults and CoreData
        self.stateController.retrieveLocationFromUserDefaults()
        self.stateController.retrieveCameraAndLensFromUserDefaults()
        if Helper.isICloudAvailable() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.stateController = stateController
                self.stateController.retrieveFromCoreData(appDelegate: appDelegate)
            } else {
                self.stateController.retrieveCamerasAndLensesFromUserDefaults()
            }
        } else {            
            self.stateController.retrieveCamerasAndLensesFromUserDefaults()
            self.stateController.retrieveCamerasAndLensesFromUserDefaults()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        self.stateController.storeLocationToUserDefaults()
        self.stateController.storeCameraAndLensToUserDefaults()
        if Helper.isICloudAvailable() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.saveContext()
                self.stateController.storeToCoreData(appDelegate: appDelegate)
            } else {
                self.stateController.storeCamerasAndLensesToUserDefaults()
            }
        } else {
            self.stateController.storeCamerasAndLensesToUserDefaults()
            self.stateController.storeViewsAndSpotsToUserDefaults()
        }
    }
}

