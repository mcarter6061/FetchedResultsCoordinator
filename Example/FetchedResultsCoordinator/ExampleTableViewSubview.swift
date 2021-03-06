//  Copyright © 2015 Mark Carter. All rights reserved.

import UIKit
import CoreData
import FetchedResultsCoordinator


class ExampleTableViewSubviewController: UIViewController, ExampleViewControllersWithFetchedResultController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    lazy var dataSource:FetchedTableDataSource<Item,UITableViewCell> = FetchedTableDataSource(cellConfigurator: self, fetchedResultsController: self.fetchedResultsController)
    
    lazy var frcCoordinator: FetchedResultsCoordinator<Item> = FetchedResultsCoordinator( coordinatee: self.tableView!, fetchedResultsController: self.fetchedResultsController, updateCell: self.makeUpdateVisibleCell(self.tableView) )
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dataSource.systemHeaders = true
        tableView.dataSource = dataSource
        
        frcCoordinator.loadData()
    }
}

// MARK: - TableCellConfigurator methods

extension ExampleTableViewSubviewController: TableCellConfigurator {
    
    typealias ObjectType = Item
    typealias CellType = UITableViewCell
    
    func configureCell( cell: UITableViewCell, withObject object: Item, atIndexPath indexPath: NSIndexPath ) {
        
        cell.textLabel!.text = object.name
    }
    
    func cellReuseIdentifierForObject( object: Item, atIndexPath indexPath: NSIndexPath ) -> String {
        return "ETVSCCellReuseIdentifier"
    }
}

// MARK: - Navigation

extension ExampleTableViewSubviewController: SegueHandlerType {
    
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
            destinationViewController.coordinator = frcCoordinator
            destinationViewController.tableDataSource = dataSource
            
        case .UnwindToDemoViewController: break
        }
    }
}

