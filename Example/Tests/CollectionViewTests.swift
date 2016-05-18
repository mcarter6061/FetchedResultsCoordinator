//  Copyright © 2016 Mark Carter. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator
import CoreData

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