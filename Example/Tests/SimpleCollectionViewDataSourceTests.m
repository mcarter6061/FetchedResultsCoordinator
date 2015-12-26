//  Copyright © 2015 Mark Carter. All rights reserved.

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <CoreData/CoreData.h>

#import "FetchedResultsCoordinator-swift.h"


NSString *reuseIdentifier = @"reuseIdentifier";

SpecBegin(SimpleCollectionDataSourceTests)

describe(@"SimpleCollectionDataSourceTests", ^{

    __block SimpleCollectionDataSource *dataSource;
    __block id mockFRC;
    __block id mockCellConfigurator;
    __block id mockSuppViewConfigurator;
    __block id mockCollectionView;
    
    beforeEach(^{
        
        mockFRC = OCMClassMock([NSFetchedResultsController class]);
        mockCollectionView = OCMClassMock([UICollectionView class]);
        
        mockCellConfigurator = OCMProtocolMock(@protocol(CollectionCellConfigurator));
        
        mockSuppViewConfigurator = OCMProtocolMock(@protocol(CollectionViewSupplementaryViewConfigurator));
        
        dataSource = [[SimpleCollectionDataSource alloc] initWithFetchedResultsController:mockFRC cellConfigurator:mockCellConfigurator supplementaryViewConfigurator:mockSuppViewConfigurator];
        
    });
    
    it(@"creates a SimpleCollectionDataSource", ^{
        expect(dataSource).toNot.beNil;
    });
    
    it(@"has the correct number of sections", ^{
        id mockSection = [OCMockObject niceMockForProtocol:@protocol(NSFetchedResultsSectionInfo)];
        NSArray *sections = @[mockSection,mockSection];
        OCMStub([mockFRC sections]).andReturn(sections);

        expect([dataSource numberOfSectionsInCollectionView:mockCollectionView]).to.equal(2);
    });
    
    it(@"has the correct number of objects for a section", ^{
        id mockSection = [OCMockObject niceMockForProtocol:@protocol(NSFetchedResultsSectionInfo)];
        OCMStub([mockSection numberOfObjects]).andReturn(3);
        
        NSArray *sections = @[mockSection];
        OCMStub([mockFRC sections]).andReturn(sections);

        expect([dataSource collectionView:mockCollectionView numberOfItemsInSection:0]).to.equal(3);
    });
    
    it(@"calls mockCellConfigurator when collectionView:cellForItemAtIndexPath: called", ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

        id mockCell = [OCMockObject niceMockForClass:[UICollectionViewCell class]];
        OCMStub([mockCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath]).andReturn(mockCell);

        id mockObject = [OCMockObject niceMockForClass:[NSManagedObject class]];
        OCMStub([mockFRC objectAtIndexPath:indexPath]).andReturn(mockObject);

        OCMExpect([mockCellConfigurator cellReuseIdentifierForManagedObject:OCMOCK_ANY]).andReturn(reuseIdentifier);
        OCMExpect([mockCellConfigurator configureCell:mockCell withManagedObject:mockObject]);
        [dataSource collectionView:mockCollectionView cellForItemAtIndexPath:indexPath];
        OCMVerifyAll(mockCellConfigurator);
    });
        
});

SpecEnd

//@interface SimpleCollectionDataSource : NSObject <UICollectionViewDataSource>
//- (nonnull instancetype)initWithFetchedResultsController:(NSFetchedResultsController * __nonnull)fetchedResultsController cellConfigurator:(id <CollectionCellConfigurator> __nonnull)cellConfigurator supplementaryViewConfigurator:(id <CollectionViewSupplementaryViewConfigurator> __nullable)supplementaryViewConfigurator OBJC_DESIGNATED_INITIALIZER;

//- (id <NSFetchedResultsSectionInfo> __nullable)sectionInfoForSection:(NSInteger)sectionIndex;

//- (NSInteger)collectionView:(UICollectionView * __nonnull)collectionView numberOfItemsInSection:(NSInteger)section;

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView * __nonnull)collectionView;

//- (UICollectionViewCell * __nonnull)collectionView:(UICollectionView * __nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * __nonnull)indexPath;

//- (BOOL)respondsToSelector:(SEL __null_unspecified)aSelector;
//- (UICollectionReusableView * __nonnull)collectionView:(UICollectionView * __nonnull)collectionView viewForSupplementaryElementOfKind:(NSString * __nonnull)kind atIndexPath:(NSIndexPath * __nonnull)indexPath;
//@end

//protocol NSFetchedResultsSectionInfo
//
///* Name of the section
// */
//@property (nonatomic, readonly) NSString *name;
//
///* Title of the section (used when displaying the index)
// */
//@property (nullable, nonatomic, readonly) NSString *indexTitle;
//
///* Number of objects in section
// */
//@property (nonatomic, readonly) NSUInteger numberOfObjects;
//
///* Returns the array of objects in the section.
// */
//@property (nullable, nonatomic, readonly) NSArray *objects;
//
//@end // NSFetchedResultsSectionInfo
//
