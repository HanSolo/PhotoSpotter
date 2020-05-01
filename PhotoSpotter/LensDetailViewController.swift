//
//  LensDetailViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 04.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public class LensDetailViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, FoVController {
    var stateController: StateController?
    
    
    @IBOutlet weak var nameTextField           : UITextField!
    @IBOutlet weak var isPrimeLensSwitch       : UISwitch!
    @IBOutlet weak var minFocalLengthTextField : UITextField!
    @IBOutlet weak var maxFocalLengthTextField : UITextField!
    @IBOutlet weak var minApertureTextField    : UITextField!
    @IBOutlet weak var maxApertureTextField    : UITextField!
    @IBOutlet weak var sensorFormatPicker      : UIPickerView!
    
    @IBOutlet weak var cancelButton            : UIButton!
    @IBOutlet weak var doneButton              : UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var nameIconView           : UIView?
    var minFocalLengthIconView : UIView?
    var maxFocalLengthIconView : UIView?
    var minApertureIconView    : UIView?
    var maxApertureIconView    : UIView?
    var tapGestureRecognizer   : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var lensName               : String = ""
    var minFocalLength         : Double = Constants.DEFAULT_LENS.minFocalLength
    var maxFocalLength         : Double = Constants.DEFAULT_LENS.maxFocalLength
    var minAperture            : Double = Constants.DEFAULT_LENS.minAperture
    var maxAperture            : Double = Constants.DEFAULT_LENS.maxAperture
    var sensorFormat           : Int64  = Constants.DEFAULT_LENS.sensorFormat
    
    var nameValid              : Bool   = false
    var minFocalLengthValid    : Bool   = false
    var maxFocalLengthValid    : Bool   = false
    var minApertureValid       : Bool   = false
    var maxApertureValid       : Bool   = false
    var sensorFormatValid      : Bool   = false
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.setNavBarTitle(navBar: navBar)
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        nameTextField.delegate           = self
        minFocalLengthTextField.delegate = self
        maxFocalLengthTextField.delegate = self
        minApertureTextField.delegate    = self
        maxApertureTextField.delegate    = self
        
        self.sensorFormatPicker.dataSource = self
        self.sensorFormatPicker.delegate   = self
        
        nameTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        minFocalLengthTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        maxFocalLengthTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        minApertureTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        maxApertureTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        nameIconView           = Helper.setupTextFieldWithAlertIcon(field: nameTextField,           gestureRecognizer: tapGestureRecognizer)
        minFocalLengthIconView = Helper.setupTextFieldWithAlertIcon(field: minFocalLengthTextField, gestureRecognizer: tapGestureRecognizer)
        maxFocalLengthIconView = Helper.setupTextFieldWithAlertIcon(field: maxFocalLengthTextField, gestureRecognizer: tapGestureRecognizer)
        minApertureIconView    = Helper.setupTextFieldWithAlertIcon(field: minApertureTextField,    gestureRecognizer: tapGestureRecognizer)
        maxApertureIconView    = Helper.setupTextFieldWithAlertIcon(field: maxApertureTextField,    gestureRecognizer: tapGestureRecognizer)
        
        validateForm()
    }
    
    @objc private func textFieldChanged(_ textField: UITextField) -> Void {
        if (textField === nameTextField) {
            self.lensName  = textField.text!
            self.nameValid = !textField.text!.isEmpty && stateController!.lenses.firstIndex(where: { $0.name == textField.text! }) == nil
        } else if textField === minFocalLengthTextField {
            self.minFocalLength      = (textField.text! as NSString).doubleValue
            if (isPrimeLensSwitch.isOn) {
                self.minFocalLengthValid = minFocalLength >= Constants.DEFAULT_LENS.minFocalLength && minFocalLength <= Constants.DEFAULT_LENS.maxFocalLength
            } else {
                self.minFocalLengthValid = minFocalLength >= Constants.DEFAULT_LENS.minFocalLength && minFocalLength <= self.maxFocalLength
            }
            if (isPrimeLensSwitch.isOn) {
                self.maxFocalLength      = (self.minFocalLengthTextField.text! as NSString).doubleValue
                self.maxFocalLengthValid = maxFocalLength <= Constants.DEFAULT_LENS.maxFocalLength && maxFocalLength >= self.minFocalLength
            }
        } else if textField === maxFocalLengthTextField {
            if (isPrimeLensSwitch.isOn) {
                self.maxFocalLength      = (self.minFocalLengthTextField.text! as NSString).doubleValue
                self.maxFocalLengthValid = maxFocalLength <= Constants.DEFAULT_LENS.maxFocalLength && maxFocalLength >= self.minFocalLength
            } else {
                self.maxFocalLength      = (textField.text! as NSString).doubleValue
                self.maxFocalLengthValid = maxFocalLength <= Constants.DEFAULT_LENS.maxFocalLength && maxFocalLength >= self.minFocalLength
            }
        } else if textField === minApertureTextField {
            self.minAperture      = (textField.text! as NSString).doubleValue
            self.minApertureValid = minAperture >= Constants.DEFAULT_LENS.minAperture && minAperture <= self.maxAperture
        } else if textField === maxApertureTextField {
            self.maxAperture      = (textField.text! as NSString).doubleValue
            self.maxApertureValid = maxAperture <= Constants.DEFAULT_LENS.maxAperture && maxAperture >= self.minAperture
        }
        validateForm()
    }
    @IBAction func isPrimeLensSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            maxFocalLengthTextField.text                     = ""
            maxFocalLengthTextField.isUserInteractionEnabled = false
        } else {
            maxFocalLengthTextField.isUserInteractionEnabled = true
        }
        validateForm()
    }
    
    
    private func validateForm() -> Void {
        self.doneButton.isEnabled = self.nameValid && self.minApertureValid && self.maxFocalLengthValid && self.minApertureValid && self.maxApertureValid
        self.doneButton.alpha     = self.doneButton.isEnabled ? 1.0 : 0.5
    
        nameIconView!.isHidden           = self.nameValid
        minFocalLengthIconView!.isHidden = self.minFocalLengthValid
        maxFocalLengthIconView!.isHidden = self.maxFocalLengthValid
        minApertureIconView!.isHidden    = self.minApertureValid
        maxApertureIconView!.isHidden    = self.maxApertureValid
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
    
    //MARK - UITextField Delegates
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        if textField == minFocalLengthTextField || textField == maxFocalLengthTextField || textField == minApertureTextField || textField == maxApertureTextField {
            let characterSetAllowed = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
            if let rangeOfCharactersAllowed = string.rangeOfCharacter(from: characterSetAllowed, options: .caseInsensitive) {
              let validCharacterCount = string.distance(from: rangeOfCharactersAllowed.lowerBound, to: rangeOfCharactersAllowed.upperBound)
              return validCharacterCount == string.count
            } else  {
              return false
            }
        }
        return true
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
