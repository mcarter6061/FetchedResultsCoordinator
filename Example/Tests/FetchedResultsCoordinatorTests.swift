//  Copyright © 2016 Mark Carter. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator
import CoreData

class Item: NSManagedObject {
    var property: String?
}

class SpyFRC: NSFetchedResultsController {
    
    var performFetchedCalled = false

    override func performFetch() throws {
        performFetchedCalled = true
    }
    
}

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


class FetchedResultsCoordinatorTests: QuickSpec {
    
    override func spec() {
        
        describe("the 'Documentation' directory") {
            
            let indexPathZero = NSIndexPath( forRow:0, inSection:0 )
            let indexPathOne = NSIndexPath( forRow:1, inSection:0 )
            let mockObject = NSManagedObject()

            let spyFRC = SpyFRC()
            let spyCoordinatee = SpyCoordinatee()
            var updateCellCalled = false
            
            let sut = FetchedResultsCoordinator<Item>( coordinatee: spyCoordinatee, fetchedResultsController: spyFRC, updateCell: { _ in updateCellCalled = true} )

            it("reloads data") {
                sut.loadData()
                expect(spyFRC.performFetchedCalled).to(beTrue())
                expect(spyCoordinatee.reloadDataCalled).to(beTrue())
            }
            
            it("applies updates to table when data inserted") {
                sut.controller(spyFRC, didChangeObject: mockObject, atIndexPath: nil, forChangeType: .Insert, newIndexPath: indexPathZero)
                sut.controllerDidChangeContent(spyFRC)
                
                expect(spyCoordinatee.appliedChangeSet!.objectChanges).to(contain(FetchedObjectChange.Insert(indexPathZero)))
            }
            
            
        }

    }
    
    
}
