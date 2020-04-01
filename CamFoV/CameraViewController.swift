//
//  CameraViewController.swift
//  CamFoV
//
//  Created by Gerrit Grunwald on 01.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation
import UIKit

class CameraViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Data model: These strings will be the data for the table view cells
    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]

    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"

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

        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapVC = storyboard.instantiateViewController(identifier: "MapViewController")
        show(mapVC, sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
    
    }
    @IBAction func viewsButtonPressed(_ sender: Any) {
    
    }
    
    @IBAction func editCameraButtonPressed(_ sender: Any) {
        
    }
    @IBAction func addCameraButtonPressed(_ sender: Any) {
        
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.animals.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!

        // set the text from the data model
        cell.textLabel?.text = self.animals[indexPath.row]

        return cell
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
