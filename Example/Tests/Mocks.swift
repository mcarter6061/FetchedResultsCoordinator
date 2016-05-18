//  Copyright © 2016 CocoaPods. All rights reserved.

import Foundation
import UIKit
@testable import FetchedResultsCoordinator
import CoreData


// MARK: - Mock TableCellConfigurator

enum SpyConfiguratorInvocation<T:Equatable>:Equatable {
    case ConfigureCell( UITableViewCell, T, NSIndexPath)
    case CellReuseIdentifierForObject( T, NSIndexPath)
}

func ==<T:Equatable>(lhs: SpyConfiguratorInvocation<T>, rhs: SpyConfiguratorInvocation<T>) -> Bool {
    
    switch (lhs,rhs) {
    case (.ConfigureCell(let lhsCell, let lhsObject, let lhsIndexPath ),.ConfigureCell(let rhsCell, let rhsObject, let rhsIndexPath))
        where lhsCell == rhsCell &&
            lhsObject == rhsObject &&
            lhsIndexPath == rhsIndexPath: return true
    case (.CellReuseIdentifierForObject(let lhsObject, let lhsIndexPath),.CellReuseIdentifierForObject( let rhsObject, let rhsIndexPath))
        where lhsObject == rhsObject &&
            lhsIndexPath == rhsIndexPath: return true
    default: return false
    }
}



class SpyConfigurator<ObjectType:Equatable>: TableCellConfigurator {
    
    typealias Invocation = SpyConfiguratorInvocation<ObjectType>
    
    var capturedCalls: [Invocation] = []
    var reuseIdentifier: String?
    
    func configureCell( cell: UITableViewCell, withObject object: ObjectType, atIndexPath indexPath: NSIndexPath ) {
        let invocation = Invocation.ConfigureCell(cell, object, indexPath)
        capturedCalls.append(invocation)
    }
    
    func cellReuseIdentifierForObject( object: ObjectType, atIndexPath indexPath: NSIndexPath ) -> String {
        
        let invocation = Invocation.CellReuseIdentifierForObject(object, indexPath)
        capturedCalls.append(invocation)
        
        guard let reuseIdentifier = reuseIdentifier else { fatalError("SpyConfigurator must have reuseIdentifier property set before cellReuseIdentifierForObject called") }
        
        return reuseIdentifier
    }
    
}


// MARK: - Mock UITableView

enum TableViewInvocation: Equatable {
    case InsertSections( NSIndexSet )
    case DeleteSections( NSIndexSet )
    case InsertRowsAtIndexPaths( indexPaths:[NSIndexPath] )
    case DeleteRowsAtIndexPaths( indexPaths:[NSIndexPath] )
    case ReloadRowsAtIndexPaths( indexPaths: [NSIndexPath] )
    case MoveRowAtIndexPath(indexPath: NSIndexPath, newIndexPath: NSIndexPath)
    case BeginUpdates
    case EndUpdates
    case SelectRowAtIndexPath( indexPath: NSIndexPath? )
    case DeselectRowAtIndexPath( indexPath: NSIndexPath )
}

func ==(lhs: TableViewInvocation, rhs: TableViewInvocation) -> Bool {
    switch (lhs,rhs) {
    case let (.InsertSections(lhsIndexSet), .InsertSections(rhsIndexSet)) where lhsIndexSet == rhsIndexSet:return true
    case let (.DeleteSections(lhsIndexSet), .DeleteSections(rhsIndexSet)) where lhsIndexSet == rhsIndexSet:return true
    case let (.InsertRowsAtIndexPaths(lhsIndexPaths), .InsertRowsAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.DeleteRowsAtIndexPaths(lhsIndexPaths), .DeleteRowsAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.ReloadRowsAtIndexPaths(lhsIndexPaths), .ReloadRowsAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.MoveRowAtIndexPath(lhsIndexPaths), .MoveRowAtIndexPath(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case (.BeginUpdates,.BeginUpdates):return true
    case (.EndUpdates,.EndUpdates):return true
    case let (.SelectRowAtIndexPath(lhsIndexPath), .SelectRowAtIndexPath(rhsIndexPath)) where lhsIndexPath == rhsIndexPath:return true
    case let (.DeselectRowAtIndexPath(lhsIndexPath), .DeselectRowAtIndexPath(rhsIndexPath)) where lhsIndexPath == rhsIndexPath:return true
    default: return false
    }
}


class SpyTableView: UITableView {
    var capturedCalls: [TableViewInvocation] = []
    var selectedRows: [NSIndexPath]?
    var cell: UITableViewCell?
    
    override func insertSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        capturedCalls.append(.InsertSections(sections))
    }
    
    override func deleteSections(sections: NSIndexSet, withRowAnimation animation: UITableViewRowAnimation) {
        capturedCalls.append(.DeleteSections(sections))
    }
    override func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        capturedCalls.append(.InsertRowsAtIndexPaths( indexPaths: indexPaths ))
    }
    
    override func deleteRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        capturedCalls.append(.DeleteRowsAtIndexPaths(indexPaths: indexPaths))
    }
    
    override func reloadRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        capturedCalls.append(.ReloadRowsAtIndexPaths(indexPaths: indexPaths))
    }
    
    override func moveRowAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        capturedCalls.append(.MoveRowAtIndexPath(indexPath: indexPath, newIndexPath: newIndexPath))
    }
    
    override func beginUpdates() {
        capturedCalls.append(.BeginUpdates)
    }
    
    override func endUpdates() {
        capturedCalls.append(.EndUpdates)
    }
    
    override func selectRowAtIndexPath(indexPath: NSIndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
        capturedCalls.append(.SelectRowAtIndexPath(indexPath: indexPath))
    }
    
    override func deselectRowAtIndexPath(indexPath: NSIndexPath, animated: Bool) {
        capturedCalls.append(.DeselectRowAtIndexPath(indexPath: indexPath))
    }
    
    override var indexPathForSelectedRow: NSIndexPath? {
        return selectedRows?.first
    }
    
    override var indexPathsForSelectedRows: [NSIndexPath]? {
        return selectedRows
    }
    
    override func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cell!
    }
    
}

