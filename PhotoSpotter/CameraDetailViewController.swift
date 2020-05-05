//
//  CameraDetailViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 03.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public class CameraDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, FoVController {
    var stateController    : StateController?
    var sentViaSegueObject : FoVController?
    
    
    @IBOutlet weak var nameTextField      : UITextField!
    @IBOutlet weak var sensorFormatPicker : UIPickerView!
    @IBOutlet weak var cancelButton       : UIButton!
    @IBOutlet weak var doneButton         : UIButton!
    
    @IBOutlet weak var navBar             : UINavigationBar!
    
    var nameIconView         : UIView?
    var tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var name                 : String                 = ""
    var sensorFormat         : Int64                  = SensorFormat.FULL_FORMAT.id
    
    var nameValid            : Bool                   = false
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.setNavBarTitle(navBar: navBar)
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        self.sensorFormatPicker.dataSource = self
        self.sensorFormatPicker.delegate   = self
                
        nameTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        nameIconView = Helper.setupTextFieldWithAlertIcon(field: nameTextField, gestureRecognizer: tapGestureRecognizer)
        
        validateForm()
    }
    
    
    @objc private func updateName() -> Void {
        self.name = nameTextField!.text!
        self.nameValid  = !nameTextField!.text!.isEmpty
    }
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSegue" {
            name   = nameTextField.text!
            //sensorFormat = Constants.SENSOR_FORMATS[sensorFormatPicker.selectedRow(inComponent: 0)]
            print("doneSegue prepared with data: \(String(describing: nameTextField!.text))")
        }
    }
    
    
    @objc private func textFieldChanged(_ textField: UITextField) -> Void {
        if (textField === nameTextField) {
            self.name      = textField.text!
            self.nameValid = !textField.text!.isEmpty && stateController!.cameras.firstIndex(where: { $0.name == textField.text! }) == nil
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
    
    
    // UIPickerViewDataSource and UIPickerViewDelegate methods
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SensorFormat.allCases.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil){
            pickerLabel                  = UILabel()
            pickerLabel?.font            = UIFont(name: "System", size: 17)            
            pickerLabel?.textAlignment   = NSTextAlignment.center
        }
        
        if pickerView === sensorFormatPicker {
            pickerLabel?.text = SensorFormat.allCases[row].description
        }
        return pickerLabel!
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === sensorFormatPicker {
            self.sensorFormat = SensorFormat.allCases[row].id
        }
    }
}
