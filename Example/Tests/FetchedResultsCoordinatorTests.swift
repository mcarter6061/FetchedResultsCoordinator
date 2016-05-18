//  Copyright © 2016 Mark Carter. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator
import CoreData

class MockItem: NSManagedObject, SpyFRCObject {
    var indexPath: NSIndexPath?
}

class FetchedResultsCoordinatorTests: QuickSpec {
    
    override func spec() {
        
        describe("with a FetchedResultsCoordinator") {
            
            let indexPathZero = NSIndexPath( forRow:0, inSection:0 )
            let indexPathOne = NSIndexPath( forRow:1, inSection:0 )
            let mockObject = NSManagedObject()

            let spyFRC:SpyFRC<MockItem> = SpyFRC()
            let spyCoordinatee = SpyCoordinatee()
            var updateCellCalled = false
            
            let sut = FetchedResultsCoordinator<MockItem>( coordinatee: spyCoordinatee, fetchedResultsController: spyFRC, updateCell: { _ in updateCellCalled = true} )

            it("reloads data") {
                sut.loadData()
                expect(spyFRC.performFetchedCalled).to(beTrue())
                expect(spyCoordinatee.reloadDataCalled).to(beTrue())
            }
            
            it("applies updates to table when data inserted") {
                sut.controller(spyFRC, didChangeObject: mockObject, atIndexPath: nil, forChangeType: .Insert, newIndexPath: indexPathZero)
                sut.controllerDidChangeContent(spyFRC)
                
                expect(spyCoordinatee.appliedChangeSet).toNot(beNil())
                let expected:FetchedObjectChange = FetchedObjectChange.Insert(indexPathZero)
                expect(spyCoordinatee.appliedChangeSet!.objectChanges).to(contain(expected))
            }
            
        }

    }
    
}
