//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit


public protocol TableCellConfigurator {
    
    typealias ManagedObjectType: NSManagedObject
   
    func configureCell( cell: UITableViewCell, withManagedObject managedObject: ManagedObjectType )
    
    func cellReuseIdentifierForManagedObject( managedObject: ManagedObjectType ) -> String
}


public class SimpleTableDataSource<ManagedObjectType:NSManagedObject>: NSObject, UITableViewDataSource {
    
    var fetchedResultsController: NSFetchedResultsController
    private var configurator: AnyTableCellConfigurator<ManagedObjectType>
    public var systemHeaders: Bool = false
    public var tableIndex: Bool = false
    public var defaultSectionTitle: String?
    
    public init<U:TableCellConfigurator where U.ManagedObjectType == ManagedObjectType>( cellConfigurator: U, fetchedResultsController: NSFetchedResultsController ) {
        self.configurator = AnyTableCellConfigurator<ManagedObjectType>(cellConfigurator)
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
        
        guard let object = fetchedResultsController.objectAtIndexPath(indexPath) as? ManagedObjectType else {
            fatalError("Incorrect object type")
        }
        
        let reuseIdentifier = configurator.cellReuseIdentifierForManagedObject(object)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        configurator.configureCell(cell, withManagedObject: object)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if fetchedResultsController.sectionNameKeyPath == nil &&
           defaultSectionTitle != nil {
                return defaultSectionTitle
        }
        return systemHeaders ? self.fetchedResultsController.sections?[section].name : nil
    }

    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return tableIndex ? fetchedResultsController.sectionIndexTitles : nil
    }

    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }

}

private struct AnyTableCellConfigurator<ManagedObjectType:NSManagedObject>: TableCellConfigurator {
    
    let _configureCell: (cell:UITableViewCell,withManagedObject:ManagedObjectType)->()
    let _cellReuseIdentifierForManagedObject: (managedObject: ManagedObjectType) -> String
    
    init<U:TableCellConfigurator where U.ManagedObjectType == ManagedObjectType>( _ configurator: U ) {
        _cellReuseIdentifierForManagedObject = configurator.cellReuseIdentifierForManagedObject
        _configureCell = configurator.configureCell
    }
    
    func configureCell(cell: UITableViewCell, withManagedObject managedObject: ManagedObjectType) {
        _configureCell(cell: cell, withManagedObject: managedObject)
    }
    
    func cellReuseIdentifierForManagedObject(managedObject: ManagedObjectType) -> String {
        return _cellReuseIdentifierForManagedObject(managedObject: managedObject)
    }
    
}