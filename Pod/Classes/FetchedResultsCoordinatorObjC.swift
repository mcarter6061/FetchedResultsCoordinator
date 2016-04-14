import Foundation
import CoreData

// This is an objc bridging wrapper.  Because FetchedResultsCoordinator is a generic class it can't be used in Obj-C.  This wrapper class specializes FetchedResultsCoordinator to use a NSManagedObject and provides a non-generic interface.
@objc(FetchedResultsCoordinator) public class FetchedResultsCoordinatorObjC:  NSObject, NSFetchedResultsControllerDelegate {
    
    public typealias UpdateVisibleCell = ( index: NSIndexPath, object: NSManagedObject ) -> ()
    
    let coordinator: FetchedResultsCoordinator<NSManagedObject>
    
    public var paused: Bool {
        get { return coordinator.paused }
        set { coordinator.paused = newValue }
    }
    
    @objc public init( collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController, updateCell: UpdateVisibleCell? ) {
        self.coordinator = FetchedResultsCoordinator<NSManagedObject>(coordinatee: collectionView, fetchedResultsController: fetchedResultsController, updateCell: updateCell)
    }
    
    @objc public init( tableView: UITableView, fetchedResultsController: NSFetchedResultsController, updateCell: UpdateVisibleCell? ) {
        self.coordinator = FetchedResultsCoordinator<NSManagedObject>(coordinatee: tableView, fetchedResultsController: fetchedResultsController, updateCell: updateCell)
    }
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        coordinator.controllerWillChangeContent(controller)
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        coordinator.controllerDidChangeContent(controller)
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        coordinator.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        coordinator.controller( controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType:type)
    }
    
    public func loadData() {
        coordinator.loadData()
    }
}

