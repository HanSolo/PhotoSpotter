//
//  SpotViewController.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 04.05.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class SpotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FoVController {
    var stateController : StateController?
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "spotCell"
    
    @IBOutlet weak var mapButton     : UIBarButtonItem!
    @IBOutlet weak var camerasButton : UIBarButtonItem!
    @IBOutlet weak var lensesButton  : UIBarButtonItem!
    @IBOutlet weak var viewsButton   : UIBarButtonItem!
    @IBOutlet weak var spotsButton   : UIBarButtonItem!
    
    @IBOutlet weak var tableView     : UITableView!
    @IBOutlet weak var editSpotButton: UIButton!
    @IBOutlet weak var addSpotButton : UIButton!
        
    @IBOutlet weak var navBar: UINavigationBar!
    
    var spotSelection : [Spot]?
    var groupedSpots  : Dictionary<String, [Spot]>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.setNavBarTitle(navBar: navBar)

        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
                
        spotSelection = stateController!.spots
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(SpotCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
        
        for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.isEditing  = false
        
        groupedSpots = groupByCountry()
    }
    
    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "spotsViewToMapView", sender: self)
    }
    @IBAction func camerasButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "spotsViewToCamerasView", sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "spotsViewToLensesView", sender: self)
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "spotsViewToViewsView", sender: self)
    }
    @IBAction func spotsButtonPressed(_ sender: Any) {
    }
    
        
    @IBAction func addSpotButtonPressed(_ sender: Any) {
        stateController!.setSpot(Spot(name: "current", description: "", point: MKMapPoint(stateController!.lastLocation.coordinate), country: ""))
        Helper.getCountryForSpot(spot: stateController!.spot)
        performSegue(withIdentifier: "spotsViewToSpotDetailsView", sender: self)
    }
    
    @IBAction func editSpotButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func done(segue:UIStoryboardSegue) {        
        let spotDetailVC = segue.source as! SpotDetailViewController
        let spot = Spot(name: spotDetailVC.name, description: spotDetailVC.descr, point: MKMapPoint(stateController!.lastLocation.coordinate), country: stateController!.spot.country, tags: spotDetailVC.tags)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            stateController!.addSpot(spot)
            stateController!.addSpotToCD(appDelegate: appDelegate, spot: spot)
        }
                
        spotSelection = stateController!.spots
        groupedSpots  = groupByCountry()
        tableView.reloadData()
        
        let cells = self.tableView.visibleCells as! Array<SpotCell>
        for cell in cells {
            cell.accessoryType = .none
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            stateController!.storeSpotsToCD(appDelegate: appDelegate)
        }
        
        stateController!.setSpot(spot)
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
                        if let spot = self.stateController!.spots.filter({ $0.name == selectedCell.textLabel?.text }).first {
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                stateController!.removeSpot(spot)
                                stateController!.removeSpotFromCD(appDelegate: appDelegate, spot: spot)
                            }
                            self.spotSelection = self.stateController!.spots
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
    
    private func groupByCountry() -> Dictionary<String, [Spot]> {
        return Dictionary(grouping: spotSelection!, by: { $0.country })
    }
    
    
    // MARK: Tableview delegate and datasource methods
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedSpots![(Array(groupedSpots!.keys.sorted())[section])]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let country      = Array(groupedSpots!.keys.sorted())[section]
        let countryName = (NSLocale.system.localizedString(forRegionCode: country) ?? "")
        return countryName
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedSpots!.keys.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell    = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SpotCell
        cell.detailTextLabel!.numberOfLines = 0
        
        let country = Array(groupedSpots!.keys.sorted())[indexPath.section]
        let spot    = groupedSpots![country]?[indexPath.row] ?? Constants.DEFAULT_SPOT
                                
        cell.textLabel?.text = (spot.name)
        
        var text : String = ""
        var tags : String = ""
        for tag in Constants.TAGS {
            tags += Helper.itemInBitmask(item: tag, bitmask: spot.tags) ? Helper.textToAdd(item: tag.0) : ""
        }
                
        if tags.count > 0 {
            tags.removeLast()
            text += tags
        }
       
        if text.count > 0 {
            let detailText :NSMutableAttributedString = NSMutableAttributedString(string: text)
            detailText.addAttributes([NSAttributedString.Key.foregroundColor: Constants.RED], range: NSRange(location: 0, length: tags.count))
        
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
        let country = Array(groupedSpots!.keys.sorted())[indexPath.section]
        if let spot = groupedSpots![country]?[indexPath.row] {
            stateController!.setSpot(spot)
            self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            performSegue(withIdentifier: "spotsViewToMapView", sender: self)
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let country = Array(groupedSpots!.keys.sorted())[indexPath.section]
            if let spot = groupedSpots![country]?[indexPath.row] {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    stateController!.removeSpot(spot)
                    stateController!.removeSpotFromCD(appDelegate: appDelegate, spot: spot)
                }
                spotSelection = stateController!.spots
                groupedSpots  = groupByCountry()
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
        if spotSelection![indexPath.row].name == Constants.DEFAULT_SPOT.name {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
    }
}


class SpotCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.tintColor = UIColor.systemTeal
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
