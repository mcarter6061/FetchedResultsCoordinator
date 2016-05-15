//  Copyright © 2016 Mark Carter. All rights reserved.

import Foundation

public protocol TableSelection {
    
    associatedtype ObjectType

    func selectObjects(tableView:UITableView, objects: [ObjectType] )
    func selectedObjects(tableView: UITableView) -> [ObjectType]
    func selectedObject(tableView: UITableView) -> ObjectType?
    
    func indexPathForObject( object:ObjectType) -> NSIndexPath?
    func objectAtIndexPath( indexPath:NSIndexPath ) -> ObjectType
}

extension TableSelection {
    
    /// Selects the table view rows for the `objects` passed in
    public func selectObjects( tableView:UITableView, objects: [ObjectType] ) {
        let indexPathsForObjects = objects.flatMap(indexPathForObject)
        indexPathsForObjects.forEach{tableView.selectRowAtIndexPath($0, animated: false, scrollPosition: .None)}
    }
    
    /// Returns underlying `ObjectType` objects for the selected rows of a table view that allows multiple selection
    public func selectedObjects(tableView: UITableView) -> [ObjectType] {
        return tableView.indexPathsForSelectedRows?.map{objectAtIndexPath($0)} ?? []
    }
    
    /// Returns underlying `ObjectType` objects for the selected row
    public func selectedObject(tableView: UITableView) -> ObjectType? {
        return tableView.indexPathForSelectedRow.map{objectAtIndexPath($0)}
    }

}

extension FetchedTableDataSource: TableSelection {
    
    public func objectAtIndexPath( indexPath: NSIndexPath ) -> ManagedObjectType {
        guard let object = fetchedResultsController.objectAtIndexPath(indexPath) as? ManagedObjectType else {
            fatalError("Wrong object type")
        }
        
        return object
    }

    public func indexPathForObject(object: ManagedObjectType) -> NSIndexPath? {
        return fetchedResultsController.indexPathForObject(object)
    }
}

extension ListTableDataSource: TableSelection {
    
    public func objectAtIndexPath( indexPath: NSIndexPath ) -> ObjectType {
        
        guard indexPath.section == 0 else { fatalError("Only single section supported by ListTableDataSource currently") }
        
        return data[indexPath.row]
    }

    public func indexPathForObject(object: ObjectType) -> NSIndexPath? {
        guard let row = data.indexOf(object) else { return nil }
        return NSIndexPath(forRow: row, inSection: 0)
    }
}
