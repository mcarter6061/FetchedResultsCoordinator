//  Copyright © 2015 Mark Carter. All rights reserved.

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import "FetchedResultsCoordinator-swift.h"
#import <CoreData/CoreData.h>


SpecBegin(SimpleTableDataSource)

describe(@"SimpleTableDataSource", ^{

    NSString *reuseIdentifier = @"reuseIdentifier";

    __block SimpleTableDataSource *dataSource;
    __block id mockFRC;
    __block id mockCellConfigurator;
    __block id mockTableView;
    __block id mockObject;
    
    beforeEach(^{
        mockFRC = OCMClassMock([NSFetchedResultsController class]);
        mockTableView = OCMClassMock([UITableView class]);
        mockObject = OCMClassMock([NSManagedObject class]);
        
        mockCellConfigurator = OCMProtocolMock(@protocol(TableCellConfigurator));
        OCMStub([mockCellConfigurator cellReuseIdentifierForObject:mockObject]).andReturn(reuseIdentifier);
        
        dataSource = [[SimpleTableDataSource alloc] initWithConfigurator:mockCellConfigurator fetchedResultsController:mockFRC];
    });
    
    it(@"should create a data source", ^{
        expect(dataSource).notTo.beNil();
    });

    it(@"should have the same number of sections as the FRC", ^{
        id mockSection = OCMProtocolMock(@protocol(NSFetchedResultsSectionInfo));
        OCMStub([mockFRC sections]).andReturn(@[mockSection]);
        expect([dataSource numberOfSectionsInTableView:mockTableView]).to.equal(1);
    });

    it(@"should match the FRC number of objects in section", ^{
        id mockSection = OCMProtocolMock(@protocol(NSFetchedResultsSectionInfo));
        OCMStub([mockSection numberOfObjects]).andReturn(4);
        OCMStub([mockFRC sections]).andReturn(@[mockSection]);
        
        expect([dataSource tableView:mockTableView numberOfRowsInSection:0]).to.equal(4);
    });

    it(@"should configure the cell when cellForRowAtIndexPath called", ^{
        NSIndexPath *zeroIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        OCMStub([mockFRC objectAtIndexPath:zeroIndexPath]).andReturn(mockObject);
        
        id mockCell = OCMClassMock([UITableViewCell class]);
        OCMStub([mockTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:zeroIndexPath]).andReturn(mockCell);
        
        [dataSource tableView:mockTableView cellForRowAtIndexPath:zeroIndexPath];
        OCMVerify([mockCellConfigurator configureCell:mockCell withObject:mockObject]);
    });

    context(@"with two sections", ^{
        
        beforeEach(^{
            id mockSection = OCMProtocolMock(@protocol(NSFetchedResultsSectionInfo));
            OCMStub([mockSection name]).andReturn(@"A Section");
            OCMStub([mockSection numberOfObjects]).andReturn(4);
            
            id mockAnotherSection = OCMProtocolMock(@protocol(NSFetchedResultsSectionInfo));
            OCMStub([mockAnotherSection name]).andReturn(@"Z Section");
            OCMStub([mockAnotherSection numberOfObjects]).andReturn(2);
            
            NSArray *sections = @[mockSection,mockAnotherSection];
            OCMStub([mockFRC sections]).andReturn(sections);
        });
        
        it(@"should have the correct number of rows with multiple sections", ^{
            expect([dataSource tableView:mockTableView numberOfRowsInSection:0]).to.equal(4);
            expect([dataSource tableView:mockTableView numberOfRowsInSection:1]).to.equal(2);
        });

        it(@"should use basic headers if configured to", ^{
            dataSource.systemHeaders = YES;
            expect([dataSource tableView:mockTableView titleForHeaderInSection:0]).to.equal(@"A Section");
            expect([dataSource tableView:mockTableView titleForHeaderInSection:1]).to.equal(@"Z Section");
        });

        it(@"should not use basic headers if configured not to", ^{
            dataSource.systemHeaders = NO;
            expect([dataSource tableView:mockTableView titleForHeaderInSection:0]).to.beNil();
            expect([dataSource tableView:mockTableView titleForHeaderInSection:1]).to.beNil();
        });

    });


    it(@"should have the same index titles as the FRC if configured to show indexes", ^{
        NSArray *seciontIndexTitles = @[@"A",@"B",@"C"];
        OCMStub([mockFRC sectionIndexTitles]).andReturn(seciontIndexTitles);
        
        dataSource.tableIndex = YES;
        expect([dataSource sectionIndexTitlesForTableView:mockTableView]).to.equal(seciontIndexTitles);
    });
    
    it(@"should not show table index if configured not to", ^{
        dataSource.tableIndex = NO;
        expect([dataSource sectionIndexTitlesForTableView:mockTableView]).to.beNil();
    });
    
});

SpecEnd