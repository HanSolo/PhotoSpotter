//
//  LensViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 04.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import UIKit

class LensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FoVController {
    var stateController : StateController?
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "lensCell"
    
    @IBOutlet weak var mapButton     : UIBarButtonItem!
    @IBOutlet weak var camerasButton : UIBarButtonItem!
    @IBOutlet weak var lensesButton  : UIBarButtonItem!
    @IBOutlet weak var viewsButton   : UIBarButtonItem!
    
    @IBOutlet weak var tableView     : UITableView!
    @IBOutlet weak var backButton    : UIBarButtonItem!
    @IBOutlet weak var addLensButton : UIBarButtonItem!
    
    @IBOutlet weak var navBar        : UINavigationBar!
    @IBOutlet weak var lensSelector  : UISegmentedControl!
    
    var lensSelection : [Lens]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.setNavBarTitle(navBar: navBar)

        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController

        if var textAttributes = navigationController?.navigationBar.titleTextAttributes {
            textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.lightText
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        
        lensSelection = stateController!.lenses
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(LensCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
        
        let lensSelectorTextAttr         = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let lensSelectorTextAttrSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        lensSelector.setTitleTextAttributes(lensSelectorTextAttr, for: .normal)
        lensSelector.setTitleTextAttributes(lensSelectorTextAttrSelected, for: .selected)
        
        let lensIndex : IndexPath = IndexPath(row: (lensSelection!.firstIndex(of: stateController!.view.lens) ?? 0), section: 0)
        tableView.selectRow(at: lensIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: lensIndex)?.accessoryType = .checkmark
        tableView.isEditing = false
        tableView.remembersLastFocusedIndexPath = false
    }
    
    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {
        stateController!.store()
        performSegue(withIdentifier: "lensesViewToMapView", sender: self)
    }
    @IBAction func camerasButtonPressed(_ sender: Any) {
        stateController!.store()
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cameraVC   = storyboard.instantiateViewController(identifier: "CameraViewController")
        show(cameraVC, sender: self)
        */
        performSegue(withIdentifier: "lensesViewToCamerasView", sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
        stateController!.store()
        performSegue(withIdentifier: "lensesViewToViewsView", sender: self)
    }
    
    @IBAction func addLensButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "lensesViewToLensDetailsView", sender: self)
    }
    
    @IBAction func editLensButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func done(segue:UIStoryboardSegue) {
        let lensDetailVC = segue.source as! LensDetailViewController
        let lens = Lens(name: lensDetailVC.lensName, minFocalLength: lensDetailVC.minFocalLength, maxFocalLength: lensDetailVC.maxFocalLength, minAperture: lensDetailVC.minAperture, maxAperture: lensDetailVC.maxAperture)
        stateController?.addLens(lens)
        lensSelection = stateController!.lenses
        lensSelector.selectedSegmentIndex = 0
        tableView.reloadData()
        
        let cells = self.tableView.visibleCells as! Array<LensCell>
        for cell in cells {
            cell.accessoryType = .none
        }
        
        let lensIndex : IndexPath = IndexPath(row: (lensSelection!.firstIndex(of: lens) ?? 0), section: 0)
        tableView.selectRow(at: lensIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: lensIndex)?.accessoryType = .checkmark
        
        stateController!.view.lens = lens
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
       
    }
    
    @IBAction func didSelectLens(_ sender: Any) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        switch lensSelector.selectedSegmentIndex {
            case 0 :  // All lenses
                lensSelection = stateController!.lenses
                break;
            case 1 : // Prime lenses
                if stateController!.lenses.filter({ $0.isPrime }).count > 0 {
                    lensSelection = stateController!.lenses.filter { $0.isPrime }
                }
                break;
            case 2 :  // Zoom lenses
                if stateController!.lenses.filter({ !$0.isPrime }).count > 0 {
                    lensSelection = stateController!.lenses.filter { !$0.isPrime }
                }
                break;
            default:
                lensSelection = stateController!.lenses
                break;
        }
        tableView.reloadData()
    }
    
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        #if targetEnvironment(macCatalyst)
            guard let key = presses.first?.key else { return }
            switch key.keyCode {
                case .keyboardDeleteOrBackspace:
                    if let indexPath = tableView.indexPathForSelectedRow {
                        stateController!.removeView(indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        stateController!.storeViews()
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
        return lensSelection!.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! LensCell
        let lens : Lens      = lensSelection![indexPath.item]
        cell.textLabel?.text = lens.name
        if lens.isPrime {
            cell.textLabel?.textColor = Constants.YELLOW
        } else {
            cell.textLabel?.textColor = UIColor.lightText
        }
        cell.detailTextLabel?.text = lens.description()
        
        return cell
    }
    
    // method to set all table view cells to height of 100
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lens = lensSelection![indexPath.item]
        stateController!.view.lens                              = lens
        stateController!.view.focalLength                       = lens.minFocalLength
        stateController!.view.aperture                          = lens.minFocalLength
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stateController?.removeLens(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
        if stateController!.lenses[indexPath.row].name == Constants.DEFAULT_LENS.name {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
    }
}


class LensCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.tintColor = UIColor.systemTeal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
