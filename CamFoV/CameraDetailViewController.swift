//
//  CameraDetailViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 03.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public class CameraDetailViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, FoVController {
    var stateController: StateController?
    
    
    @IBOutlet weak var nameTextField      : UITextField!
    @IBOutlet weak var sensorFormatPicker : UIPickerView!
    @IBOutlet weak var cancelButton       : UIButton!
    @IBOutlet weak var doneButton         : UIButton!
    
    var nameIconView         : UIImageView            = UIImageView(image: Constants.INFO_ICON)
    var tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var cameraName           : String                 = ""
    var sensorFormat         : SensorFormat           = SensorFormat.FULL_FORMAT
    
    var nameValid            : Bool                   = false
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        self.sensorFormatPicker.dataSource = self
        self.sensorFormatPicker.delegate   = self
        
        nameTextField.addTarget(self, action: #selector(updateName), for: .editingChanged)
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        Helper.setupTextFieldWithIcon(field: nameTextField, imageView: nameIconView, gestureRecognizer: tapGestureRecognizer)
    }
    
    
    @objc private func updateName() -> Void {
        self.cameraName = nameTextField!.text!
        self.nameValid  = !nameTextField!.text!.isEmpty
    }
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneSegue" {
            cameraName   = nameTextField.text!
            //sensorFormat = Constants.SENSOR_FORMATS[sensorFormatPicker.selectedRow(inComponent: 0)]
            print("doneSegue prepared with data: \(String(describing: nameTextField!.text))")
        }
    }
    
    
    private func validateForm() -> Void {
        self.doneButton.isEnabled = self.nameValid
        self.doneButton.alpha     = self.doneButton.isEnabled ? 1.0 : 0.5
        
        nameIconView.isHidden = nameValid
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
        return Constants.SENSOR_FORMATS.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil){
            pickerLabel                  = UILabel()
            pickerLabel?.font            = UIFont(name: "System", size: 17)
            //pickerLabel?.textColor       = UIColor.systemTeal
            //pickerLabel?.backgroundColor = UIColor.clear
            pickerLabel?.textAlignment   = NSTextAlignment.center
        }
        
        if pickerView === sensorFormatPicker {
            pickerLabel?.text = Constants.SENSOR_FORMATS[row].description
        }
        return pickerLabel!
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView === sensorFormatPicker {
            self.sensorFormat = Constants.SENSOR_FORMATS[row]
        }
    }
    
    //MARK - UITextField Delegates
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        validateForm()
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === self.nameTextField {
            self.nameValid = !textField.text!.isEmpty
        }
        validateForm()
    }
}
