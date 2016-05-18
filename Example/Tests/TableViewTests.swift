//  Copyright © 2016 Mark Carter. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator
import CoreData


class TableViewTests: QuickSpec {
    
    override func spec() {
        
        describe("With a table view") {
            
            let indexPathZero = NSIndexPath( forRow:0, inSection:0 )
            let indexPathOne = NSIndexPath( forRow:1, inSection:0 )
            let indexPathTwo = NSIndexPath( forRow:2, inSection:0 )
            let indexPathThree = NSIndexPath( forRow:3, inSection:0 )
            let indexSet = NSMutableIndexSet(index: 5)

            var sut: SpyTableView!
            var changes:ChangeSet!
            
            beforeEach({ 
                sut = SpyTableView()
                changes = ChangeSet()
            })

            it("reloads data") {
                sut.reloadData()
            }
            
            it("updates table when section inserted") {
                changes.insertedSections = indexSet
                sut.apply( changes )
                
                let expected:[TableViewInvocation] = [.BeginUpdates,.InsertSections(indexSet),.EndUpdates]
                expect(sut.capturedCalls).to(equal(expected))
            }

            it("updates table when section inserted") {
                changes.deletedSections = indexSet
                sut.apply( changes )
                
                let expected:TableViewInvocation = .DeleteSections(indexSet)
                expect(sut.capturedCalls).to(contain(expected))
            }

            it("updates table when data inserted") {
                changes.objectChanges = [.Insert(indexPathZero),.Insert(indexPathOne)]
                sut.apply( changes )
                
                let expected:TableViewInvocation = .InsertRowsAtIndexPaths(indexPaths:[indexPathZero,indexPathOne])
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("updates table when data deleted") {
                changes.objectChanges = [.Delete(indexPathZero)]
                sut.apply( changes )
                
                let expected:TableViewInvocation = .DeleteRowsAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("updates table when data moved") {
                changes.objectChanges = [.Move(from:indexPathZero,to:indexPathOne),.Move(from:indexPathTwo,to:indexPathThree)]
                sut.apply( changes )
                
                let expectedA:TableViewInvocation = .DeleteRowsAtIndexPaths(indexPaths:[indexPathZero,indexPathTwo])
                let expectedB:TableViewInvocation = .InsertRowsAtIndexPaths(indexPaths:[indexPathOne,indexPathThree])
                expect(sut.capturedCalls).to(contain(expectedA,expectedB))
            }

            it("updates table when data updated") {
                changes.objectChanges = [.Update(indexPathZero)]
                sut.apply( changes )
                
                let expected:TableViewInvocation = .ReloadRowsAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("doesn't update table when cell reloaded") {
                changes.objectChanges = [.CellConfigure( {} )]
                sut.apply(changes)
                
                let rejected:TableViewInvocation = .ReloadRowsAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).toNot(contain(rejected))
            }

            it("calls reload cell function when cell reloaded") {
                var calledReload = false
                changes.objectChanges = [.CellConfigure( {calledReload = true} )]
                sut.apply(changes)
                
                expect(calledReload).to(beTrue())
            }
            
            it("updates tables with mixed changes") {
                changes.objectChanges = [.Insert(indexPathTwo),.Delete(indexPathZero),.Insert(indexPathOne)]
                changes.insertedSections = indexSet
                let deleteIndexSet = NSMutableIndexSet(index: 1)
                changes.deletedSections = deleteIndexSet
                
                sut.apply( changes )
                
                let expected:[TableViewInvocation] = [.BeginUpdates,.DeleteSections(deleteIndexSet),.InsertSections(indexSet),.DeleteRowsAtIndexPaths(indexPaths:[indexPathZero]),.InsertRowsAtIndexPaths(indexPaths: [indexPathTwo,indexPathOne]),.EndUpdates]
                expect(sut.capturedCalls).to(equal(expected))
            }

        }
    }
}