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
    var stateController    : StateController?
    var sentViaSegueObject : FoVController?
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "viewCell"
    
    @IBOutlet weak var mapButton     : UIBarButtonItem!
    @IBOutlet weak var camerasButton : UIBarButtonItem!
    @IBOutlet weak var lensesButton  : UIBarButtonItem!
    @IBOutlet weak var viewsButton   : UIBarButtonItem!
    @IBOutlet weak var spotsButton   : UIBarButtonItem!
    
    @IBOutlet weak var tableView     : UITableView!
    @IBOutlet weak var editViewButton: UIButton!
    @IBOutlet weak var addViewButton : UIButton!
        
    @IBOutlet weak var navBar: UINavigationBar!
    
    var viewSelection : [View]?
    var groupedViews  : Dictionary<String, [View]>?
    
    
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
        
        //let viewIndex : IndexPath = IndexPath(row: (viewSelection!.firstIndex(of: stateController!.view) ?? 0), section: 0)
        //tableView.selectRow(at: viewIndex, animated: true, scrollPosition: .none)
        //tableView.cellForRow(at: viewIndex)?.accessoryType = .checkmark
        tableView.isEditing = false
        
        groupedViews = groupByCountry()
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
    @IBAction func spotsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewsViewToSpotsView", sender: self)
    }
    
    @IBAction func addViewButtonPressed(_ sender: Any) {
        Helper.getCountryForView(view: stateController!.view)
        performSegue(withIdentifier: "viewsViewToViewDetailsView", sender: self)
    }
    
    @IBAction func editViewButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func done(segue:UIStoryboardSegue) {
        let viewDetailVC = segue.source as! ViewDetailViewController
        let view = View(name: viewDetailVC.name, description: viewDetailVC.descr, cameraPoint: stateController!.view.cameraPoint, motifPoint: stateController!.view.motifPoint, camera: stateController!.view.camera, lens: stateController!.view.lens, focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, orientation: stateController!.view.orientation, country: stateController!.view.country, mapRect: stateController!.view.mapRect, tags: viewDetailVC.tags, equipment: viewDetailVC.equipment, times: viewDetailVC.times)        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            stateController!.addView(view)
            stateController!.addViewToCD(appDelegate: appDelegate, view: view)
        }
        
        let hideDefaultView : Bool = stateController!.views.count > 1
        viewSelection = hideDefaultView ? stateController!.views.filter { $0.name != Constants.DEFAULT_VIEW.name } : stateController!.views
        groupedViews  = groupByCountry()
        tableView.reloadData()
        
        let cells = self.tableView.visibleCells as! Array<ViewCell>
        for cell in cells {
            cell.accessoryType = .none
        }
        
        /*
        let sectionIndex = groupedViews!.index(forKey: view.country)
        let rowIndex     = groupedViews![view.country]?.firstIndex(of: view) ?? 0
        
        let viewIndex : IndexPath = IndexPath(row: rowIndex, section: sectionIndex?.hashValue ?? 0)
        tableView.selectRow(at: viewIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: viewIndex)?.accessoryType = .checkmark
        */
        
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
    
    private func groupByCountry() -> Dictionary<String, [View]> {
        return Dictionary(grouping: viewSelection!, by: { $0.country })
    }
    
    
    // MARK: Tableview delegate and datasource methods
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedViews![(Array(groupedViews!.keys.sorted())[section])]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let country      = Array(groupedViews!.keys.sorted())[section]
        let countryName = (NSLocale.system.localizedString(forRegionCode: country) ?? "")
        return countryName
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedViews!.keys.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell    = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ViewCell
        cell.detailTextLabel!.numberOfLines = 0
        
        let country = Array(groupedViews!.keys.sorted())[indexPath.section]
        let view    = groupedViews![country]?[indexPath.row] ?? Constants.DEFAULT_VIEW
                                
        cell.textLabel?.text = (view.name)
        
        var text           : String
        var equipmentBegin : Int
        var equipmentEnd   : Int
        var timesBegin     : Int
        var timesEnd       : Int
        var tagsBegin      : Int
        var tagsEnd        : Int
        
        var equipment : String = " ["
        for equip in Constants.EQUIPMENT {
            equipment += Helper.itemInBitmask(item: equip, bitmask: view.equipment) ? Helper.textToAdd(item: equip.0, withComma: true) : ""
        }        
        
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
        for time in Constants.TIMES {
            times += Helper.itemInBitmask(item: time, bitmask: view.times)  ? Helper.textToAdd(item: time.0)  : ""
        }
        
        if times.count > 0 {
            if equipment.count > 2 {
                times.removeLast()
            }
            text += ("\n" + times)
        }
        timesBegin = equipment.count > 2 ? equipmentEnd + 1 : equipmentEnd
        timesEnd   = timesBegin + times.count
        
        var tags : String = ""
        for tag in Constants.TAGS {
            tags += Helper.itemInBitmask(item: tag, bitmask: view.tags) ? Helper.textToAdd(item: tag.0) : ""
        }
                
        if tags.count > 0 {
            if times.count > 0 || equipment.count > 2 {
                tags.removeLast()
            }
            text += ("\n" + tags)
        }
        tagsBegin = times.count == 0 ? timesEnd : timesEnd + 1
        tagsEnd   = equipment.count > 2 ? tags.count : tags.count + 1
       
        if text.count > 0 {
            let detailText :NSMutableAttributedString = NSMutableAttributedString(string: text)
            detailText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.YELLOW], range: NSRange(location: equipmentBegin, length: equipment.count > 2 ? equipment.count : 0))
            detailText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.BLUE], range: NSRange(location: timesBegin, length: times.count))
            detailText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.RED], range: NSRange(location: tagsBegin, length: tagsEnd))
        
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
        let country = Array(groupedViews!.keys.sorted())[indexPath.section]
        if let view = groupedViews![country]?[indexPath.row] {
            stateController!.setView(view)
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            performSegue(withIdentifier: "viewsViewToMapView", sender: self)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let country = Array(groupedViews!.keys.sorted())[indexPath.section]
            if let view = groupedViews![country]?[indexPath.row] {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    stateController!.removeView(view)
                    stateController!.removeViewFromCD(appDelegate: appDelegate, view: view)
                }
                let hideDefaultView : Bool = stateController!.views.count > 1
                viewSelection = hideDefaultView ? stateController!.views.filter { $0.name != Constants.DEFAULT_VIEW.name } : stateController!.views
                groupedViews  = groupByCountry()
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
