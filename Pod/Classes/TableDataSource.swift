//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit


public protocol TableCellConfigurator {
    
    associatedtype ManagedObjectType: NSManagedObject
    associatedtype CellType: UITableViewCell
   
    func configureCell( cell: CellType, withManagedObject managedObject: ManagedObjectType )
    
    func cellReuseIdentifierForManagedObject( managedObject: ManagedObjectType ) -> String
}

public class SimpleTableDataSource<ManagedObjectType:NSManagedObject,CellType:UITableViewCell>: NSObject, UITableViewDataSource {
    
    public private(set) var fetchedResultsController: NSFetchedResultsController
    public var systemHeaders: Bool = false
    public var tableIndex: Bool = false
    public var defaultSectionTitle: String?

    private var configurator: AnyTableCellConfigurator<ManagedObjectType,CellType>

    public init<U:TableCellConfigurator where U.ManagedObjectType == ManagedObjectType, U.CellType == CellType>( cellConfigurator: U, fetchedResultsController: NSFetchedResultsController ) {
        self.configurator = AnyTableCellConfigurator<ManagedObjectType,CellType>(cellConfigurator)
        self.fetchedResultsController = fetchedResultsController
        super.init()
    }
    
    public func sectionInfoForSection( sectionIndex: Int ) -> NSFetchedResultsSectionInfo? {
        
        if let sectionInfo = self.fetchedResultsController.sections?[sectionIndex] {
            return sectionInfo
        }
        
        return nil
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
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as? CellType else {
            fatalError("Incorrect table view cell type")
        }

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

extension TableCellConfigurator {
    
    // Helper method to create the UpdateCell function passed into a FetchedResultsCoordinator
    // The function fetches the visible cell at indexPath and if it exists configures it again
    // This is used to avoid the animation "flash" when you call tableView.reloadRowsAtIndexPaths
    public func makeUpdateVisibleCell( tableView: UITableView ) -> ( NSIndexPath, ManagedObjectType ) -> Void {
        return { indexPath, object in
            guard let cell = tableView.cellForRowAtIndexPath( indexPath ) else { return }
            
            guard let customCell = cell as? CellType else {
                fatalError("Incorrect table view cell type")
            }

            self.configureCell(customCell, withManagedObject: object )
        }
    }

}

// Type erased wrapper for TableCellConfigurator protocol
private struct AnyTableCellConfigurator<ManagedObjectType:NSManagedObject,CellType:UITableViewCell>: TableCellConfigurator {
    
    let _configureCell: (cell:CellType,withManagedObject:ManagedObjectType)->()
    let _cellReuseIdentifierForManagedObject: (managedObject: ManagedObjectType) -> String
    
    init<U:TableCellConfigurator where U.ManagedObjectType == ManagedObjectType, U.CellType == CellType>( _ configurator: U ) {
        _cellReuseIdentifierForManagedObject = configurator.cellReuseIdentifierForManagedObject
        _configureCell = configurator.configureCell
    }
    
    func configureCell(cell: CellType, withManagedObject managedObject: ManagedObjectType) {
        _configureCell(cell: cell, withManagedObject: managedObject)
    }
    
    func cellReuseIdentifierForManagedObject(managedObject: ManagedObjectType) -> String {
        return _cellReuseIdentifierForManagedObject(managedObject: managedObject)
    }
    
}

