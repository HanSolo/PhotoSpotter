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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC      = storyboard.instantiateViewController(identifier: "MapViewController")
        show(mapVC, sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
    
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
    
    }
    
    @IBAction func editCameraButtonPressed(_ sender: Any) {
        
    }
    @IBAction func addCameraButtonPressed(_ sender: Any) {
        // Show view controller that saves the current
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController!.cameras.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                   = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CameraCell
        let camera : Camera        = stateController!.cameras[indexPath.item]
        cell.textLabel?.text       = camera.name
        cell.detailTextLabel?.text = "[\(camera.sensorFormat.description)]"
        return cell
    }
    
    // method to set all table view cells to height of 100
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let camera = stateController!.cameras[indexPath.item]
        print("You tapped camera \(camera.name).")
        stateController!.view.camera = camera
        
        let alertController = UIAlertController(title: camera.name, message: " is in da house!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}


class CameraCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
