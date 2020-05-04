//
//  SpotDetailViewController.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 04.05.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public class SpotDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FoVController {
    var stateController: StateController?
    
    
    @IBOutlet weak var nameTextField        : UITextField!
    @IBOutlet weak var descriptionTextField : UITextField!
    
    @IBOutlet weak var cancelButton         : UIButton!
    @IBOutlet weak var doneButton           : UIButton!
    
    @IBOutlet weak var navBar               : UINavigationBar!
    
    @IBOutlet weak var tableView            : UITableView!
    
    
    let cellReuseIdentifier = "TagCell"
    
    var nameIconView         : UIView?
    var tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var name                 : String            = ""
    var descr                : String            = ""
    var tags                 : Int32             = 0
    var items                : [(String, Int32)] = Constants.TAGS
    
    var nameValid            : Bool              = false
    var descriptionValid     : Bool              = false
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        Helper.setNavBarTitle(navBar: navBar)
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        self.nameTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        self.descriptionTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        
        self.tapGestureRecognizer.numberOfTapsRequired = 1
        
        self.nameIconView = Helper.setupTextFieldWithAlertIcon(field: nameTextField, gestureRecognizer: tapGestureRecognizer)
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(TagCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
        
        validateForm()
    }
    
    
    @objc private func textFieldChanged(_ textField: UITextField) -> Void {
        if textField === nameTextField {
            self.name      = textField.text!
            self.nameValid = !textField.text!.isEmpty && stateController!.spots.firstIndex(where: { $0.name == textField.text! }) == nil
        } else if textField === descriptionTextField {
            self.descr = textField.text!
        }
        validateForm()
    }
    
    
    
    private func validateForm() -> Void {
        self.doneButton.isEnabled = self.nameValid
        self.doneButton.alpha     = self.doneButton.isEnabled ? 1.0 : 0.5
        nameIconView!.isHidden    = nameValid
    }
    
    private func setItem(item: String, isOn: Bool) -> Void {
        switch item {
            case Constants.TAG_NIGHT.0        : self.tags = isOn ? self.tags | Constants.TAG_NIGHT.1                : self.tags      ^ Constants.TAG_NIGHT.1
            case Constants.TAG_ASTRO.0        : self.tags = isOn ? self.tags | Constants.TAG_ASTRO.1                : self.tags      ^ Constants.TAG_ASTRO.1
            case Constants.TAG_MACRO.0        : self.tags = isOn ? self.tags | Constants.TAG_MACRO.1                : self.tags      ^ Constants.TAG_MACRO.1
            case Constants.TAG_POI.0          : self.tags = isOn ? self.tags | Constants.TAG_POI.1                  : self.tags      ^ Constants.TAG_POI.1
            case Constants.TAG_INFRARED.0     : self.tags = isOn ? self.tags | Constants.TAG_INFRARED.1             : self.tags      ^ Constants.TAG_INFRARED.1
            case Constants.TAG_LONG_EXPOSURE.0: self.tags = isOn ? self.tags | Constants.TAG_LONG_EXPOSURE.1        : self.tags      ^ Constants.TAG_LONG_EXPOSURE.1
            case Constants.TAG_CITYSCAPE.0    : self.tags = isOn ? self.tags | Constants.TAG_CITYSCAPE.1            : self.tags      ^ Constants.TAG_CITYSCAPE.1
            case Constants.TAG_LANDSCAPE.0    : self.tags = isOn ? self.tags | Constants.TAG_LANDSCAPE.1            : self.tags      ^ Constants.TAG_LANDSCAPE.1
            case Constants.TAG_STREET.0       : self.tags = isOn ? self.tags | Constants.TAG_STREET.1               : self.tags      ^ Constants.TAG_STREET.1
            case Constants.TAG_BRIDGE.0       : self.tags = isOn ? self.tags | Constants.TAG_BRIDGE.1               : self.tags      ^ Constants.TAG_BRIDGE.1
            case Constants.TAG_LAKE.0         : self.tags = isOn ? self.tags | Constants.TAG_LAKE.1                 : self.tags      ^ Constants.TAG_LAKE.1
            case Constants.TAG_SHIP.0         : self.tags = isOn ? self.tags | Constants.TAG_SHIP.1                 : self.tags      ^ Constants.TAG_SHIP.1
            case Constants.TAG_CAR.0          : self.tags = isOn ? self.tags | Constants.TAG_CAR.1                  : self.tags      ^ Constants.TAG_CAR.1
            case Constants.TAG_FLOWER.0       : self.tags = isOn ? self.tags | Constants.TAG_FLOWER.1               : self.tags      ^ Constants.TAG_FLOWER.1
            case Constants.TAG_TREE.0         : self.tags = isOn ? self.tags | Constants.TAG_TREE.1                 : self.tags      ^ Constants.TAG_TREE.1
            case Constants.TAG_BUILDING.0     : self.tags = isOn ? self.tags | Constants.TAG_BUILDING.1             : self.tags      ^ Constants.TAG_BUILDING.1
            case Constants.TAG_BEACH.0        : self.tags = isOn ? self.tags | Constants.TAG_BEACH.1                : self.tags      ^ Constants.TAG_BEACH.1
            case Constants.TAG_SUNRISE.0      : self.tags = isOn ? self.tags | Constants.TAG_SUNRISE.1              : self.tags      ^ Constants.TAG_SUNRISE.1
            case Constants.TAG_SUNSET.0       : self.tags = isOn ? self.tags | Constants.TAG_SUNSET.1               : self.tags      ^ Constants.TAG_SUNSET.1
            case Constants.TAG_MOON.0         : self.tags = isOn ? self.tags | Constants.TAG_MOON.1                 : self.tags      ^ Constants.TAG_MOON.1
            case Constants.TAG_ARCHITECTURE.0 : self.tags = isOn ? self.tags | Constants.TAG_ARCHITECTURE.1         : self.tags      ^ Constants.TAG_ARCHITECTURE.1
            case Constants.TAG_CLOSEUP.0      : self.tags = isOn ? self.tags | Constants.TAG_CLOSEUP.1              : self.tags      ^ Constants.TAG_CLOSEUP.1
            case Constants.TAG_RIVER.0        : self.tags = isOn ? self.tags | Constants.TAG_RIVER.1                : self.tags      ^ Constants.TAG_RIVER.1
            case Constants.TAG_CHURCH.0       : self.tags = isOn ? self.tags | Constants.TAG_CHURCH.1               : self.tags      ^ Constants.TAG_CHURCH.1
            case Constants.TAG_TRAIN.0        : self.tags = isOn ? self.tags | Constants.TAG_TRAIN.1                : self.tags      ^ Constants.TAG_TRAIN.1
            default                           : break
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
        }
    }
    
    //MARK: tableview delegate methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! TagCell
        let item : (String, Int32) = items[indexPath.item]
        
        //here is programatically switch make to the table view
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag         = indexPath.row // for detect which row switch Changed
        switchView.onTintColor = UIColor.systemTeal
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        switchView.setOn(Helper.itemInBitmask(item: item, bitmask: tags), animated: false)
        
        cell.accessoryView         = switchView
        cell.textLabel?.text       = item.0
        cell.textLabel?.textColor  = Constants.RED
        cell.detailTextLabel?.text = "Tag"
        
        return cell
    }
    
    @objc func switchChanged(_ sender : UISwitch!) {
        if let text = tableView!.cellForRow(at: IndexPath(row: sender.tag, section:0))?.textLabel!.text {
            setItem(item: text, isOn: sender.isOn)
        }
    }
}


class TagCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.tintColor = UIColor.systemTeal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
