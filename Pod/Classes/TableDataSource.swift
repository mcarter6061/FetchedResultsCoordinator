//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit


public protocol TableCellConfigurator {
    
    associatedtype ObjectType
    associatedtype CellType: UITableViewCell
   
    func configureCell( cell: CellType, withObject object: ObjectType, atIndexPath indexPath: NSIndexPath )
    
    func cellReuseIdentifierForObject( object: ObjectType, atIndexPath indexPath: NSIndexPath ) -> String
}


public class ListTableDataSource<ObjectType:Equatable,CellType:UITableViewCell>: NSObject, UITableViewDataSource {

    public private(set) var data: [ObjectType]
    public var systemHeaders: Bool = false
    public var tableIndex: Bool = false
    public var defaultSectionTitle: String?
    
    private var configurator: AnyTableCellConfigurator<ObjectType,CellType>

    public init<U:TableCellConfigurator where U.ObjectType == ObjectType, U.CellType == CellType>( cellConfigurator: U, data: [ObjectType] ) {
        self.configurator = AnyTableCellConfigurator(cellConfigurator)
        self.data = data
        super.init()
    }
    
    // MARK: - UITableViewDataSource methods
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let object = data[indexPath.row]
        
        let reuseIdentifier = configurator.cellReuseIdentifierForObject(object, atIndexPath: indexPath)
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as? CellType else {
            fatalError("Incorrect table view cell type")
        }
        
        configurator.configureCell(cell, withObject: object, atIndexPath: indexPath)
        
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return defaultSectionTitle
    }
    
}


public class FetchedTableDataSource<ManagedObjectType:NSManagedObject,CellType:UITableViewCell>: NSObject, UITableViewDataSource {
    
    public private(set) var fetchedResultsController: NSFetchedResultsController
    public var systemHeaders: Bool = false
    public var tableIndex: Bool = false
    public var defaultSectionTitle: String?

    private var configurator: AnyTableCellConfigurator<ManagedObjectType,CellType>

    public init<U:TableCellConfigurator where U.ObjectType == ManagedObjectType, U.CellType == CellType>( cellConfigurator: U, fetchedResultsController: NSFetchedResultsController ) {
        self.configurator = AnyTableCellConfigurator(cellConfigurator)
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
        
        let reuseIdentifier = configurator.cellReuseIdentifierForObject(object, atIndexPath: indexPath)
        
        guard let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as? CellType else {
            fatalError("Incorrect table view cell type")
        }

        configurator.configureCell(cell, withObject: object, atIndexPath: indexPath)
        
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
    public func makeUpdateVisibleCell( tableView: UITableView ) -> ( NSIndexPath, ObjectType ) -> Void {
        return { indexPath, object in
            guard let cell = tableView.cellForRowAtIndexPath( indexPath ) else { return }
            
            guard let customCell = cell as? CellType else {
                fatalError("Incorrect table view cell type")
            }

            self.configureCell(customCell, withObject: object, atIndexPath: indexPath )
        }
    }

}

// Type erased wrapper for TableCellConfigurator protocol
private struct AnyTableCellConfigurator<ObjectType,CellType:UITableViewCell>: TableCellConfigurator {
    
    let _configureCell: (cell: CellType, withObject: ObjectType, atIndexPath: NSIndexPath)->()
    let _cellReuseIdentifierForObject: (object: ObjectType, atIndexPath: NSIndexPath) -> String
    
    init<U:TableCellConfigurator where U.ObjectType == ObjectType, U.CellType == CellType>( _ configurator: U ) {
        _cellReuseIdentifierForObject = configurator.cellReuseIdentifierForObject
        _configureCell = configurator.configureCell
    }
    
    func configureCell(cell: CellType, withObject object: ObjectType, atIndexPath indexPath: NSIndexPath) {
        _configureCell(cell: cell, withObject: object, atIndexPath: indexPath)
    }
    
    func cellReuseIdentifierForObject(object: ObjectType, atIndexPath indexPath: NSIndexPath) -> String {
        return _cellReuseIdentifierForObject(object: object, atIndexPath: indexPath)
    }
    
}

