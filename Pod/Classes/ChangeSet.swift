//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit

typealias UpdateChange = (indexPath:NSIndexPath, object:NSManagedObject)
typealias MoveChange = (fromIndexPath:NSIndexPath,toIndexPath:NSIndexPath)
typealias ApplyUpdateChange = ( UpdateChange ) -> ()

struct ChangeSet {
    var insertedSections = NSMutableIndexSet()
    var deletedSections = NSMutableIndexSet()
    var insertedItems: [NSIndexPath] = []
    var deletedItems: [NSIndexPath] = []
    var updatedItems: [UpdateChange] = []
    var movedItems: [MoveChange] = []
    
    func indexPathInDeletedSection( indexPath: NSIndexPath ) -> Bool {
        return deletedSections.containsIndex(indexPath.section)
    }

    func indexPathInInsertedSection( indexPath: NSIndexPath ) -> Bool {
        return insertedSections.containsIndex(indexPath.section)
    }

    func description() -> String {
        
        var result = "ChangeSet:\n"
        if insertedSections.count > 0 {
            result += "insertedSections \(insertedSections)\n"
        }
        
        if deletedSections.count > 0 {
            result += "deletedSections \(deletedSections)\n"
        }
        
        if !insertedItems.isEmpty {
            result += "insertedItems \(insertedItems)\n"
        }
        
        if !deletedItems.isEmpty {
            result += "deletedItems \(deletedItems)\n"
        }
        
        if !updatedItems.isEmpty {
            result += "updatedItems \(updatedItems)\n"
        }
        
        if !movedItems.isEmpty {
            result += "movedItems \(movedItems)\n"
        }
        
        return result
    }
}

protocol Coordinatable {
    
    func reloadData()
    
    func apply( changeSet: ChangeSet, applyUpdate: ApplyUpdateChange? )
}

extension UITableView: Coordinatable {
    
    func apply(changeSet: ChangeSet, applyUpdate: ApplyUpdateChange? ) {
        print( changeSet.description() )
        self.beginUpdates()
        
        if changeSet.deletedSections.count > 0 {
            self.deleteSections(changeSet.deletedSections, withRowAnimation: .Fade)
        }
        
        if changeSet.insertedSections.count > 0 {
            self.insertSections(changeSet.insertedSections, withRowAnimation: .Fade)
        }
        
        if !changeSet.deletedItems.isEmpty {
            self.deleteRowsAtIndexPaths(changeSet.deletedItems, withRowAnimation: .Fade)
        }
        
        if !changeSet.insertedItems.isEmpty {
            self.insertRowsAtIndexPaths(changeSet.insertedItems, withRowAnimation: .Fade)
        }
        
        if !changeSet.movedItems.isEmpty {
            self.deleteRowsAtIndexPaths(changeSet.movedItems.map{$0.fromIndexPath}, withRowAnimation: .Fade)
            self.insertRowsAtIndexPaths(changeSet.movedItems.map{$0.toIndexPath}, withRowAnimation: .Fade)
        }
        
        if !changeSet.updatedItems.isEmpty {
            if let applyUpdate = applyUpdate {
                changeSet.updatedItems.forEach(applyUpdate)
            } else {
                self.reloadRowsAtIndexPaths(changeSet.updatedItems.map({$0.indexPath}), withRowAnimation: .None)
            }
        }
        
        self.endUpdates()
    }
}



extension UICollectionView: Coordinatable {
    
    func apply(changeSet: ChangeSet, applyUpdate: ApplyUpdateChange? ) {
        
        self.performBatchUpdates({
            
            if changeSet.deletedSections.count > 0 {
                self.deleteSections(changeSet.deletedSections)
            }
            
            if changeSet.insertedSections.count > 0 {
                self.insertSections(changeSet.insertedSections)
            }
            
            if !changeSet.deletedItems.isEmpty {
                self.deleteItemsAtIndexPaths(changeSet.deletedItems)
            }
            
            if !changeSet.insertedItems.isEmpty {
                self.insertItemsAtIndexPaths(changeSet.insertedItems)
            }
            
            if !changeSet.movedItems.isEmpty {
                self.deleteItemsAtIndexPaths(changeSet.movedItems.map{$0.fromIndexPath})
                self.insertItemsAtIndexPaths(changeSet.movedItems.map{$0.toIndexPath})
            }
            
            if !changeSet.updatedItems.isEmpty {
                if let applyUpdate = applyUpdate {
                    changeSet.updatedItems.forEach(applyUpdate)
                } else {
                    self.reloadItemsAtIndexPaths(changeSet.updatedItems.map({$0.indexPath}))
                }
            }
            
            }, completion: nil)
    }
}
