//
//  LensDetailViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 04.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public class LensDetailViewController: UIViewController, UITextFieldDelegate, FoVController {
    var stateController: StateController?
    
    
    @IBOutlet weak var nameTextField           : UITextField!
    @IBOutlet weak var minFocalLengthTextField : UITextField!
    @IBOutlet weak var maxFocalLengthTextField : UITextField!
    @IBOutlet weak var minApertureTextField    : UITextField!
    @IBOutlet weak var maxApertureTextField    : UITextField!
    
    @IBOutlet weak var cancelButton            : UIButton!
    @IBOutlet weak var doneButton              : UIButton!
    
    var nameIconView           : UIImageView = UIImageView(image: Constants.INFO_ICON)
    var minFocalLengthIconView : UIImageView = UIImageView(image: Constants.INFO_ICON)
    var maxFocalLengthIconView : UIImageView = UIImageView(image: Constants.INFO_ICON)
    var minApertureIconView    : UIImageView = UIImageView(image: Constants.INFO_ICON)
    var maxApertureIconView    : UIImageView = UIImageView(image: Constants.INFO_ICON)
    var tapGestureRecognizer   : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var lensName               : String = ""
    var minFocalLength         : Double = Constants.DEFAULT_LENS.minFocalLength
    var maxFocalLength         : Double = Constants.DEFAULT_LENS.maxFocalLength
    var minAperture            : Double = Constants.DEFAULT_LENS.minAperture
    var maxAperture            : Double = Constants.DEFAULT_LENS.maxAperture
    
    var nameValid              : Bool   = false
    var minFocalLengthValid    : Bool = false
    var maxFocalLengthValid    : Bool = false
    var minApertureValid       : Bool = false
    var maxApertureValid       : Bool = false
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        nameTextField.delegate       = self
        minFocalLengthTextField.delegate = self
        maxFocalLengthTextField.delegate = self
        minApertureTextField.delegate    = self
        maxApertureTextField.delegate    = self
        
        nameTextField.addTarget(self, action: #selector(updateName), for: .editingChanged)
        minFocalLengthTextField.addTarget(self, action: #selector(updateMinFocalLength), for: .editingChanged)
        maxFocalLengthTextField.addTarget(self, action: #selector(updateMaxFocalLength), for: .editingChanged)
        minApertureTextField.addTarget(self, action: #selector(updateMinAperture), for: .editingChanged)
        maxApertureTextField.addTarget(self, action: #selector(updateMaxAperture), for: .editingChanged)
        
        tapGestureRecognizer.numberOfTapsRequired = 1
        Helper.setupTextFieldWithIcon(field: nameTextField,       imageView: nameIconView, gestureRecognizer: tapGestureRecognizer)
        Helper.setupTextFieldWithIcon(field: minFocalLengthTextField, imageView: minFocalLengthIconView, gestureRecognizer: tapGestureRecognizer)
        Helper.setupTextFieldWithIcon(field: maxFocalLengthTextField, imageView: maxFocalLengthIconView, gestureRecognizer: tapGestureRecognizer)
        Helper.setupTextFieldWithIcon(field: minApertureTextField,    imageView: minApertureIconView, gestureRecognizer: tapGestureRecognizer)
        Helper.setupTextFieldWithIcon(field: maxApertureTextField,    imageView: maxApertureIconView, gestureRecognizer: tapGestureRecognizer)
    }
    
    
    @objc private func updateName() -> Void {
        self.lensName  = nameTextField!.text!
        self.nameValid = !nameTextField!.text!.isEmpty
    }
    @objc private func updateMinFocalLength() -> Void {
        self.minFocalLength      = (minFocalLengthTextField!.text! as NSString).doubleValue
        self.minFocalLengthValid = !minFocalLengthTextField!.text!.isEmpty
    }
    @objc private func updateMaxFocalLength() -> Void {
        self.maxFocalLength      = (maxFocalLengthTextField!.text! as NSString).doubleValue
        self.maxFocalLengthValid = !maxFocalLengthTextField!.text!.isEmpty
    }
    @objc private func updateMinAperture() -> Void {
        self.minAperture      = (minApertureTextField!.text! as NSString).doubleValue
        self.minApertureValid = !minApertureTextField!.text!.isEmpty
    }
    @objc private func updateMaxAperture() -> Void {
        self.maxAperture      = (maxApertureTextField!.text! as NSString).doubleValue
        self.maxApertureValid = !maxApertureTextField!.text!.isEmpty
    }
    
    
    
    
    private func validateForm() -> Void {
        self.doneButton.isEnabled = self.nameValid && self.minApertureValid && self.maxFocalLengthValid && self.minApertureValid && self.maxApertureValid
        self.doneButton.alpha     = self.doneButton.isEnabled ? 1.0 : 0.5
    
        nameIconView.isHidden           = self.nameValid
        minFocalLengthIconView.isHidden = self.minFocalLengthValid
        maxFocalLengthIconView.isHidden = self.maxFocalLengthValid
        minApertureIconView.isHidden    = self.minApertureValid
        maxApertureIconView.isHidden    = self.maxApertureValid
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
            lensName   = nameTextField.text!
            print("doneSegue prepared with data: \(String(describing: nameTextField!.text))")
        }
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
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        validateForm()
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === self.nameTextField {
            self.nameValid = !textField.text!.isEmpty
        } else if textField === self.minFocalLengthTextField {
            let value : Double = (textField.text! as NSString).doubleValue
            self.minFocalLengthValid = value >= Constants.DEFAULT_LENS.minFocalLength && value < self.maxFocalLength
        } else if textField == self.maxFocalLengthTextField {
            let value : Double = (textField.text! as NSString).doubleValue
            self.maxFocalLengthValid = value <= Constants.DEFAULT_LENS.maxFocalLength && value > self.minFocalLength
        } else if textField == self.minApertureTextField {
            let value : Double = (textField.text! as NSString).doubleValue
            self.minApertureValid = value >= Constants.DEFAULT_LENS.minAperture && value < self.maxAperture
        } else if textField == self.maxApertureTextField {
            let value : Double = (textField.text! as NSString).doubleValue
            self.maxApertureValid = value <= Constants.DEFAULT_LENS.maxAperture && value > self.minAperture
        }
        validateForm()
    }
}
