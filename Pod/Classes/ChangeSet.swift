//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit

public typealias MoveIndexes = ( from: NSIndexPath, to: NSIndexPath )

public enum FetchedObjectChange {
    case Insert( NSIndexPath )
    case Delete( NSIndexPath )
    case Move( MoveIndexes )
    case Update( NSIndexPath )
    // Special case, rather than use the table/collection view reload cell methods ( which can cause an anmiation flash ), if a method to configure the cell is provided, call this closure will call that method for the cell )
    case CellConfigure( ()->() )
    
}

public struct ChangeSet {
    
    var insertedSections = NSMutableIndexSet()
    var deletedSections = NSMutableIndexSet()
    var objectChanges: [FetchedObjectChange] = []
    
    func isInDeletedSection( indexPath: NSIndexPath? ) -> Bool? {
        return indexPath.map{ deletedSections.containsIndex($0.section)}
    }
    
    func isInInsertedSection( indexPath: NSIndexPath? ) -> Bool? {
        return indexPath.map{insertedSections.containsIndex($0.section)}
    }
}


extension UITableView: Coordinatable {
    
    public func apply(changeSet: ChangeSet ) {
        
        self.beginUpdates()
        
        let ( deletedIndexes, insertedIndexes, updatedIndexes, movedIndexes ) = batchObjectChanges( changeSet.objectChanges )
        
        if changeSet.deletedSections.count > 0 {
            self.deleteSections(changeSet.deletedSections, withRowAnimation: .Fade)
        }
        
        if changeSet.insertedSections.count > 0 {
            self.insertSections(changeSet.insertedSections, withRowAnimation: .Fade)
        }
        
        if !deletedIndexes.isEmpty {
            self.deleteRowsAtIndexPaths(deletedIndexes, withRowAnimation: .Fade)
        }
        
        if !insertedIndexes.isEmpty {
            self.insertRowsAtIndexPaths(insertedIndexes, withRowAnimation: .Fade)
        }
        
        if !movedIndexes.isEmpty {
            self.deleteRowsAtIndexPaths(movedIndexes.map{$0.from}, withRowAnimation: .Fade)
            self.insertRowsAtIndexPaths(movedIndexes.map{$0.to}, withRowAnimation: .Fade)
        }
        
        if !updatedIndexes.isEmpty {
            self.reloadRowsAtIndexPaths(updatedIndexes, withRowAnimation: .None)
        }
        
        self.endUpdates()
        
        updateCells(changeSet)
    }
    
}

extension UICollectionView: Coordinatable {
    
    public func apply(changeSet: ChangeSet ) {
        
        self.performBatchUpdates({
            
            if changeSet.deletedSections.count > 0 {
                self.deleteSections(changeSet.deletedSections)
            }
            
            if changeSet.insertedSections.count > 0 {
                self.insertSections(changeSet.insertedSections)
            }
            
            let ( deletedIndexes, insertedIndexes, updatedIndexes, movedIndexes ) = batchObjectChanges( changeSet.objectChanges )
            
            if !deletedIndexes.isEmpty {
                self.deleteItemsAtIndexPaths(deletedIndexes)
            }
            
            if !insertedIndexes.isEmpty {
                self.insertItemsAtIndexPaths(insertedIndexes)
            }
            
            if !movedIndexes.isEmpty {
                self.deleteItemsAtIndexPaths(movedIndexes.map{$0.from})
                self.insertItemsAtIndexPaths(movedIndexes.map{$0.to})
            }
            
            if !updatedIndexes.isEmpty {
                self.reloadItemsAtIndexPaths(updatedIndexes)
            }
            }, completion: { _ in updateCells(changeSet) })
    }
}

func updateCells( changeSet: ChangeSet ) {
    
    for case let .CellConfigure( updateCell ) in changeSet.objectChanges {
        updateCell()
    }
}

func batchObjectChanges( changes: [FetchedObjectChange] ) -> ( deletes:[NSIndexPath], inserts:[NSIndexPath], updates:[NSIndexPath], moves:[MoveIndexes] ) {
    
    var deletedIndexes: [NSIndexPath] = []
    var insertedIndexes: [NSIndexPath] = []
    var updatedIndexes: [NSIndexPath] = []
    var movedIndexes: [MoveIndexes] = []
    
    for objectChange in changes {
        switch objectChange {
        case .Insert( let index ): insertedIndexes.append(index)
        case .Delete( let index ): deletedIndexes.append(index)
        case .Update( let index ): updatedIndexes.append(index)
        case .Move( let move ): movedIndexes.append( move )
        case .CellConfigure: break; // Will handle these refresh via configureCell in the coordinator
        }
    }
    
    return ( deletedIndexes, insertedIndexes, updatedIndexes, movedIndexes )
}

extension ChangeSet: CustomStringConvertible {
    
    public var description: String {
        
        let ( deletedIndexes, insertedIndexes, updatedIndexes, movedIndexes ) = batchObjectChanges( objectChanges )
        
        return "+Inserted Sections \(insertedSections.count)\n-Deleted Sections \(deletedSections.count)\n+Inserted Objects \(insertedIndexes.count)\n↺Updated Objects \(updatedIndexes.count)\n⇆Moved Objects \(movedIndexes.count)\n-Deleted Objects \(deletedIndexes.count) "
    }
}

extension ChangeSet: CustomPlaygroundQuickLookable {
    
    public func customPlaygroundQuickLook() -> PlaygroundQuickLook {
        return .Text( description )
    }
}