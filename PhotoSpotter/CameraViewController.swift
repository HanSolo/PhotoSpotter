//
//  CameraViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 01.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

class CameraViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FoVController {
    var stateController : StateController?
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cameraCell"

    // Toolbar items
    @IBOutlet weak var mapButton        : UIBarButtonItem!
    @IBOutlet weak var camerasButton    : UIBarButtonItem!
    @IBOutlet weak var lensesButton     : UIBarButtonItem!
    @IBOutlet weak var viewsButton      : UIBarButtonItem!
    
    // View items
    @IBOutlet weak var tableView        : UITableView!
    @IBOutlet weak var editCameraButton : UIButton!
    @IBOutlet weak var addCameraButton  : UIButton!
        
    @IBOutlet weak var navBar: UINavigationBar!
    
    var cameraSelection : [Camera]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Helper.setNavBarTitle(navBar: navBar)
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        let hideDefaultCamera : Bool = stateController!.cameras.count > 1
        cameraSelection = hideDefaultCamera ? stateController!.cameras.filter { $0.name != Constants.DEFAULT_CAMERA.name } : stateController!.cameras
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(CameraCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
        
        for indexPath in self.tableView.indexPathsForSelectedRows ?? [] {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
                
        let cameraIndex : IndexPath = IndexPath(row: (cameraSelection!.firstIndex(of: stateController!.view.camera) ?? 0), section: 0)
        tableView.selectRow(at: cameraIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: cameraIndex)?.accessoryType = .checkmark
        tableView.isEditing = false
    }

    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC      = storyboard.instantiateViewController(identifier: "MapViewController")
        show(mapVC, sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "camerasViewToLensesView", sender: self)
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "camerasViewToViewsView", sender: self)
    }
    
    @IBAction func editCameraButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func addCameraButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "camerasViewToCameraDetailsView", sender: self)
    }
    
    
    
    @IBAction func done(segue:UIStoryboardSegue) {
        let cameraDetailVC = segue.source as! CameraDetailViewController
        let camera = Camera(name: cameraDetailVC.name, sensorFormat: cameraDetailVC.sensorFormat)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            stateController!.addCamera(camera)
            stateController!.addCameraToCD(appDelegate: appDelegate, camera: camera)
        }
        
        let hideDefaultCamera : Bool = stateController!.cameras.count > 1
        cameraSelection = hideDefaultCamera ? stateController!.cameras.filter { $0.name != Constants.DEFAULT_CAMERA.name } : stateController!.cameras
        
        tableView.reloadData()
        
        let cells = self.tableView.visibleCells as! Array<CameraCell>
        for cell in cells {
            cell.accessoryType = .none
        }
        
        let cameraIndex : IndexPath = IndexPath(row: (cameraSelection!.firstIndex(of: camera) ?? 0), section: 0)
        tableView.selectRow(at: cameraIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: cameraIndex)?.accessoryType = .checkmark
        
        stateController?.view.camera = camera
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
       
    }
    
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        #if targetEnvironment(macCatalyst)
            guard let key = presses.first?.key else { return }
            switch key.keyCode {
                case .keyboardDeleteOrBackspace:
                    if let indexPath = tableView.indexPathForSelectedRow {
                        let appDelegate  = UIApplication.shared.delegate as? AppDelegate ?? nil
                        let selectedCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
                        if let camera = self.stateController!.cameras.filter({ $0.name == selectedCell.textLabel?.text }).first {
                            if let filteredViews = self.stateController?.views.filter({ $0.camera.name == camera.name }) {
                                for view in filteredViews {
                                    if nil != appDelegate {
                                        self.stateController!.removeView(view)
                                        self.stateController!.removeViewFromCD(appDelegate: appDelegate!, view: view)
                                    }
                                }
                            }
                            self.stateController!.removeCamera(camera)
                            self.stateController!.removeCameraFromCD(appDelegate: appDelegate!, camera: camera)
                        }
                        let hideDefaultCamera : Bool = stateController!.cameras.count > 1
                        cameraSelection = hideDefaultCamera ? stateController!.cameras.filter { $0.name != Constants.DEFAULT_CAMERA.name } : stateController!.cameras
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
        return cameraSelection!.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                   = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CameraCell
        let camera : Camera        = cameraSelection![indexPath.item]
        cell.textLabel?.text       = camera.name
        cell.detailTextLabel?.text = camera.sensorFormat.description
        return cell
    }
    
    // method to set all table view cells to height of 100
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let camera = cameraSelection![indexPath.item]
        stateController!.view.camera = camera
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Warning", message: "Views using this camera will be deleted too.", preferredStyle: .alert)
            let deleteAction    = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                //self.tableView.deleteRows(at: [indexPath], with: .fade)
                let appDelegate  = UIApplication.shared.delegate as? AppDelegate ?? nil
                let selectedCell = tableView.cellForRow(at: indexPath)! as! CameraCell
                if let camera = self.stateController!.cameras.filter({ $0.name == selectedCell.textLabel?.text }).first {
                    if let filteredViews = self.stateController?.views.filter({ $0.camera.name == camera.name }) {
                        for view in filteredViews {
                            if nil != appDelegate {
                                self.stateController!.removeView(view)
                                self.stateController!.removeViewFromCD(appDelegate: appDelegate!, view: view)
                            }
                        }
                    }
                    self.stateController!.removeCamera(camera)
                    self.stateController!.removeCameraFromCD(appDelegate: appDelegate!, camera: camera)
                }
                let hideDefaultCamera : Bool = self.stateController!.cameras.count > 1
                self.cameraSelection = hideDefaultCamera ? self.stateController!.cameras.filter { $0.name != Constants.DEFAULT_CAMERA.name } : self.stateController!.cameras
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
        if cameraSelection![indexPath.row].name == Constants.DEFAULT_CAMERA.name {
            return UITableViewCell.EditingStyle.none
        } else {
            return UITableViewCell.EditingStyle.delete
        }
    }
}


class CameraCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.tintColor = UIColor.systemTeal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
