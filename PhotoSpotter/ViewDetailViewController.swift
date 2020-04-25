//
//  ViewDetailViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 05.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

public class ViewDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FoVController {
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
    @IBOutlet weak var tableView            : UITableView!
    
    
    let cellReuseIdentifier = "ItemCell"
    
    var nameIconView         : UIView?
    var tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAlert(sender:)))
    
    var name                 : String            = ""
    var descr                : String            = ""
    var equipment            : Int32             = 0
    var times                : Int32             = 0
    var tags                 : Int32             = 0
    var items                : [(String, Int32)] = Constants.EQUIPMENT + Constants.TIMES + Constants.TAGS
    
    var nameValid            : Bool              = false
    var descriptionValid     : Bool              = false
    
    
    
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
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(ItemCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
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
    
    private func setItem(item: String, isOn: Bool) -> Void {
        switch item {
            case Constants.EQP_TRIPOD.0       : self.equipment = isOn ? self.equipment | Constants.EQP_TRIPOD.1     : self.equipment | -Constants.EQP_TRIPOD.1
            case Constants.EQP_GIMBAL.0       : self.equipment = isOn ? self.equipment | Constants.EQP_GIMBAL.1     : self.equipment | -Constants.EQP_GIMBAL.1
            case Constants.EQP_CPL_FILTER.0   : self.equipment = isOn ? self.equipment | Constants.EQP_CPL_FILTER.1 : self.equipment | -Constants.EQP_CPL_FILTER.1
            case Constants.EQP_ND_FILTER.0    : self.equipment = isOn ? self.equipment | Constants.EQP_ND_FILTER.1  : self.equipment | -Constants.EQP_ND_FILTER.1
            case Constants.EQP_IR_FILTER.0    : self.equipment = isOn ? self.equipment | Constants.EQP_IR_FILTER.1  : self.equipment | -Constants.EQP_IR_FILTER.1
            case Constants.EQP_FLASH.0        : self.equipment = isOn ? self.equipment | Constants.EQP_FLASH.1      : self.equipment | Constants.EQP_FLASH.1
            case Constants.EQP_REMOTE.0       : self.equipment = isOn ? self.equipment | Constants.EQP_REMOTE.1     : self.equipment | Constants.EQP_REMOTE.1
            
            case Constants.TMS_ALL_YEAR.0     : self.times = isOn ? self.times | Constants.TMS_ALL_YEAR.1           : self.times     | -Constants.TMS_ALL_YEAR.1
            case Constants.TMS_SPRING.0       : self.times = isOn ? self.times | Constants.TMS_SPRING.1             : self.times     | -Constants.TMS_SPRING.1
            case Constants.TMS_SUMMER.0       : self.times = isOn ? self.times | Constants.TMS_SUMMER.1             : self.times     | -Constants.TMS_SUMMER.1
            case Constants.TMS_AUTUMN.0       : self.times = isOn ? self.times | Constants.TMS_AUTUMN.1             : self.times     | -Constants.TMS_AUTUMN.1
            case Constants.TMS_WINTER.0       : self.times = isOn ? self.times | Constants.TMS_WINTER.1             : self.times     | -Constants.TMS_WINTER.1
            case Constants.TMS_JANUARY.0      : self.times = isOn ? self.times | Constants.TMS_JANUARY.1            : self.times     | -Constants.TMS_JANUARY.1
            case Constants.TMS_FEBRUARY.0     : self.times = isOn ? self.times | Constants.TMS_FEBRUARY.1           : self.times     | -Constants.TMS_FEBRUARY.1
            case Constants.TMS_MARCH.0        : self.times = isOn ? self.times | Constants.TMS_MARCH.1              : self.times     | -Constants.TMS_MARCH.1
            case Constants.TMS_APRIL.0        : self.times = isOn ? self.times | Constants.TMS_APRIL.1              : self.times     | -Constants.TMS_APRIL.1
            case Constants.TMS_MAY.0          : self.times = isOn ? self.times | Constants.TMS_MAY.1                : self.times     | -Constants.TMS_MAY.1
            case Constants.TMS_JUNE.0         : self.times = isOn ? self.times | Constants.TMS_JUNE.1               : self.times     | -Constants.TMS_JUNE.1
            case Constants.TMS_JULY.0         : self.times = isOn ? self.times | Constants.TMS_JULY.1               : self.times     | -Constants.TMS_JULY.1
            case Constants.TMS_AUGUST.0       : self.times = isOn ? self.times | Constants.TMS_AUGUST.1             : self.times     | -Constants.TMS_AUGUST.1
            case Constants.TMS_SEPTEMBER.0    : self.times = isOn ? self.times | Constants.TMS_SEPTEMBER.1          : self.times     | -Constants.TMS_SEPTEMBER.1
            case Constants.TMS_OCTOBER.0      : self.times = isOn ? self.times | Constants.TMS_OCTOBER.1            : self.times     | -Constants.TMS_OCTOBER.1
            case Constants.TMS_NOVEMBER.0     : self.times = isOn ? self.times | Constants.TMS_NOVEMBER.1           : self.times     | -Constants.TMS_NOVEMBER.1
            case Constants.TMS_DECEMBER.0     : self.times = isOn ? self.times | Constants.TMS_DECEMBER.1           : self.times     | -Constants.TMS_DECEMBER.1
            
            case Constants.TAG_NIGHT.0        : self.tags = isOn ? self.tags | Constants.TAG_NIGHT.1                : self.tags      | -Constants.TAG_NIGHT.1
            case Constants.TAG_ASTRO.0        : self.tags = isOn ? self.tags | Constants.TAG_ASTRO.1                : self.tags      | -Constants.TAG_ASTRO.1
            case Constants.TAG_MACRO.0        : self.tags = isOn ? self.tags | Constants.TAG_MACRO.1                : self.tags      | -Constants.TAG_MACRO.1
            case Constants.TAG_POI.0          : self.tags = isOn ? self.tags | Constants.TAG_POI.1                  : self.tags      | -Constants.TAG_POI.1
            case Constants.TAG_INFRARED.0     : self.tags = isOn ? self.tags | Constants.TAG_INFRARED.1             : self.tags      | -Constants.TAG_INFRARED.1
            case Constants.TAG_LONG_EXPOSURE.0: self.tags = isOn ? self.tags | Constants.TAG_LONG_EXPOSURE.1        : self.tags      | -Constants.TAG_LONG_EXPOSURE.1
            case Constants.TAG_CITYSCAPE.0    : self.tags = isOn ? self.tags | Constants.TAG_CITYSCAPE.1            : self.tags      | -Constants.TAG_CITYSCAPE.1
            case Constants.TAG_LANDSCAPE.0    : self.tags = isOn ? self.tags | Constants.TAG_LANDSCAPE.1            : self.tags      | -Constants.TAG_LANDSCAPE.1
            case Constants.TAG_STREET.0       : self.tags = isOn ? self.tags | Constants.TAG_STREET.1               : self.tags      | -Constants.TAG_STREET.1
            case Constants.TAG_BRIDGE.0       : self.tags = isOn ? self.tags | Constants.TAG_BRIDGE.1               : self.tags      | -Constants.TAG_BRIDGE.1
            case Constants.TAG_LAKE.0         : self.tags = isOn ? self.tags | Constants.TAG_LAKE.1                 : self.tags      | -Constants.TAG_LAKE.1
            case Constants.TAG_SHIP.0         : self.tags = isOn ? self.tags | Constants.TAG_SHIP.1                 : self.tags      | -Constants.TAG_SHIP.1
            case Constants.TAG_CAR.0          : self.tags = isOn ? self.tags | Constants.TAG_CAR.1                  : self.tags      | -Constants.TAG_CAR.1
            case Constants.TAG_FLOWER.0       : self.tags = isOn ? self.tags | Constants.TAG_FLOWER.1               : self.tags      | -Constants.TAG_FLOWER.1
            case Constants.TAG_TREE.0         : self.tags = isOn ? self.tags | Constants.TAG_TREE.1                 : self.tags      | -Constants.TAG_TREE.1
            case Constants.TAG_BUILDING.0     : self.tags = isOn ? self.tags | Constants.TAG_BUILDING.1             : self.tags      | -Constants.TAG_BUILDING.1
            case Constants.TAG_BEACH.0        : self.tags = isOn ? self.tags | Constants.TAG_BEACH.1                : self.tags      | -Constants.TAG_BEACH.1
            case Constants.TAG_SUNRISE.0      : self.tags = isOn ? self.tags | Constants.TAG_SUNRISE.1              : self.tags      | -Constants.TAG_SUNRISE.1
            case Constants.TAG_SUNSET.0       : self.tags = isOn ? self.tags | Constants.TAG_SUNSET.1               : self.tags      | -Constants.TAG_SUNSET.1
            case Constants.TAG_MOON.0         : self.tags = isOn ? self.tags | Constants.TAG_MOON.1                 : self.tags      | -Constants.TAG_MOON.1
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ItemCell
        let item : (String, Int32) = items[indexPath.item]
        
        //here is programatically switch make to the table view
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = indexPath.row // for detect which row switch Changed
        switchView.onTintColor = UIColor.systemTeal
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        if Helper.isItemInGroup(item: item, group: Constants.EQUIPMENT) {
            switchView.setOn(Helper.itemInBitmask(item: item, bitmask: equipment), animated: false)
        } else if Helper.isItemInGroup(item: item, group: Constants.TIMES) {
            switchView.setOn(Helper.itemInBitmask(item: item, bitmask: times), animated: false)
        } else if Helper.isItemInGroup(item: item, group: Constants.TAGS) {
            switchView.setOn(Helper.itemInBitmask(item: item, bitmask: tags), animated: false)
        }
        cell.accessoryView = switchView
        
        cell.textLabel?.text = item.0
        
        if Helper.isItemInGroup(item: item, group: Constants.EQUIPMENT) {
            cell.textLabel?.textColor = Constants.YELLOW
            cell.detailTextLabel?.text = "Equipment"
        } else if Helper.isItemInGroup(item: item, group: Constants.TIMES) {
            cell.textLabel?.textColor = Constants.BLUE
            cell.detailTextLabel?.text = "Time"
        } else {
            cell.textLabel?.textColor = Constants.RED
            cell.detailTextLabel?.text = "Tag"
        }
        
        return cell
    }
    
    @objc func switchChanged(_ sender : UISwitch!) {
        if let text = tableView!.cellForRow(at: IndexPath(row: sender.tag, section:0))?.textLabel!.text {
            //print("\(text) => \(sender.isOn ? "ON" : "OFF")")
            setItem(item: text, isOn: sender.isOn)
        }                        
    }
}


class ItemCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.tintColor = UIColor.systemTeal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
