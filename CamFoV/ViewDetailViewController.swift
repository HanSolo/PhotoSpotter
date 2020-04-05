//
//  ViewDetailViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 05.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public class ViewDetailViewController: UIViewController, UITextFieldDelegate, FoVController {
    var stateController: StateController?
    
    
    @IBOutlet weak var nameTextField        : UITextField!
    @IBOutlet weak var descriptionTextField : UITextField!
    @IBOutlet weak var cameraTextField      : UITextField!
    @IBOutlet weak var lensTextField        : UITextField!
    
    @IBOutlet weak var cancelButton         : UIButton!
    @IBOutlet weak var doneButton           : UIButton!
    
    var name             : String = ""
    var descr            : String = ""
    
    var nameValid        : Bool   = false
    var descriptionValid : Bool   = false
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        nameTextField.delegate        = self
        descriptionTextField.delegate = self
        
        nameTextField.addTarget(self, action: #selector(updateName), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(updateDescription), for: .editingChanged)
        
        cameraTextField.text = stateController!.view.camera.name
        lensTextField.text   = stateController!.view.lens.name
    }
    
    
    @objc private func updateName() -> Void {
        self.name      = nameTextField!.text!
        self.nameValid = !nameTextField!.text!.isEmpty
    }
    @objc private func updateDescription() -> Void {
        self.descr            = descriptionTextField!.text!
        self.descriptionValid = !descriptionTextField!.text!.isEmpty
    }
    
    
    
    private func validateForm() -> Void {
        self.doneButton.isEnabled = self.nameValid
        self.doneButton.alpha     = self.doneButton.isEnabled ? 1.0 : 0.5
        if self.doneButton.isEnabled {
            self.nameTextField.layer.borderColor = Constants.VALID_CLEAR
            self.nameTextField.layer.borderWidth  = 0
        } else {
            self.nameTextField.layer.borderColor  = Constants.INVALID_RED
            self.nameTextField.layer.borderWidth  = 1
        }
    }
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSegue" {
            self.name  = nameTextField.text!
            self.descr = descriptionTextField.text!
        }
    }
    
    //MARK - UITextField Delegates
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        validateForm()
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === self.nameTextField {
            self.nameValid = !textField.text!.isEmpty
        } else if textField === self.descriptionTextField {
            self.descriptionValid = !textField.text!.isEmpty
        }
        validateForm()
    }
}
