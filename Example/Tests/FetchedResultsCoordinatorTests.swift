//  Copyright © 2016 Mark Carter. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator
import CoreData

class Item: NSManagedObject {
    var property: String?
}

class MockTableView: UITableView {
    
    var applyCalled: Bool = false
    var reloadCalled: Bool = false
    var changeSet: ChangeSet?
    
    override func reloadData() {
      reloadCalled = true
    }
    
//    func apply( changeSet: ChangeSet, applyUpdate: ApplyUpdateChange? ) {
//        applyCalled = true
//        self.changeSet = changeSet
//    }
}

class MockConfigurator: TableCellConfigurator {
    
    func configureCell( cell: UITableViewCell, withManagedObject managedObject: Item ) {
        
    }
    
    func cellReuseIdentifierForManagedObject( managedObject: Item ) -> String {
        return "Dummy"
    }

}

class FetchedResultsCoordinatorTests: QuickSpec {
    
    override func spec() {
        
        describe("the 'Documentation' directory") {
            
            let fetchedResultsController = NSFetchedResultsController()
            let tableView = UITableView()
            let mockConfigurator = MockConfigurator()
            
            let sut = FetchedResultsCoordinator<Item>( tableView: tableView, fetchedResultsController: fetchedResultsController, cellConfigurator: mockConfigurator )
//            let sut = FetchedResultsCoordinator<Item>( tableView: tableView, fetchedResultsController: fetchedResultsController, cellConfigurator: nil )
//            public init<U:TableCellConfigurator where U.ManagedObjectType == ManagedObjectType>( tableView: UITableView, fetchedResultsController: NSFetchedResultsController, cellConfigurator: U? ) {

            it("reloads data") {
                sut.loadData()
                
//                expect(sut).to(contain("Organized Tests with Quick Examples and Example Groups"))
//                expect(sections).to(contain("Installing Quick"))
            }
            
//            context("if it doesn't have what you're looking for") {
//                it("needs to be updated") {
//                    let you = You(awesome: true)
//                    expect{you.submittedAnIssue}.toEventually(beTruthy())
//                }
//            }
        }

    }
    
    
}
