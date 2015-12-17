//  Copyright © 2015 Mark Carter. All rights reserved.

import UIKit
import CoreData
import FetchedResultsCoordinator


class ExampleTableViewSubviewController: UIViewController, TableCellConfigurator, ExampleViewControllersWithFetchedResultController {

    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController!
    var frcCoordinator: FetchedResultsCoordinator?
    var dataSource: SimpleTableDataSource?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if dataSource == nil {
            dataSource = SimpleTableDataSource(configurator: self, fetchedResultsController: fetchedResultsController)
            dataSource?.systemHeaders = true

            tableView.dataSource = dataSource
        }

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
    
    func configureCell(cell: UITableViewCell, withObject: NSManagedObject) {
        if let withObject = withObject as? Item {
            cell.textLabel!.text = withObject.name
        }
    }
    
    func cellReuseIdentifierForObject(object: NSManagedObject) -> String {
        return "ETVSCCellReuseIdentifier"
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TableSettingsSegue" {
            if  let navController = segue.destinationViewController as? UINavigationController,
                let destinationViewController = navController.topViewController as? TableSettingsViewController {
                    destinationViewController.fetchedResultsController = fetchedResultsController
                    destinationViewController.coordinator = frcCoordinator
                    destinationViewController.tableDataSource = dataSource!
            }
        }
    }

}
