//  Copyright © 2015 Mark Carter. All rights reserved.

import UIKit
import CoreData
import FetchedResultsCoordinator

// Using a custom class here to show how TableCellConfigurator conformance with a UITableViewCell subclass.
class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

class ExampleTableViewController: UITableViewController, ExampleViewControllersWithFetchedResultController {

    var fetchedResultsController: NSFetchedResultsController!
    var frcCoordinator: FetchedResultsCoordinator<Item>?
    var dataSource: FetchedTableDataSource<Item,CustomTableViewCell>?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if dataSource == nil {
            dataSource = FetchedTableDataSource( cellConfigurator: self, fetchedResultsController: fetchedResultsController )
            dataSource?.systemHeaders = true
        }
        tableView.dataSource = dataSource
        
        if frcCoordinator == nil {
            frcCoordinator = FetchedResultsCoordinator( coordinatee: tableView, fetchedResultsController: fetchedResultsController, updateCell: makeUpdateVisibleCell(tableView) )
            frcCoordinator?.loadData()
        }

    }
}

// MARK: - TableCellConfigurator methods

extension ExampleTableViewController: TableCellConfigurator {
    
    func configureCell(cell: CustomTableViewCell, withObject object: Item, atIndexPath indexPath: NSIndexPath) {

        cell.titleLabel!.text = object.name
    }
    
    func cellReuseIdentifierForObject(object: Item, atIndexPath indexPath: NSIndexPath) -> String {
        return "ETVCCellReuseIdentifier"
    }
}

// MARK: - Navigation

extension ExampleTableViewController: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case TableSettingsSegue
        case UnwindToDemoViewController
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segueIdentifierForSegue(segue) {
        case .TableSettingsSegue:
            guard let navController = segue.destinationViewController as? UINavigationController,
                let destinationViewController = navController.topViewController as? TableSettingsViewController else { fatalError("Unexpected view controller hierarchy") }
            
            destinationViewController.fetchedResultsController = fetchedResultsController!
            destinationViewController.coordinator = frcCoordinator!
            destinationViewController.tableDataSource = dataSource!

        case .UnwindToDemoViewController: break
        }
    }
}

