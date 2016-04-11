//  Copyright © 2016 Mark Carter. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator
import CoreData

enum TableViewInvocation: Equatable {
    case InsertRowsAtIndexPaths( indexPaths:[NSIndexPath] )
    case DeleteRowsAtIndexPaths( indexPaths:[NSIndexPath] )
    case ReloadRowsAtIndexPaths( indexPaths: [NSIndexPath] )
    case MoveRowAtIndexPath(indexPath: NSIndexPath, newIndexPath: NSIndexPath)
}

func ==(lhs: TableViewInvocation, rhs: TableViewInvocation) -> Bool {
    switch (lhs,rhs) {
    case let (.InsertRowsAtIndexPaths(lhsIndexPaths), .InsertRowsAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.DeleteRowsAtIndexPaths(lhsIndexPaths), .DeleteRowsAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.ReloadRowsAtIndexPaths(lhsIndexPaths), .ReloadRowsAtIndexPaths(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    case let (.MoveRowAtIndexPath(lhsIndexPaths), .MoveRowAtIndexPath(rhsIndexPaths)) where lhsIndexPaths == rhsIndexPaths:return true
    default: return false
    }
}


class SpyTableView: UITableView {
    var capturedCalls: [TableViewInvocation] = []
    
    override func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        capturedCalls.append( .InsertRowsAtIndexPaths( indexPaths: indexPaths ) )
    }
    
    override func deleteRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        capturedCalls.append( .DeleteRowsAtIndexPaths(indexPaths: indexPaths))
    }
    
    override func reloadRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        capturedCalls.append( .ReloadRowsAtIndexPaths(indexPaths: indexPaths))
    }
    
    override func moveRowAtIndexPath(indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        capturedCalls.append(.MoveRowAtIndexPath(indexPath: indexPath, newIndexPath: newIndexPath))
    }
}


class TableViewTests: QuickSpec {
    
    override func spec() {
        
        describe("With a table view") {
            
            var changes:ChangeSet = ChangeSet()
            let indexPathZero = NSIndexPath( forRow:0, inSection:0 )
            let indexPathOne = NSIndexPath( forRow:1, inSection:0 )
            let mockObject = NSManagedObject()

            let sut = SpyTableView()

            it("reloads data") {
                sut.reloadData()
            }
            
            it("updates table when data inserted") {
                changes.insertedItems = [indexPathZero]
                sut.apply( changes )
                
                let expected:TableViewInvocation = .InsertRowsAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("updates collection when data deleted") {
                changes.deletedItems = [indexPathZero]
                sut.apply( changes )
                
                let expected:TableViewInvocation = .DeleteRowsAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).to(contain(expected))
            }
            
            it("updates collection when data moved") {
                changes.movedItems = [(fromIndexPath:indexPathZero,toIndexPath:indexPathOne)]
                sut.apply( changes )
                
                let expectedA:TableViewInvocation = .DeleteRowsAtIndexPaths(indexPaths:[indexPathZero])
                let expectedB:TableViewInvocation = .InsertRowsAtIndexPaths(indexPaths:[indexPathOne])
                expect(sut.capturedCalls).to(contain(expectedA,expectedB))
            }

            it("updates collection when data updated") {
                changes.updatedItems = [(indexPathZero,mockObject)]
                sut.apply( changes )
                
                let expected:TableViewInvocation = .ReloadRowsAtIndexPaths(indexPaths:[indexPathZero])
                expect(sut.capturedCalls).to(contain(expected))
            }

            // TODO: finish porting over tests from tableview objc tests.
        }
    }
}