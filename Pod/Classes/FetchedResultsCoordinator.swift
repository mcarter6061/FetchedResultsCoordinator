//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit

// Can I create an objc coordinator that could be used by an objc class
// needs a better name that sticking objc on the end!
//@objc public class FetchedResultsCoordinatorProxy:  NSObject, NSFetchedResultsControllerDelegate {
//    let coordinator: FetchedResultsCoordinator<NSManagedObject>
//    
//       @objc public init( collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController, cellConfigurator: CollectionCellConfigurator? ) {
//        self.coordinator = FetchedResultsCoordinator<NSManagedObject>(collectionView: collectionView, fetchedResultsController: fetchedResultsController, cellConfigurator: cellConfigurator)
//    }
//    
//    public init<U:TableCellConfigurator where U.ManagedObjectType == NSManagedObject>( tableView: UITableView, fetchedResultsController: NSFetchedResultsController, cellConfigurator: U? ) {
//        self.coordinator = FetchedResultsCoordinator<NSManagedObject>(tableView: tableView, fetchedResultsController: fetchedResultsController, cellConfigurator: cellConfigurator)
//    }
//    
//    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        coordinator.controllerWillChangeContent(controller)
//    }
//    
//    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        coordinator.controllerDidChangeContent(controller)
//    }
//    
//    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        coordinator.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
//    }
//    
//    public func loadData() {
//        coordinator.loadData()
//    }
//}
//
public class FetchedResultsCoordinator<ManagedObjectType:NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    public var paused = false {
        didSet {
            self.fetchedResultsController.delegate = paused ? nil : self
            
            if !paused && oldValue {
                loadData()
            }
        }
    }
    
    public private(set) var fetchedResultsController: NSFetchedResultsController
    var changes = ChangeSet()
    var coordinatee: Coordinatable
    var reconfigureVisibleCell: ApplyUpdateChange?
    
    public init( collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController, cellConfigurator: CollectionCellConfigurator? ) {
        
        self.fetchedResultsController = fetchedResultsController
        self.coordinatee = collectionView
        
        if let cellConfigurator = cellConfigurator {
            self.reconfigureVisibleCell = { (indexPath, object) in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                    cellConfigurator.configureCell(cell, withManagedObject: object)
                }
            }
        }
        
        super.init()
    }
    
    public init<U:TableCellConfigurator where U.ManagedObjectType == ManagedObjectType>( tableView: UITableView, fetchedResultsController: NSFetchedResultsController, cellConfigurator: U? ) {
        
        self.fetchedResultsController = fetchedResultsController
        self.coordinatee = tableView
        
        if let cellConfigurator = cellConfigurator {
            self.reconfigureVisibleCell = {
                if let cell = tableView.cellForRowAtIndexPath($0) {
                    guard let object = $1 as? ManagedObjectType else { fatalError("Incorrect object type") }
                    cellConfigurator.configureCell(cell, withManagedObject:object)
                }
            }
        }
        
        super.init()
    }
    
    public func loadData() {
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            fatalError("performFetch failed:\(error).  Is your fetch request valid?")
        }
        
        self.fetchedResultsController.delegate = paused ? nil : self
        
        coordinatee.reloadData()
    }
    
    public func objectAtIndexPath( indexPath: NSIndexPath ) -> ManagedObjectType {
        guard let object = fetchedResultsController.objectAtIndexPath(indexPath) as? ManagedObjectType else {
            fatalError("Wrong object type")
        }
        
        return object
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        coordinatee.apply(changes, applyUpdate:reconfigureVisibleCell)
        changes = ChangeSet()
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch type {
        case .Delete where !changes.indexPathInDeletedSection(indexPath!):
            changes.deletedItems.append(indexPath!)
        case .Insert where !changes.indexPathInInsertedSection(newIndexPath!):
            changes.insertedItems.append(newIndexPath!)
        case .Update:
            changes.updatedItems.append( (indexPath!, anObject as! NSManagedObject) )
        case .Move where !changes.indexPathInDeletedSection(indexPath!) && !changes.indexPathInInsertedSection(newIndexPath!):
            changes.movedItems.append((fromIndexPath: indexPath!, toIndexPath: newIndexPath!))
        case .Move where !changes.indexPathInInsertedSection(newIndexPath!):
            changes.insertedItems.append(newIndexPath!)
        case .Move where !changes.indexPathInDeletedSection(indexPath!):
            changes.deletedItems.append(indexPath!)
        default:
            // .Delete ignores objects being deleted from a section that was deleted
            // .Insert ignores objects being inserted into a newly inserted section
            // .Update should never receive on in a deleted or inserted section
            // .Move if moving from one section to another, sections may be inserted/deleted in which case we 
            //       only need to account for the insertItem/deleteItem in the sections that weren't inserted/deleted
            
            // Docs state "The fetched results controller reports changes to its section before changes to the fetched result objects" so should be able to filter on the inserted/deleted sections
            break
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {

        switch type {
        case .Insert:
            changes.insertedSections.addIndex(sectionIndex)
        case .Delete:
            changes.deletedSections.addIndex(sectionIndex)
        default:
            // Docs state only insert and delete are valid change types in didChangeSection: method
            break
        }
    }
    
    // NOTE: sectionIndexTitleForSectionName is not implemented, if you do not want default behaviour ( section index is section name's first letter capitalized ) you must override FetchedResultsCoordinator with your own implementation.
    //optional public func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
    
}