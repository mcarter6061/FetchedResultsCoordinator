//  Copyright © 2016 Mark Carter. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator
import CoreData

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

class CollectionViewTests: QuickSpec {
    
    override func spec() {
        
        describe("With a collection view") {
            
            let indexPathZero = NSIndexPath( forRow:0, inSection:0 )
            let indexPathOne = NSIndexPath( forRow:1, inSection:0 )
            let indexSet = NSMutableIndexSet(index: 5)
            
            var sut: SpyCollectionView!
            var changes:ChangeSet!
            
            beforeEach({
                sut = SpyCollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
                changes = ChangeSet()
            })
            
            it("reloads data") {
                sut.reloadData()
            }
            
            it("applies no changes") {
                changes.objectChanges = []
                sut.apply(changes)
                
                let expected = CollectionViewInvocation.PerformBatchUpdates
                expect(sut.capturedCalls).to(equal([expected]))
            }

            it("updates table when section inserted") {
                changes.insertedSections = indexSet
                sut.apply( changes )
                
                let expected = CollectionViewInvocation.InsertSections(indexSet)
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("updates table when section inserted") {
                changes.deletedSections = indexSet
                sut.apply( changes )
                
                let expected = CollectionViewInvocation.DeleteSections(indexSet)
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("updates table when data inserted") {
                changes.objectChanges = [.Insert(indexPathZero)]
                sut.apply( changes )
                
                let expected = CollectionViewInvocation.InsertItemssAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("updates table when data deleted") {
                changes.objectChanges = [.Delete(indexPathZero)]
                sut.apply( changes )
                
                let expected = CollectionViewInvocation.DeleteItemssAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("updates table when data moved") {
                changes.objectChanges = [.Move(from:indexPathZero,to:indexPathOne)]
                sut.apply( changes )
                
                let expectedA:CollectionViewInvocation = .DeleteItemssAtIndexPaths(indexPaths:[indexPathZero])
                let expectedB:CollectionViewInvocation = .InsertItemssAtIndexPaths(indexPaths:[indexPathOne])
                expect(sut.capturedCalls).to(contain(expectedA,expectedB))
            }
            
            it("updates table when data updated") {
                changes.objectChanges = [.Update(indexPathZero)]
                sut.apply( changes )
                
                let expected = CollectionViewInvocation.ReloadItemssAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("doesn't update table when cell reloaded") {
                changes.objectChanges = [.CellConfigure( {} )]
                sut.apply(changes)
                
                let rejected = CollectionViewInvocation.ReloadItemssAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).toNot(contain(rejected))
            }
            
            it("calls reload cell function when cell reloaded") {
                var calledReload = false
                changes.objectChanges = [.CellConfigure( {calledReload = true} )]
                sut.apply(changes)
                
                expect(calledReload).to(beTrue())
            }

            // TODO: finish porting over tests from tableview objc tests.
        }
    }
}