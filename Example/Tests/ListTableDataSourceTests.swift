//  Copyright © 2016 CocoaPods. All rights reserved.

import XCTest
import Quick
import Nimble
@testable import FetchedResultsCoordinator

class ListTableDataSourceTests: QuickSpec {
    
    override func spec() {
        
        describe("with a ListTableDataSource") {
            
            let indexPathZero = NSIndexPath( forRow:0, inSection:0 )

            var spyConfigurator: SpyConfigurator<ListItem>!
            var data: [ListItem]!
            var spyTableView: SpyTableView!
            var sut: ListTableDataSource<ListItem,UITableViewCell>!
            let item0 = ListItem()
            let item1 = ListItem()
            let item2 = ListItem()
            
            beforeEach {
                spyTableView = SpyTableView()
                spyConfigurator = SpyConfigurator<ListItem>()
                data = [item0,item1,item2]
                sut = ListTableDataSource(cellConfigurator: spyConfigurator, data: data)
            }
            
            it("only has one section") {
                expect( sut.numberOfSectionsInTableView(spyTableView) ).to(equal(1))
            }
            
            it("has the correct number of rows") {
                expect(sut.tableView(spyTableView, numberOfRowsInSection: 1)).to(equal(3))
            }
            
            it("has zero rows when data is empty") {
                sut = ListTableDataSource(cellConfigurator: spyConfigurator, data: [])
                expect(sut.tableView(spyTableView, numberOfRowsInSection: 1)).to(equal(0))
            }
            
            
            it("checks for cell identifier when returning cell") {
                
                spyConfigurator.reuseIdentifier = "Identifier"
                spyTableView.cell = UITableViewCell()
                
                sut.tableView(spyTableView, cellForRowAtIndexPath: indexPathZero)
                
                expect(spyConfigurator.capturedCalls).to(contain(SpyConfiguratorInvocation.CellReuseIdentifierForObject(item0, indexPathZero)))
            }
            
            it("configures cell when returning cell") {
                spyConfigurator.reuseIdentifier = "Identifier"
                let expectedCell = UITableViewCell()
                spyTableView.cell = expectedCell
                
                sut.tableView(spyTableView, cellForRowAtIndexPath: indexPathZero)
                
                expect(spyConfigurator.capturedCalls).to(contain(SpyConfiguratorInvocation.ConfigureCell(expectedCell, item0, indexPathZero)))
                print(spyConfigurator.capturedCalls)
            }
            
            it("has section title when default section title set") {
                let expectedSectionTitle = "DefaultSectionTitle"
                sut.defaultSectionTitle = expectedSectionTitle
                expect(sut.tableView(spyTableView, titleForHeaderInSection: 0)).to(equal(expectedSectionTitle))
            }
            
            it("does not have section title when default section title is nil") {
                sut.defaultSectionTitle = nil
                expect(sut.tableView(spyTableView, titleForHeaderInSection: 0)).to(beNil())
            }
            
        }
        
    }
    
}

