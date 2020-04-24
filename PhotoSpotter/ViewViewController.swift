//
//  ViewViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 05.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

class ViewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FoVController {
    var stateController : StateController?
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "viewCell"
    
    @IBOutlet weak var mapButton     : UIBarButtonItem!
    @IBOutlet weak var camerasButton : UIBarButtonItem!
    @IBOutlet weak var lensesButton  : UIBarButtonItem!
    @IBOutlet weak var viewsButton   : UIBarButtonItem!
    
    @IBOutlet weak var tableView     : UITableView!
    @IBOutlet weak var editViewButton: UIButton!
    @IBOutlet weak var addViewButton : UIButton!
        
    @IBOutlet weak var navBar: UINavigationBar!
    
    var viewSelection : [View]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.setNavBarTitle(navBar: navBar)

        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        let hideDefaultView : Bool = stateController!.views.count > 1
        viewSelection = hideDefaultView ? stateController!.views.filter { $0.name != Constants.DEFAULT_VIEW.name } : stateController!.views
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(ViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
        
        for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
        
        let viewIndex : IndexPath = IndexPath(row: (viewSelection!.firstIndex(of: stateController!.view) ?? 0), section: 0)
        tableView.selectRow(at: viewIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: viewIndex)?.accessoryType = .checkmark
        tableView.isEditing = false
    }
    
    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewsViewToMapView", sender: self)
    }
    @IBAction func camerasButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewsViewToCamerasView", sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewsViewToLensesView", sender: self)
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
    }
    
    @IBAction func addViewButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewsViewToViewDetailsView", sender: self)
    }
    
    @IBAction func editViewButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func done(segue:UIStoryboardSegue) {
        let viewDetailVC = segue.source as! ViewDetailViewController
        let view = View(name: viewDetailVC.name, description: viewDetailVC.descr, cameraPoint: stateController!.view.cameraPoint, motifPoint: stateController!.view.motifPoint, camera: stateController!.view.camera, lens: stateController!.view.lens, focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, orientation: stateController!.view.orientation, mapRect: stateController!.view.mapRect, tags: viewDetailVC.tags, equipment: viewDetailVC.equipment, times: viewDetailVC.times)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            stateController!.addView(view)
            stateController!.addViewToCD(appDelegate: appDelegate, view: view)
        }
        
        let hideDefaultView : Bool = stateController!.views.count > 1
        viewSelection = hideDefaultView ? stateController!.views.filter { $0.name != Constants.DEFAULT_VIEW.name } : stateController!.views
        tableView.reloadData()
        
        let cells = self.tableView.visibleCells as! Array<ViewCell>
        for cell in cells {
            cell.accessoryType = .none
        }
        
        let viewIndex : IndexPath = IndexPath(row: (viewSelection!.firstIndex(of: view) ?? 0), section: 0)
        tableView.selectRow(at: viewIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: viewIndex)?.accessoryType = .checkmark
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            stateController!.storeViewsToCD(appDelegate: appDelegate)
        }
        
        stateController!.setView(view)
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
       
    }
    
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        #if targetEnvironment(macCatalyst)
            guard let key = presses.first?.key else { return }
            switch key.keyCode {
                case .keyboardDeleteOrBackspace:
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let selectedCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
                        if let view = self.stateController!.views.filter({ $0.name == selectedCell.textLabel?.text }).first {
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                stateController!.removeView(view)
                                stateController!.removeViewFromCD(appDelegate: appDelegate, view: view)
                            }
                            let hideDefaultView : Bool = self.stateController!.views.count > 1
                            self.viewSelection = hideDefaultView ? self.stateController!.views.filter { $0.name != Constants.DEFAULT_VIEW.name } : self.stateController!.views
                            tableView.reloadData()
                        }
                    }
            default:
                super.pressesBegan(presses, with: event)
            }
        #else
            super.pressesBegan(presses, with: event)
        #endif
    }
    
    
    // MARK: Tableview delegate and datasource methods
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewSelection!.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                            = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ViewCell
        let view : View                     = viewSelection![indexPath.item]
        cell.detailTextLabel!.numberOfLines = 0
        
        cell.textLabel?.text = view.name
        
        var text           : String
        var equipmentBegin : Int
        var equipmentEnd   : Int
        var timesBegin     : Int
        var timesEnd       : Int
        var tagsBegin      : Int
        
        var equipment : String = " ["
        equipment += Helper.equipmentInBitMask(equipment: Constants.EQP_TRIPOD,     bitmask: view.equipment) ? Helper.textToAdd(item: Constants.EQP_TRIPOD.0,     withComma: true) : ""
        equipment += Helper.equipmentInBitMask(equipment: Constants.EQP_GIMBAL,     bitmask: view.equipment) ? Helper.textToAdd(item: Constants.EQP_GIMBAL.0,     withComma: true) : ""
        equipment += Helper.equipmentInBitMask(equipment: Constants.EQP_CPL_FILTER, bitmask: view.equipment) ? Helper.textToAdd(item: Constants.EQP_CPL_FILTER.0, withComma: true) : ""
        equipment += Helper.equipmentInBitMask(equipment: Constants.EQP_ND_FILTER,  bitmask: view.equipment) ? Helper.textToAdd(item: Constants.EQP_ND_FILTER.0,  withComma: true) : ""
        equipment += Helper.equipmentInBitMask(equipment: Constants.EQP_IR_FILTER,  bitmask: view.equipment) ? Helper.textToAdd(item: Constants.EQP_IR_FILTER.0,  withComma: true) : ""
        equipment += Helper.equipmentInBitMask(equipment: Constants.EQP_FLASH,      bitmask: view.equipment) ? Helper.textToAdd(item: Constants.EQP_FLASH.0,      withComma: true) : ""
        equipment += Helper.equipmentInBitMask(equipment: Constants.EQP_REMOTE,     bitmask: view.equipment) ? Helper.textToAdd(item: Constants.EQP_REMOTE.0,     withComma: true) : ""
        
        if equipment.count > 2 {
            equipment.removeLast(2)
            equipment += "]"
            text = view.description + equipment
        } else {
            text = view.description
        }
        equipmentBegin = view.description.count        
        equipmentEnd   = equipmentBegin + (equipment.count > 2 ? equipment.count : 0)
        
        var times : String = ""
        times += Helper.timeInBitMask(time: Constants.TMS_ALL_YEAR, bitmask: view.times)  ? Helper.textToAdd(item: Constants.TMS_ALL_YEAR.0)  : ""
        times += Helper.timeInBitMask(time: Constants.TMS_SPRING, bitmask: view.times)    ? Helper.textToAdd(item: Constants.TMS_SPRING.0)    : ""
        times += Helper.timeInBitMask(time: Constants.TMS_SUMMER, bitmask: view.times)    ? Helper.textToAdd(item: Constants.TMS_SUMMER.0)    : ""
        times += Helper.timeInBitMask(time: Constants.TMS_AUTUMN, bitmask: view.times)    ? Helper.textToAdd(item: Constants.TMS_AUTUMN.0)    : ""
        times += Helper.timeInBitMask(time: Constants.TMS_WINTER, bitmask: view.times)    ? Helper.textToAdd(item: Constants.TMS_WINTER.0)    : ""
        times += Helper.timeInBitMask(time: Constants.TMS_JANUARY, bitmask: view.times)   ? Helper.textToAdd(item: Constants.TMS_JANUARY.0)   : ""
        times += Helper.timeInBitMask(time: Constants.TMS_FEBRUARY, bitmask: view.times)  ? Helper.textToAdd(item: Constants.TMS_FEBRUARY.0)  : ""
        times += Helper.timeInBitMask(time: Constants.TMS_MARCH, bitmask: view.times)     ? Helper.textToAdd(item: Constants.TMS_MARCH.0)     : ""
        times += Helper.timeInBitMask(time: Constants.TMS_APRIL, bitmask: view.times)     ? Helper.textToAdd(item: Constants.TMS_APRIL.0)     : ""
        times += Helper.timeInBitMask(time: Constants.TMS_MAY, bitmask: view.times)       ? Helper.textToAdd(item: Constants.TMS_MAY.0)       : ""
        times += Helper.timeInBitMask(time: Constants.TMS_JUNE, bitmask: view.times)      ? Helper.textToAdd(item: Constants.TMS_JUNE.0)      : ""
        times += Helper.timeInBitMask(time: Constants.TMS_JULY, bitmask: view.times)      ? Helper.textToAdd(item: Constants.TMS_JULY.0)      : ""
        times += Helper.timeInBitMask(time: Constants.TMS_AUGUST, bitmask: view.times)    ? Helper.textToAdd(item: Constants.TMS_AUGUST.0)    : ""
        times += Helper.timeInBitMask(time: Constants.TMS_SEPTEMBER, bitmask: view.times) ? Helper.textToAdd(item: Constants.TMS_SEPTEMBER.0) : ""
        times += Helper.timeInBitMask(time: Constants.TMS_OCTOBER, bitmask: view.times)   ? Helper.textToAdd(item: Constants.TMS_OCTOBER.0)   : ""
        times += Helper.timeInBitMask(time: Constants.TMS_NOVEMBER, bitmask: view.times)  ? Helper.textToAdd(item: Constants.TMS_NOVEMBER.0)  : ""
        times += Helper.timeInBitMask(time: Constants.TMS_DECEMBER, bitmask: view.times)  ? Helper.textToAdd(item: Constants.TMS_DECEMBER.0)  : ""
        
        if times.count > 0 {
            if equipment.count > 2 {
                times.removeLast()
                text += ("\n" + times)
            } else {
                text += times
            }
        }
        timesBegin = equipment.count > 2 ? equipmentEnd + 1 : equipmentEnd
        timesEnd   = timesBegin + times.count
        
        var tags : String = ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_NIGHT,         bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_NIGHT.0)         : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_ASTRO,         bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_ASTRO.0)         : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_MACRO,         bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_MACRO.0)         : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_POI,           bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_POI.0)           : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_INFRARED,      bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_INFRARED.0)      : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_LONG_EXPOSURE, bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_LONG_EXPOSURE.0) : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_CITYSCAPE,     bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_CITYSCAPE.0)     : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_LANDSCAPE,     bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_LANDSCAPE.0)     : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_STREET,        bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_STREET.0)        : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_BRIDGE,        bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_BRIDGE.0)        : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_LAKE,          bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_LAKE.0)          : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_SHIP,          bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_SHIP.0)          : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_CAR,           bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_CAR.0)           : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_FLOWER,        bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_FLOWER.0)        : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_TREE,          bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_TREE.0)          : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_BUILDING,      bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_BUILDING.0)      : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_BEACH,         bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_BEACH.0)         : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_SUNRISE,       bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_SUNRISE.0)       : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_SUNSET,        bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_SUNSET.0)        : ""
        tags += Helper.tagInBitMask(tag: Constants.TAG_MOON,          bitmask: view.tags) ? Helper.textToAdd(item: Constants.TAG_MOON.0)          : ""
        
        if tags.count > 0 {
            if times.count > 0 || equipment.count > 2 {
                tags.removeLast()
                text += ("\n" + tags)
            } else {
                text += tags
            }
        }
        tagsBegin = times.count == 0 ? timesEnd : timesEnd + 1
       
        if text.count > 0 {
            let detailText :NSMutableAttributedString = NSMutableAttributedString(string: text)
            detailText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.YELLOW], range: NSRange(location: equipmentBegin, length: equipment.count > 2 ? equipment.count : 0))
            detailText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.BLUE], range: NSRange(location: timesBegin, length: times.count))
            detailText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.RED], range: NSRange(location: tagsBegin, length: tags.count))
        
            cell.detailTextLabel?.attributedText = detailText
        }
        return cell
    }
    
    // method to set all table view cells to height of 100
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = viewSelection![indexPath.item]
        stateController!.setView(view)
        
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
            if let view = self.stateController!.views.filter({ $0.name == selectedCell.textLabel?.text }).first {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    stateController!.removeView(view)
                    stateController!.removeViewFromCD(appDelegate: appDelegate, view: view)
                }
                let hideDefaultView : Bool = stateController!.views.count > 1
                viewSelection = hideDefaultView ? stateController!.views.filter { $0.name != Constants.DEFAULT_VIEW.name } : stateController!.views
                tableView.reloadData()
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    */
 
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if viewSelection![indexPath.row].name == Constants.DEFAULT_VIEW.name {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
    }
}


class ViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.tintColor = UIColor.systemTeal
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
