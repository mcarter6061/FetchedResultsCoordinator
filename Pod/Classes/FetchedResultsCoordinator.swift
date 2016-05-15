//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit


public protocol FetchedResultsCoordinatorDelegate {

    func numberOfObjectsChanged( count: Int )
}

public protocol Coordinatable {
    
    func reloadData()
    
    func apply( changeSet: ChangeSet )
}


public class FetchedResultsCoordinator<ManagedObjectType:NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias UpdateVisibleCell = ( index: NSIndexPath, object: ManagedObjectType ) -> ()

    public var paused = false {
        didSet {
            self.fetchedResultsController.delegate = paused ? nil : self
            
            if !paused && oldValue {
                loadData()
            }
        }
    }
    
    public var delegate: FetchedResultsCoordinatorDelegate?
    
    public private(set) var fetchedResultsController: NSFetchedResultsController
    private var changes = ChangeSet()
    private var coordinatee: Coordinatable
    private var updateVisibleCell: UpdateVisibleCell?
    
    public init( coordinatee: Coordinatable, fetchedResultsController: NSFetchedResultsController, updateCell: UpdateVisibleCell? = nil) {
        self.fetchedResultsController = fetchedResultsController
        self.coordinatee = coordinatee
        self.updateVisibleCell = updateCell
        
        super.init()
    }

    deinit {
        fetchedResultsController.delegate = nil
    }
   
    public func loadData() {
        
        do {
            try fetchedResultsController.performFetch()
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
    
    var numberOfObjects: Int = 0 {
        didSet {
            if oldValue != numberOfObjects {
                delegate?.numberOfObjectsChanged(numberOfObjects)
            }
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        coordinatee.apply(changes)
        
        changes = ChangeSet()
        
        numberOfObjects = fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        switch (type, changes.isInInsertedSection(newIndexPath), changes.isInDeletedSection(indexPath)) {
        case (.Delete, _, false? ): changes.objectChanges.append(.Delete(indexPath!))
        case (.Insert, false?, _ ): changes.objectChanges.append(.Insert(newIndexPath!))
        case (.Move,false?,false?): changes.objectChanges.append( .Move( from: indexPath!, to: newIndexPath!))
        case (.Move,false?,_):      changes.objectChanges.append( .Insert(newIndexPath!))
        case (.Move,_,false?):      changes.objectChanges.append( .Delete(indexPath!))
        case (.Update,_,false?):
            if let updateVisibleCell = updateVisibleCell {
                let updateCell = { updateVisibleCell( index: indexPath!, object: anObject as! ManagedObjectType) }
                changes.objectChanges.append( .CellConfigure( updateCell ) )
            } else {
                changes.objectChanges.append( .Update( indexPath! ) )
            }
        default:break
            // .Delete ignores objects being deleted from a section that was deleted
            // .Insert ignores objects being inserted into a newly inserted section
            // .Update should never receive on in a deleted or inserted section
            // .Move if moving from one section to another, sections may be inserted/deleted in which case we
            //       only need to account for the insertItem/deleteItem in the sections that weren't inserted/deleted
            
            // Docs state "The fetched results controller reports changes to its section before changes to the fetched result objects" so should be able to filter on the inserted/deleted sections
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


