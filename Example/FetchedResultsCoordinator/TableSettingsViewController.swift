//  Copyright © 2015 Mark Carter. All rights reserved.

import UIKit
import CoreData
import FetchedResultsCoordinator

protocol SettingsConfigurable {
    var systemHeaders: Bool {get set}
    var tableIndex: Bool {get set}
    var defaultSectionTitle: String? {get set}
}

class TableSettingsViewController: UITableViewController {

    var fetchedResultsController: NSFetchedResultsController!
    var tableDataSource: SettingsConfigurable!
    var coordinator: FetchedResultsCoordinator<Item>!
    
    @IBOutlet weak var showSystemHeadersSwitch: UISwitch!
    @IBOutlet weak var showTableIndexSwitch: UISwitch!
    @IBOutlet weak var tableCoordinatorPausedSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showSystemHeadersSwitch.setOn(tableDataSource.systemHeaders, animated: false)
        showTableIndexSwitch.setOn(tableDataSource.tableIndex, animated: false)
        tableCoordinatorPausedSwitch.setOn(coordinator.paused, animated: false)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showSystemHeadersChanged(sender: UISwitch) {
        
        guard tableDataSource.systemHeaders != sender.on else {
            return // already set
        }
        
        tableDataSource.systemHeaders = sender.on
        coordinator.loadData()
    }

    @IBAction func showTableIndexChanged(sender: UISwitch) {
        tableDataSource.tableIndex = sender.on
        coordinator.loadData()
    }

    @IBAction func tableCoordinatorPausedChanged(sender: UISwitch) {
        coordinator.paused = sender.on
    }

    @IBAction func doneTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}


// Adding SettingsConfigurable conformance to SimpleTableDataSource so we can inject specialized SimpleTableDataSources instances to the TableSettingsViewController without having to know their specialization ( and still be able to set their systemHeaders, tableIndex, and defaultSectionTitle )
extension SimpleTableDataSource: SettingsConfigurable {}