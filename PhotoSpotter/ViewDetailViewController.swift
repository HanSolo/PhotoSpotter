//
//  ViewDetailViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 05.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public class ViewDetailViewController: UIViewController, FoVController {
    var stateController: StateController?
    
    
    @IBOutlet weak var nameTextField        : UITextField!
    @IBOutlet weak var descriptionTextField : UITextField!
    @IBOutlet weak var cameraTextField      : UITextField!
    @IBOutlet weak var lensTextField        : UITextField!
    
    @IBOutlet weak var cancelButton         : UIButton!
    @IBOutlet weak var doneButton           : UIButton!
    
    @IBOutlet weak var navBar               : UINavigationBar!
    // Equipment
    @IBOutlet weak var tripodSwitch         : UISwitch!
    @IBOutlet weak var gimbalSwitch         : UISwitch!
    @IBOutlet weak var cplFilterSwitch      : UISwitch!
    @IBOutlet weak var ndFilterSwitch       : UISwitch!
    @IBOutlet weak var irFilterSwitch       : UISwitch!
    @IBOutlet weak var flashSwitch          : UISwitch!
    // Tags
    @IBOutlet weak var nightSwitch          : UISwitch!
    @IBOutlet weak var astroSwitch          : UISwitch!
    @IBOutlet weak var macroSwitch          : UISwitch!
    @IBOutlet weak var poiSwitch            : UISwitch!
    @IBOutlet weak var infraredSwitch       : UISwitch!
    @IBOutlet weak var longExposureSwitch   : UISwitch!
    @IBOutlet weak var cityscapeSwitch      : UISwitch!
    @IBOutlet weak var landscapeSwitch      : UISwitch!
    @IBOutlet weak var streetSwitch         : UISwitch!
    @IBOutlet weak var bridgeSwitch         : UISwitch!
    @IBOutlet weak var lakeSwitch           : UISwitch!
    @IBOutlet weak var shipSwitch           : UISwitch!
    @IBOutlet weak var carSwitch            : UISwitch!
    @IBOutlet weak var flowerSwitch         : UISwitch!
    @IBOutlet weak var treeSwitch           : UISwitch!
    @IBOutlet weak var buildingSwitch       : UISwitch!
    @IBOutlet weak var beachSwitch          : UISwitch!
    @IBOutlet weak var sunriseSwitch        : UISwitch!
    @IBOutlet weak var sunsetSwitch         : UISwitch!
    @IBOutlet weak var moonSwitch           : UISwitch!
    
    
    
    var nameIconView         : UIView?
    var tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var name                 : String      = ""
    var descr                : String      = ""
    var equipment            : Int32       = 0
    var tags                 : Int32       = 0
    
    var nameValid            : Bool        = false
    var descriptionValid     : Bool        = false
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.setNavBarTitle(navBar: navBar)
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        self.nameTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        self.descriptionTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        self.cameraTextField.text  = stateController!.view.camera.name
        self.lensTextField.text    = stateController!.view.lens.name
        
        self.tapGestureRecognizer.numberOfTapsRequired = 1
        
        self.nameIconView = Helper.setupTextFieldWithAlertIcon(field: nameTextField, gestureRecognizer: tapGestureRecognizer)
    }
    
    
    @objc private func textFieldChanged(_ textField: UITextField) -> Void {
        if textField === nameTextField {
            self.name      = textField.text!
            self.nameValid = !textField.text!.isEmpty
        } else if textField === descriptionTextField {
            self.descr = textField.text!
        }
        validateForm()
    }
    
    //MARK: Equipment switch handlers
    @IBAction func tripodSwitchChanged(_ sender: Any) {
        setEquipment()
    }
    @IBAction func gimbalSwitchChanged(_ sender: Any) {
        setEquipment()
    }
    @IBAction func cplFilterSwitchChanged(_ sender: Any) {
        setEquipment()
    }
    @IBAction func ndFilterSwitchChanged(_ sender: Any) {
        setEquipment()
    }
    @IBAction func irFilterSwitchChanged(_ sender: Any) {
        setEquipment()
    }
    @IBAction func flashSwitchChanged(_ sender: Any) {
        setEquipment()
    }
    // Mark: Tags switch handlers
    @IBAction func nightSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func astroSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func macroSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func poiSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func infraredSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func longExposureSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func cityscapeSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func landscapeSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func streetSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func bridgeSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func lakeSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func shipSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func carSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func flowerSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func treeSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func buildingSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func beachSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func sunriseSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func sunsetSwitchChanged(_ sender: Any) {
        setTags()
    }
    @IBAction func moonSwitchChanged(_ sender: Any) {
        setTags()
    }
    
    
    
    
    private func validateForm() -> Void {
        self.doneButton.isEnabled = self.nameValid
        self.doneButton.alpha     = self.doneButton.isEnabled ? 1.0 : 0.5
        
        nameIconView!.isHidden = nameValid
    }
    
    private func setEquipment() -> Void {
        self.equipment = 0
        if self.tripodSwitch.isOn {
            self.equipment = self.equipment | Constants.EQP_TRIPOD.1
        }
        if self.gimbalSwitch.isOn {
            self.equipment = self.equipment | Constants.EQP_GIMBAL.1
        }
        if self.cplFilterSwitch.isOn {
            self.equipment = self.equipment | Constants.EQP_CPL_FILTER.1
        }
        if self.ndFilterSwitch.isOn {
            self.equipment = self.equipment | Constants.EQP_ND_FILTER.1
        }
        if self.irFilterSwitch.isOn {
            self.equipment = self.equipment | Constants.EQP_IR_FILTER.1
        }
        if self.flashSwitch.isOn {
            self.equipment = self.equipment | Constants.EQP_FLASH.1
        }
    }
    
    private func setTags() -> Void {
        self.tags = 0
        if self.nightSwitch.isOn {
            self.tags = self.tags | Constants.TAG_NIGHT.1
        }
        if self.astroSwitch.isOn {
            self.tags = self.tags | Constants.TAG_ASTRO.1
        }
        if self.macroSwitch.isOn {
            self.tags = self.tags | Constants.TAG_MACRO.1
        }
        if self.poiSwitch.isOn {
            self.tags = self.tags | Constants.TAG_POI.1
        }
        if self.infraredSwitch.isOn {
            self.tags = self.tags | Constants.TAG_INFRARED.1
        }
        if self.longExposureSwitch.isOn {
            self.tags = self.tags | Constants.TAG_LONG_EXPOSURE.1
        }
        if self.cityscapeSwitch.isOn {
            self.tags = self.tags | Constants.TAG_CITYSCAPE.1
        }
        if self.landscapeSwitch.isOn {
            self.tags = self.tags | Constants.TAG_LANDSCAPE.1
        }
        if self.streetSwitch.isOn {
            self.tags = self.tags | Constants.TAG_STREET.1
        }
        if self.bridgeSwitch.isOn {
            self.tags = self.tags | Constants.TAG_BRIDGE.1
        }
        if self.lakeSwitch.isOn {
            self.tags = self.tags | Constants.TAG_LAKE.1
        }
        if self.shipSwitch.isOn {
            self.tags = self.tags | Constants.TAG_SHIP.1
        }        
        if self.carSwitch.isOn {
            self.tags = self.tags | Constants.TAG_CAR.1
        }
        if self.flowerSwitch.isOn {
            self.tags = self.tags | Constants.TAG_FLOWER.1
        }
        if self.treeSwitch.isOn {
            self.tags = self.tags | Constants.TAG_TREE.1
        }
        if self.buildingSwitch.isOn {
            self.tags = self.tags | Constants.TAG_BUILDING.1
        }
        if self.beachSwitch.isOn {
            self.tags = self.tags | Constants.TAG_BEACH.1
        }
        if self.sunriseSwitch.isOn {
            self.tags = self.tags | Constants.TAG_SUNRISE.1
        }
        if self.sunsetSwitch.isOn {
            self.tags = self.tags | Constants.TAG_SUNSET.1
        }
        if self.moonSwitch.isOn {
            self.tags = self.tags | Constants.TAG_MOON.1
        }
    }
    
    @objc private func showAlert(sender: UIGestureRecognizer) -> Void {
        var title  : String = "Error"
        var message: String = ""
        if sender === tapGestureRecognizer {
            title   = "Name"
            message = "Please type in a name"
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSegue" {
            self.name  = nameTextField.text!
            self.descr = descriptionTextField.text!
            setEquipment()
            setTags()
        }
    }
}