// MARK: - Mock UICollectionView

enum CollectionViewInvocation: Equatable {
    case InsertSections( NSIndexSet )
    case DeleteSections( NSIndexSet )
    case InsertItemssAtIndexPaths( indexPaths:[NSIndexPath] )
    case DeleteItemssAtIndexPaths( indexPaths:[NSIndexPath] )
    case ReloadItemssAtIndexPaths( indexPaths: [NSIndexPath] )
    case MoveItemsAtIndexPath(indexPath: NSIndexPath, newIndexPath: NSIndexPath)
    case PerformBatchUpdates
}

func ==(lhs: CollectionViewInvocation, rhs: CollectionViewInvocation) -> Bool {
    switch (lhs,rhs) {
    case let (.InsertSections(lhsIndexSet), .InsertSections(rhsIndexSet)) where lhsIndexSet == rhsIndexSet:return true
    case let (.DeleteSections(lhsIndexSet), .DeleteSections(rhsIndexSet)) where lhsIndexSet == rhsIndexSet:return true
    case let (.InsertItemssAtIndexPaths(lhsIndexPaths), .InsertItemssAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.DeleteItemssAtIndexPaths(lhsIndexPaths), .DeleteItemssAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.ReloadItemssAtIndexPaths(lhsIndexPaths), .ReloadItemssAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.MoveItemsAtIndexPath(lhsIndexPaths), .MoveItemsAtIndexPath(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case (.PerformBatchUpdates,.PerformBatchUpdates):return true
    default: return false
    }
}


class SpyCollectionView: UICollectionView {
    
    var capturedCalls: [CollectionViewInvocation] = []
    
    override func insertItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        capturedCalls.append(.InsertItemssAtIndexPaths( indexPaths: indexPaths ))
    }
    
    override func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        capturedCalls.append(.DeleteItemssAtIndexPaths(indexPaths: indexPaths))
    }
    
    override func reloadItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        capturedCalls.append(.ReloadItemssAtIndexPaths(indexPaths: indexPaths))
    }
    
    override func moveItemAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        capturedCalls.append(.MoveItemsAtIndexPath(indexPath: indexPath, newIndexPath: newIndexPath))
    }
    
    override func performBatchUpdates(updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        capturedCalls.append(.PerformBatchUpdates)
        updates?()
        completion?(true)
    }
    
    override func insertSections(sections: NSIndexSet) {
        capturedCalls.append(.InsertSections(sections))
    }
    
    override func deleteSections(sections: NSIndexSet) {
        capturedCalls.append(.DeleteSections(sections))
    }
    
}

// MARK: - Mock NSFetchedResultsController

protocol SpyFRCObject: class {
    var indexPath: NSIndexPath? {get}
}

class NoObject: AnyObject {}

class SpyFRC<T:SpyFRCObject>: NSFetchedResultsController {
    
    var performFetchedCalled = false
    
    override func performFetch() throws {
        performFetchedCalled = true
    }
    
    var objects: [T] = []

    override func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        // this is a bit weird, to override the method we can't add throws or any way to feedback that there is no object at this index.  In reality the program would crash with a runtime error.
        return objects.filter{$0.indexPath == indexPath}.first ?? NoObject()
    }
    
    override func indexPathForObject(object: AnyObject) -> NSIndexPath? {
        return objects.filter{object === $0}.first?.indexPath
    }
    
    
    
    override init() {
        super.init()
    }
}

// MARK: - Mock Coordinatable

class SpyCoordinatee: Coordinatable {
    
    var reloadDataCalled = false
    var appliedChangeSet: ChangeSet?
    
    func reloadData() {
        reloadDataCalled = true
    }
    
    func apply( changeSet: ChangeSet ) {
        appliedChangeSet = changeSet
    }
    
}

extension FetchedObjectChange:Equatable {}

public func ==(lhs: FetchedObjectChange, rhs: FetchedObjectChange) -> Bool {
    switch (lhs,rhs) {
    case let (.Insert(lhsIndexPath), .Insert(rhsIndexPath)) where lhsIndexPath == rhsIndexPath:return true
    case let (.Delete(lhsIndexPath), .Delete(rhsIndexPath)) where lhsIndexPath == rhsIndexPath:return true
    case let (.Move(lhsIndexPath), .Move(rhsIndexPath)) where lhsIndexPath == rhsIndexPath:return true
    case let (.Update(lhsIndexPath), .Update(rhsIndexPath)) where lhsIndexPath == rhsIndexPath:return true
    case (.CellConfigure, .CellConfigure):return true
    default: return false
    }
}


