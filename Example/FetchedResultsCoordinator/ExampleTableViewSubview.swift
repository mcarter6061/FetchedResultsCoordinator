//  Copyright © 2015 Mark Carter. All rights reserved.

import UIKit
import CoreData
import FetchedResultsCoordinator


class ExampleTableViewSubviewController: UIViewController, ExampleViewControllersWithFetchedResultController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController!
    lazy var dataSource:SimpleTableDataSource<Item> = SimpleTableDataSource(cellConfigurator: self, fetchedResultsController: self.fetchedResultsController)
    lazy var frcCoordinator: FetchedResultsCoordinator<Item> = FetchedResultsCoordinator( coordinatee: self.tableView!, fetchedResultsController: self.fetchedResultsController, updateCell: self.makeUpdateVisibleCell(self.tableView) )
    
    func reconfigureCell( indexPath: NSIndexPath, object: Item ) {
        guard let cell = tableView.cellForRowAtIndexPath( indexPath ) else { return }
        configureCell(cell, withManagedObject: object )
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dataSource.systemHeaders = true
        tableView.dataSource = dataSource
        
        frcCoordinator.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "TableSettingsSegue" {
            if  let navController = segue.destinationViewController as? UINavigationController,
                let destinationViewController = navController.topViewController as? TableSettingsViewController {
                    destinationViewController.fetchedResultsController = fetchedResultsController
                    destinationViewController.coordinator = frcCoordinator
                    destinationViewController.tableDataSource = dataSource
            }
        }
    }
}

extension ExampleTableViewSubviewController: TableCellConfigurator {
    
    typealias ManagedObjectType = Item
    
    func configureCell(cell: UITableViewCell, withManagedObject managedObject: Item) {
        
        cell.textLabel!.text = managedObject.name
    }
    
    func cellReuseIdentifierForManagedObject(managedObject: Item) -> String {
        return "ETVSCCellReuseIdentifier"
    }
}
