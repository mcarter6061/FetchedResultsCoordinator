//  Copyright © 2016 CocoaPods. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator
import CoreData


struct ListItem:Equatable {
    var property: String?
}

func ==(lhs: ListItem, rhs: ListItem) -> Bool {
    return lhs.property == rhs.property
}



class SpyConfigurator<T>: TableCellConfigurator {

    func configureCell( cell: UITableViewCell, withObject object: T, atIndexPath indexPath: NSIndexPath ) {
        
    }
    
    func cellReuseIdentifierForObject( object: T, atIndexPath indexPath: NSIndexPath ) -> String {
        return "identifier"
    }

}

class ListTableSelectionTests: QuickSpec {
    
    override func spec() {
        
        describe("With a list based table view") {
            
            let indexPathZero = NSIndexPath( forRow:0, inSection:0 )
            let indexPathOne = NSIndexPath( forRow:1, inSection:0 )
            let indexPathTwo = NSIndexPath( forRow:2, inSection:0 )

            let item0 = ListItem( property: "item0" )
            let item1 = ListItem( property: "item1" )
            let item2 = ListItem( property: "item2" )
            let item3 = ListItem( property: "item3" )

            var sut: ListTableDataSource<ListItem,UITableViewCell>!
            var spyTableView: SpyTableView!
            var spyConfigurator: SpyConfigurator<ListItem>!
            
            beforeEach {
                spyTableView = SpyTableView()
                spyConfigurator = SpyConfigurator()
                let data = [item0,item1,item2]
                sut = ListTableDataSource( cellConfigurator: spyConfigurator, data: data )
            }
            
            it("selectedObjects returns selected object when there is one") {
                spyTableView.selectedRows = [indexPathOne]
                expect( sut.selectedObject(spyTableView)).to(equal(item1))
            }
            
            it("selectedObjects returns selected objects when there are more than one") {
                spyTableView.selectedRows = [indexPathZero,indexPathTwo]
                expect( sut.selectedObjects(spyTableView) ).to(contain(item0,item2))
            }
            
            it("selectedObjects returns nil when there are none") {
                expect( sut.selectedObjects(spyTableView) ).to(beEmpty())
            }
            
            it("selectObjects selects row for object") {
                sut.selectObjects(spyTableView, objects: [item0])
                XCTAssertTrue(spyTableView.capturedCalls.contains(.SelectRowAtIndexPath(indexPath:indexPathZero)))
            }
            
            it("selectObjects ignores object if it is not in datasource") {
                sut.selectObjects(spyTableView, objects: [item3])
                XCTAssertTrue(spyTableView.capturedCalls.isEmpty)
            }
            
            it("finds index path where object is in data") {
                expect( sut.indexPathForObject(item0)).to(equal(indexPathZero))
                expect( sut.indexPathForObject(item1)).to(equal(indexPathOne))
                expect( sut.indexPathForObject(item2)).to(equal(indexPathTwo))
            }

            it("doesn't find index path where object is not in data") {
                expect( sut.indexPathForObject(item3)).to(beNil())
            }

            it("doesn't find index path where data is empty") {
                sut = ListTableDataSource( cellConfigurator: spyConfigurator, data: [] )
                expect( sut.indexPathForObject(item0)).to(beNil())
            }
            
            it("find object where indexPath has an object") {
                expect(sut.objectAtIndexPath(indexPathOne )).to(equal(item1))
            }

//            let indexPathThree = NSIndexPath( forRow:3, inSection:0 )
//            it("crashes when there is no object for index path") {
//                expect(sut.objectAtIndexPath(indexPathThree)).to(beAKindOf(NoObject.self))
//            }

        }
        
    }
}


class FetchedItem: NSManagedObject, SpyFRCObject {
    @NSManaged var title: String?
    var indexPath: NSIndexPath?
    
    static var entityName: String { return "FetchedItem" }
}

class FetchedTableSelectionTests: QuickSpec {
    
    override func spec() {
        
        describe("With a list based table view") {
            
            let indexPathZero = NSIndexPath( forRow:0, inSection:0 )
            let indexPathOne = NSIndexPath( forRow:1, inSection:0 )
            let indexPathTwo = NSIndexPath( forRow:2, inSection:0 )
            
            var item0: FetchedItem!
            var item1: FetchedItem!
            var item2: FetchedItem!
            var item3: FetchedItem!

            var sut: FetchedTableDataSource<FetchedItem,UITableViewCell>!
            var spyTableView: SpyTableView!
            var spyConfigurator: SpyConfigurator<FetchedItem>!
            var spyFRC: SpyFRC<FetchedItem>!
            
            beforeEach {
                let context = ManagedObjectContextFactory.managedObjectContextOfInMemoryStoreTypeWithModel( "Test" )
                item0 =  NSEntityDescription.insertNewObjectForEntityForName(FetchedItem.entityName, inManagedObjectContext: context) as! FetchedItem
                item1 =  NSEntityDescription.insertNewObjectForEntityForName(FetchedItem.entityName, inManagedObjectContext: context) as! FetchedItem
                item2 =  NSEntityDescription.insertNewObjectForEntityForName(FetchedItem.entityName, inManagedObjectContext: context) as! FetchedItem
                item3 =  NSEntityDescription.insertNewObjectForEntityForName(FetchedItem.entityName, inManagedObjectContext: context) as! FetchedItem
                
                item0.indexPath = indexPathZero
                item1.indexPath = indexPathOne
                item2.indexPath = indexPathTwo
                
                spyTableView = SpyTableView()
                spyConfigurator = SpyConfigurator()
                spyFRC = SpyFRC()
                spyFRC.objects = [item0,item1,item2]
                sut = FetchedTableDataSource( cellConfigurator: spyConfigurator, fetchedResultsController: spyFRC )
            }
            
            it("selectedObjects returns selected object when there is one") {
                spyTableView.selectedRows = [indexPathOne]
                expect( sut.selectedObject(spyTableView)).to(equal(item1))
            }
            
            it("selectedObjects returns selected objects when there are more than one") {
                spyTableView.selectedRows = [indexPathZero,indexPathTwo]
                expect( sut.selectedObjects(spyTableView) ).to(contain(item0,item2))
            }
            
            it("selectedObjects returns nil when there are none") {
                expect( sut.selectedObjects(spyTableView) ).to(beEmpty())
            }
            
            it("selectObjects selects row for object") {
                sut.selectObjects(spyTableView, objects: [item0])
                XCTAssertTrue(spyTableView.capturedCalls.contains(.SelectRowAtIndexPath(indexPath:indexPathZero)))
            }
            
            it("selectObjects ignores object if it is not in datasource") {
                sut.selectObjects(spyTableView, objects: [item3])
                XCTAssertTrue(spyTableView.capturedCalls.isEmpty)
            }
            
            it("finds index path where object is in data") {
                expect( sut.indexPathForObject(item0)).to(equal(indexPathZero))
                expect( sut.indexPathForObject(item1)).to(equal(indexPathOne))
                expect( sut.indexPathForObject(item2)).to(equal(indexPathTwo))
            }
            
            it("doesn't find index path where object is not in data") {
                expect( sut.indexPathForObject(item3)).to(beNil())
            }
            
            it("doesn't find index path where data is empty") {
                spyFRC.objects = []
                sut = FetchedTableDataSource( cellConfigurator: spyConfigurator, fetchedResultsController: spyFRC )
                expect( sut.indexPathForObject(item0)).to(beNil())
            }
            
            it("find object where indexPath has an object") {
                expect(sut.objectAtIndexPath(indexPathOne )).to(equal(item1))
            }
            
        }
    }
}