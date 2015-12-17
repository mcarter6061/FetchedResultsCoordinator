//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit


@objc public protocol TableCellConfigurator {
   
    func configureCell( cell: UITableViewCell, withObject: NSManagedObject )
    
    func cellReuseIdentifierForObject( object: NSManagedObject ) -> String
}


public class SimpleTableDataSource: NSObject, UITableViewDataSource {
    
    var fetchedResultsController: NSFetchedResultsController
    var configurator: TableCellConfigurator
    public var systemHeaders: Bool = false
    public var tableIndex: Bool = false
    
    public init( configurator: TableCellConfigurator, fetchedResultsController: NSFetchedResultsController ) {
        self.configurator = configurator
        self.fetchedResultsController = fetchedResultsController
        super.init()
    }

    // MARK: - UITableViewDataSource methods

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sectionInfo = fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        
        let reuseIdentifier = configurator.cellReuseIdentifierForObject(object)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        configurator.configureCell(cell, withObject: object)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return systemHeaders ? self.fetchedResultsController.sections?[section].name : nil
    }

    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return tableIndex ? fetchedResultsController.sectionIndexTitles : nil
    }

    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }

}

