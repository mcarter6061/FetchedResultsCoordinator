//  Copyright © 2015 Mark Carter. All rights reserved.

import UIKit
import CoreData
import FetchedResultsCoordinator


class ExampleTableViewController: UITableViewController, TableCellConfigurator, ExampleViewControllersWithFetchedResultController {

    var fetchedResultsController: NSFetchedResultsController!
    var frcCoordinator: FetchedResultsCoordinator?

    var tableViewDataSource: SimpleTableDataSource?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if tableViewDataSource == nil {
            tableViewDataSource = SimpleTableDataSource( cellConfigurator: self, fetchedResultsController: fetchedResultsController )
            tableViewDataSource?.systemHeaders = true
        }
        tableView.dataSource = tableViewDataSource
        
        if frcCoordinator == nil {
            frcCoordinator = FetchedResultsCoordinator( tableView: self.tableView!, fetchedResultsController: self.fetchedResultsController, cellConfigurator: self )
            frcCoordinator?.loadData()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableCellConfigurator methods
    
    func configureCell(cell: UITableViewCell, withManagedObject managedObject: NSManagedObject) {
        guard let managedObject = managedObject as? Item else { return }
        
        cell.textLabel!.text = managedObject.name
    }
    
    func cellReuseIdentifierForManagedObject(managedObject: NSManagedObject) -> String {
        return "ETVCCellReuseIdentifier"
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TableSettingsSegue" {
            if  let navController = segue.destinationViewController as? UINavigationController,
                let destinationViewController = navController.topViewController as? TableSettingsViewController {
                destinationViewController.fetchedResultsController = fetchedResultsController!
                destinationViewController.coordinator = frcCoordinator!
                destinationViewController.tableDataSource = tableViewDataSource!
            }
        }
    }
    
}
