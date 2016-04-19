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


class FetchedResultsCoordinatorTests: QuickSpec {
    
    override func spec() {
        
        describe("with a FetchedResultsCoordinator") {
            
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
                
                expect(spyCoordinatee.appliedChangeSet).toNot(beNil())
                let expected:FetchedObjectChange = FetchedObjectChange.Insert(indexPathZero)
                expect(spyCoordinatee.appliedChangeSet!.objectChanges).to(contain(expected))
            }
            
        }

    }
    
    
}
