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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate      = UIApplication.shared.delegate as! AppDelegate
        self.stateController = appDelegate.stateController
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.register(ViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        // (optional) include this line if you want to remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()

        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate   = self
        tableView.dataSource = self
        
        let viewIndex : IndexPath = IndexPath(row: (stateController!.views.firstIndex(of: stateController!.view) ?? 0), section: 0)
        tableView.selectRow(at: viewIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: viewIndex)?.accessoryType = .checkmark
        tableView.isEditing = false
    }
    
    
    // MARK: Event handling
    @IBAction func mapButtonPressed(_ sender: Any) {
        stateController!.store()
        performSegue(withIdentifier: "viewsViewToMapView", sender: self)
    }
    @IBAction func camerasButtonPressed(_ sender: Any) {
        stateController!.store()
        performSegue(withIdentifier: "viewsViewToCamerasView", sender: self)
    }
    @IBAction func lensesButtonPressed(_ sender: Any) {
        stateController!.store()
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
        let view = View(name: viewDetailVC.name, description: viewDetailVC.descr, cameraPoint: stateController!.view.cameraPoint, motifPoint: stateController!.view.motifPoint, camera: stateController!.view.camera, lens: stateController!.view.lens, focalLength: stateController!.view.focalLength, aperture: stateController!.view.aperture, orientation: stateController!.view.orientation)
        stateController?.addView(view)
        tableView.reloadData()
        
        let cells = self.tableView.visibleCells as! Array<ViewCell>
        for cell in cells {
            cell.accessoryType = .none
        }
        
        let viewIndex : IndexPath = IndexPath(row: (stateController!.views.firstIndex(of: view) ?? 0), section: 0)
        tableView.selectRow(at: viewIndex, animated: true, scrollPosition: .none)
        tableView.cellForRow(at: viewIndex)?.accessoryType = .checkmark
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
       
    }
    
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateController!.views.count
    }

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                   = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ViewCell
        let view : View            = stateController!.views[indexPath.item]
        cell.textLabel?.text       = view.name
        cell.detailTextLabel?.text = view.description
        return cell
    }
    
    // method to set all table view cells to height of 100
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = stateController!.views[indexPath.item]
        stateController!.setView(view)
        
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stateController!.removeView(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
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
