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
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    
    var nameIconView         : UIView?
    var tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var name                 : String      = ""
    var descr                : String      = ""
    
    var nameValid            : Bool        = false
    var descriptionValid     : Bool        = false
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.setNavBarTitle(navBar: navBar)
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        nameTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        cameraTextField.text  = stateController!.view.camera.name
        lensTextField.text    = stateController!.view.lens.name
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        nameIconView = Helper.setupTextFieldWithAlertIcon(field: nameTextField, gestureRecognizer: tapGestureRecognizer)
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
    
    
    private func validateForm() -> Void {
        self.doneButton.isEnabled = self.nameValid
        self.doneButton.alpha     = self.doneButton.isEnabled ? 1.0 : 0.5
        
        nameIconView!.isHidden = nameValid
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
        }
    }
}
