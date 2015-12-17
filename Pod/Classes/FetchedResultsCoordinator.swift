//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit

public class FetchedResultsCoordinator: NSObject,NSFetchedResultsControllerDelegate {
    
    public var paused = false {
        didSet {
            self.fetchedResultsController.delegate = paused ? nil : self
            
            if !paused && oldValue {
                loadData()
            }
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController
    var changes = ChangeSet()
    var viewToSync: Coordinatable
    var reconfigureVisibleCell: ApplyUpdateChange?
    
    
    public init( collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController, cellConfigurator: CollectionCellConfigurator? ) {
        
        self.fetchedResultsController = fetchedResultsController
        self.viewToSync = collectionView
        
        if let cellConfigurator = cellConfigurator {
            self.reconfigureVisibleCell = { (indexPath, object) in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                    cellConfigurator.configureCell(cell, withObject: object)
                }
            }
        }
        
        super.init()
    }
    
    public init( tableView: UITableView, fetchedResultsController: NSFetchedResultsController, cellConfigurator: TableCellConfigurator? ) {
        
        self.fetchedResultsController = fetchedResultsController
        self.viewToSync = tableView
        
        if let cellConfigurator = cellConfigurator {
            self.reconfigureVisibleCell = {
                if let cell = tableView.cellForRowAtIndexPath($0) {
                    cellConfigurator.configureCell(cell, withObject:$1)
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
        
        viewToSync.reloadData()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        viewToSync.apply(changes, applyUpdate:reconfigureVisibleCell)
        changes = ChangeSet()
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        
        // if there is an indexPath ( delete, move, update ) -
        // newIndexPath ( insert, move )
        
        print("didChangeObject: changeType \(type.description) atIndexPath \(indexPath) newIndexPath \(newIndexPath)")
        
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
        print("didChangeSection: changeType \(type.description) section \(sectionIndex)")

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

extension NSFetchedResultsChangeType {
    
    var description : String {
        get {
            switch(self) {
            case .Insert:
                return "Insert"
            case .Delete:
                return "Delete"
            case .Update:
                return "Update"
            case .Move:
                return "Move"
            }
        }
    }
}