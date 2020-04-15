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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Helper.setNavBarTitle(navBar: navBar)
        
        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(CameraCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
                
        let cameraIndex : IndexPath = IndexPath(row: (stateController!.cameras.firstIndex(of: stateController!.view.camera) ?? 0), section: 0)
        tableView.selectRow(at: cameraIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: cameraIndex)?.accessoryType = .checkmark
        tableView.isEditing = false
    }

    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {
        stateController!.store()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC      = storyboard.instantiateViewController(identifier: "MapViewController")
        show(mapVC, sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
        stateController!.store()
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lensVC   = storyboard.instantiateViewController(identifier: "LensViewController")
        show(lensVC, sender: self)
        */
        performSegue(withIdentifier: "camerasViewToLensesView", sender: self)
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
        stateController!.store()
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
        stateController?.addCamera(camera)
        tableView.reloadData()
        
        let cells = self.tableView.visibleCells as! Array<CameraCell>
        for cell in cells {
            cell.accessoryType = .none
        }
        
        let cameraIndex : IndexPath = IndexPath(row: (stateController!.cameras.firstIndex(of: camera) ?? 0), section: 0)
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
        return stateController!.cameras.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                   = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CameraCell
        let camera : Camera        = stateController!.cameras[indexPath.item]
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
        let camera = stateController!.cameras[indexPath.item]
        stateController!.view.camera = camera
        
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        /*
        let alertController = UIAlertController(title: camera.name, message: " is in da house!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        */
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stateController!.removeCamera(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0 
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
