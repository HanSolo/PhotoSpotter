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
    @IBOutlet weak var tripodSwitch         : UISwitch!
    @IBOutlet weak var gimbalSwitch         : UISwitch!
    @IBOutlet weak var cplFilterSwitch      : UISwitch!
    @IBOutlet weak var ndFilterSwitch       : UISwitch!
    @IBOutlet weak var irFilterSwitch       : UISwitch!
    @IBOutlet weak var flashSwitch          : UISwitch!

    var nameIconView         : UIView?
    var tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var name                 : String      = ""
    var descr                : String      = ""
    var equipment            : Int         = 0
    
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
        
        
        var text : String = " ["
        text += Helper.equipmentInBitMask(equipment: Constants.EQP_TRIPOD,     bitmask: equipment) ?         Constants.EQP_TRIPOD.0 : ""
        text += Helper.equipmentInBitMask(equipment: Constants.EQP_GIMBAL,     bitmask: equipment) ? (", " + Constants.EQP_GIMBAL.0) : ""
        text += Helper.equipmentInBitMask(equipment: Constants.EQP_CPL_FILTER, bitmask: equipment) ? (", " + Constants.EQP_CPL_FILTER.0) : ""
        text += Helper.equipmentInBitMask(equipment: Constants.EQP_ND_FILTER,  bitmask: equipment) ? (", " + Constants.EQP_ND_FILTER.0) : ""
        text += Helper.equipmentInBitMask(equipment: Constants.EQP_IR_FILTER,  bitmask: equipment) ? (", " + Constants.EQP_IR_FILTER.0) : ""
        text += Helper.equipmentInBitMask(equipment: Constants.EQP_FLASH,      bitmask: equipment) ? (", " + Constants.EQP_FLASH.0) : ""
        text += "]"
        print("\(self.equipment) => \(text)")
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
        }
    }
}
