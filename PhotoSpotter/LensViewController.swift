//
//  LensViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 04.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import UIKit

class LensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FoVController {
    var stateController    : StateController?
    var sentViaSegueObject : FoVController?
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "lensCell"
    
    @IBOutlet weak var mapButton     : UIBarButtonItem!
    @IBOutlet weak var camerasButton : UIBarButtonItem!
    @IBOutlet weak var lensesButton  : UIBarButtonItem!
    @IBOutlet weak var viewsButton   : UIBarButtonItem!
    @IBOutlet weak var spotsButton   : UIBarButtonItem!
    
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
        
        let hideDefaultLens : Bool = stateController!.lenses.count > 1
        self.lensSelection = hideDefaultLens ? (self.stateController!.lenses.filter { $0.name != Constants.DEFAULT_LENS.name &&
                                                                                      $0.sensorFormat == self.stateController!.view.camera.sensorFormat }).sorted(by: { $0.isPrime && !$1.isPrime }) :
                                                self.stateController!.lenses.filter { $0.sensorFormat == self.stateController!.view.camera.sensorFormat }.sorted(by: { $0.isPrime && !$1.isPrime })
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(LensCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
        
        let lensSelectorTextAttr         = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let lensSelectorTextAttrSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        lensSelector.setTitleTextAttributes(lensSelectorTextAttr, for: .normal)
        lensSelector.setTitleTextAttributes(lensSelectorTextAttrSelected, for: .selected)
        
        //let lensIndex : IndexPath = IndexPath(row: (lensSelection!.firstIndex(of: stateController!.view.lens) ?? 0), section: 0)
        //tableView.selectRow(at: lensIndex, animated: true, scrollPosition: .none)
        //tableView.cellForRow(at: lensIndex)?.accessoryType = .checkmark
        tableView.isEditing = false        
    }
    
    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {        
        performSegue(withIdentifier: "lensesViewToMapView", sender: self)
    }
    @IBAction func camerasButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "lensesViewToCamerasView", sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "lensesViewToViewsView", sender: self)
    }
    @IBAction func spotsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "lensesViewToSpotsView", sender: self)
    }
    
    @IBAction func addLensButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "lensesViewToLensDetailsView", sender: self)
    }
    
    @IBAction func editLensButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func done(segue:UIStoryboardSegue) {
        let lensDetailVC = segue.source as! LensDetailViewController
        let lens = Lens(name: lensDetailVC.lensName, minFocalLength: lensDetailVC.minFocalLength, maxFocalLength: lensDetailVC.maxFocalLength, minAperture: lensDetailVC.minAperture, maxAperture:          lensDetailVC.maxAperture, sensorFormat: lensDetailVC.sensorFormat)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            stateController!.addLens(lens)
            stateController!.addLensToCD(appDelegate: appDelegate, lens: lens)
        }
        
        let hideDefaultLens : Bool = stateController!.lenses.count > 1
        
        self.lensSelection = hideDefaultLens ? (self.stateController!.lenses.filter { $0.name != Constants.DEFAULT_LENS.name &&
                                                                                      $0.sensorFormat == self.stateController!.view.camera.sensorFormat }).sorted(by: { $0.isPrime && !$1.isPrime }) :
                                                self.stateController!.lenses.filter { $0.sensorFormat == self.stateController!.view.camera.sensorFormat }.sorted(by: { $0.isPrime && !$1.isPrime })
        //lensSelector.selectedSegmentIndex = 0
        tableView.reloadData()
        
        let cells = self.tableView.visibleCells as! Array<LensCell>
        for cell in cells {
            cell.accessoryType = .none
        }
        
        let lensIndex : IndexPath = IndexPath(row: (lensSelection!.firstIndex(of: lens) ?? 0), section: 0)
        tableView.selectRow(at: lensIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: lensIndex)?.accessoryType = .checkmark
        
        stateController!.view.lens        = lens
        stateController!.view.focalLength = lens.minFocalLength
        stateController!.view.aperture    = lens.minAperture
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
       
    }
    
    @IBAction func didSelectLens(_ sender: Any) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
        let hideDefaultLens : Bool = stateController!.lenses.count > 1
        
        switch lensSelector.selectedSegmentIndex {
            case 0 :  // All lenses
                if hideDefaultLens {
                    lensSelection = (stateController!.lenses.filter { $0.name != Constants.DEFAULT_LENS.name &&
                                                                      $0.sensorFormat == self.stateController!.view.camera.sensorFormat
                    }).sorted(by: { $0.isPrime && !$1.isPrime })
                } else {
                    lensSelection = stateController!.lenses.filter{ $0.sensorFormat == self.stateController!.view.camera.sensorFormat }.sorted(by: { $0.isPrime && !$1.isPrime })
                }
                break;
            case 1 : // Prime lenses
                if stateController!.lenses.filter({ $0.isPrime }).count > 0 {
                    lensSelection = stateController!.lenses.filter { $0.isPrime && $0.sensorFormat == self.stateController!.view.camera.sensorFormat }
                } else {
                    lensSelection = []
                }
                break;
            case 2 :  // Zoom lenses
                if stateController!.lenses.filter({ !$0.isPrime }).count > 0 {
                    if hideDefaultLens {
                        lensSelection = stateController!.lenses.filter { !$0.isPrime &&
                                                                          $0.name != Constants.DEFAULT_LENS.name &&
                                                                          $0.sensorFormat == self.stateController!.view.camera.sensorFormat
                        }
                    } else {
                        lensSelection = stateController!.lenses.filter { !$0.isPrime && $0.sensorFormat == self.stateController!.view.camera.sensorFormat }
                    }
                } else {
                    lensSelection = []
                }
                break;
            default:
                if hideDefaultLens {
                    lensSelection = stateController!.lenses.filter { $0.name != Constants.DEFAULT_LENS.name &&
                                                                     $0.sensorFormat == self.stateController!.view.camera.sensorFormat
                    }
                } else {
                    lensSelection = stateController!.lenses.filter { $0.sensorFormat == self.stateController!.view.camera.sensorFormat }
                }
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
                        let appDelegate  = UIApplication.shared.delegate as? AppDelegate ?? nil
                        let selectedCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
                        if let lens = self.stateController!.lenses.filter({ $0.name == selectedCell.textLabel?.text }).first {
                            if let filteredViews = self.stateController?.views.filter({ $0.lens.name == lens.name }) {
                                for view in filteredViews {
                                    if nil != appDelegate {
                                        self.stateController!.removeView(view)
                                        self.stateController!.removeViewFromCD(appDelegate: appDelegate!, view: view)
                                    }
                                }
                            }
                            self.stateController!.removeLens(lens)
                            self.stateController!.removeLensFromCD(appDelegate: appDelegate!, lens: lens)
                        }
                        let hideDefaultLens : Bool = self.stateController!.lenses.count > 1
                        self.lensSelection = hideDefaultLens ? (self.stateController!.lenses.filter { $0.name != Constants.DEFAULT_LENS.name &&
                                                                                                      $0.sensorFormat == self.stateController!.view.camera.sensorFormat }).sorted(by: { $0.isPrime && !$1.isPrime }) :
                                                                self.stateController!.lenses.filter { $0.sensorFormat == self.stateController!.view.camera.sensorFormat }.sorted(by: { $0.isPrime && !$1.isPrime })
                        tableView.reloadData()
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
            cell.textLabel?.textColor = Constants.BLUE
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
        stateController!.view.aperture                          = lens.minAperture
        stateController!.lens                                   = lens
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        performSegue(withIdentifier: "lensesViewToMapView", sender: self)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Warning", message: "Views using this lens will be deleted too.", preferredStyle: .alert)
            let deleteAction    = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                //self.tableView.deleteRows(at: [indexPath], with: .fade)
                let appDelegate  = UIApplication.shared.delegate as? AppDelegate ?? nil
                let selectedCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
                if let lens = self.stateController!.lenses.filter({ $0.name == selectedCell.textLabel?.text }).first {
                    if let filteredViews = self.stateController?.views.filter({ $0.lens.name == lens.name }) {
                        for view in filteredViews {
                            if nil != appDelegate {
                                self.stateController!.removeView(view)
                                self.stateController!.removeViewFromCD(appDelegate: appDelegate!, view: view)
                            }
                        }
                    }
                    self.stateController!.removeLens(lens)
                    self.stateController!.removeLensFromCD(appDelegate: appDelegate!, lens: lens)
                }
                let hideDefaultLens : Bool = self.stateController!.lenses.count > 1
                self.lensSelection = hideDefaultLens ? (self.stateController!.lenses.filter { $0.name != Constants.DEFAULT_LENS.name &&
                                                                                              $0.sensorFormat == self.stateController!.view.camera.sensorFormat }).sorted(by: { $0.isPrime && !$1.isPrime }) :
                                                        self.stateController!.lenses.filter { $0.sensorFormat == self.stateController!.view.camera.sensorFormat }.sorted(by: { $0.isPrime && !$1.isPrime })
                tableView.reloadData()
            })
            alertController.addAction(deleteAction)

            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)            
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
        //if stateController!.lenses[indexPath.row].name == Constants.DEFAULT_LENS.name {
        if lensSelection![indexPath.row].name == Constants.DEFAULT_LENS.name {
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
