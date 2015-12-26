//  Copyright © 2015 Mark Carter. All rights reserved.

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <CoreData/CoreData.h>
#import "Expecta+OCMock.h"

#import "FetchedResultsCoordinator-swift.h"


SpecBegin(FetchedResultsCoordinatorCollectionTests)

describe(@"FetchedResultsCoordinatorCollectionTests", ^{
    
    __block id mockCollectionView;
    __block id mockFRC;
    __block id mockObject;
    
    id indexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
    id indexPathOne = [NSIndexPath indexPathForRow:1 inSection:0];
    __block FetchedResultsCoordinator *coordinator;
    
    beforeEach(^{
        mockCollectionView = OCMClassMock([UICollectionView class]);
        mockFRC = OCMClassMock([NSFetchedResultsController class]);
        OCMStub([mockFRC performFetch:[OCMArg anyObjectRef]]).andReturn(YES);

        mockObject = OCMClassMock([NSManagedObject class]);
    });
    
    it(@"creates a FetchedResultsCoordinator for collections", ^{
        expect([[FetchedResultsCoordinator alloc] initWithCollectionView:mockCollectionView fetchedResultsController:mockFRC cellConfigurator:nil]).toNot.beNil();
    });
    
    describe(@"with a collection view based Coordinator", ^{
        
        beforeEach(^{
            coordinator = [[FetchedResultsCoordinator alloc] initWithCollectionView:mockCollectionView fetchedResultsController:mockFRC cellConfigurator:nil];
            OCMStub([mockCollectionView performBatchUpdates:[OCMArg invokeBlock] completion:nil]);
            [coordinator controllerWillChangeContent:mockFRC];
        });
        
        it(@"updates collection when data inserted", ^{
            OCMExpect([mockCollectionView insertItemsAtIndexPaths:@[indexPathZero]]);
            
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:nil forChangeType:NSFetchedResultsChangeInsert newIndexPath:indexPathZero];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockCollectionView);
        });
        
        it(@"updates collection when data deleted", ^{
            OCMExpect([mockCollectionView deleteItemsAtIndexPaths:@[indexPathZero]]);
            
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockCollectionView);
        });
        
        it(@"updates collection when data moved", ^{
            OCMExpect([mockCollectionView deleteItemsAtIndexPaths:@[indexPathZero]]);
            OCMExpect([mockCollectionView insertItemsAtIndexPaths:@[indexPathOne]]);
            
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeMove newIndexPath:indexPathOne];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockCollectionView);
        });
        
        it(@"updates collection when data updated", ^{
            OCMExpect([mockCollectionView reloadItemsAtIndexPaths:@[indexPathZero]]);
            
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockCollectionView);
        });
        
        it(@"updates collection when section inserted", ^{
            OCMExpect([mockCollectionView insertSections:[NSIndexSet indexSetWithIndex:0]]);
            
            [coordinator controllerWillChangeContent:mockFRC];
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeInsert];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockCollectionView);
        });
        
        it(@"updates collection when section deleted", ^{
            OCMExpect([mockCollectionView deleteSections:[NSIndexSet indexSetWithIndex:0]]);
            
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeDelete];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockCollectionView);
        });
        
        it(@"ignores invalid section changes", ^{
            [[mockCollectionView reject] insertSections:[NSIndexSet indexSetWithIndex:0]];
            [[mockCollectionView reject] deleteSections:[NSIndexSet indexSetWithIndex:0]];
            
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeMove];
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:1 forChangeType:NSFetchedResultsChangeUpdate];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockCollectionView);
        });
        
        describe(@"with section changes", ^{
            
            beforeEach(^{
                [[mockCollectionView reject] insertItemsAtIndexPaths:OCMOCK_ANY];
                [[mockCollectionView reject] deleteItemsAtIndexPaths:OCMOCK_ANY];
                [[mockCollectionView reject] moveItemAtIndexPath:OCMOCK_ANY toIndexPath:OCMOCK_ANY];
                [[mockCollectionView reject] reloadItemsAtIndexPaths:OCMOCK_ANY];
            });
            
            it(@"ignores changes for object deleted in a deleted section", ^{
                
                OCMExpect([mockCollectionView deleteSections:[NSIndexSet indexSetWithIndex:0]]);
                
                [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeDelete];
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
                [coordinator controllerDidChangeContent:mockFRC];
                
                OCMVerifyAll(mockCollectionView);
            });
            
            
            it(@"ignores changes for object inserted in an inserted section", ^{
                OCMExpect([mockCollectionView insertSections:[NSIndexSet indexSetWithIndex:0]]);
                
                [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeInsert];
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:nil forChangeType:NSFetchedResultsChangeInsert newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [coordinator controllerDidChangeContent:mockFRC];
                
                OCMVerifyAll(mockCollectionView);
            });
            
            it(@"ignore move from a deleted section into a inserted section", ^{
                // ie move only item out of a section into a new section
                OCMExpect([mockCollectionView deleteSections:[NSIndexSet indexSetWithIndex:0]]);
                OCMExpect([mockCollectionView insertSections:[NSIndexSet indexSetWithIndex:0]]);
                
                [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeInsert];
                [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeDelete];
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forChangeType:NSFetchedResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [coordinator controllerDidChangeContent:mockFRC];
                
                OCMVerifyAll(mockCollectionView);
            });
        });
        
        it(@"ignore delete item part of move when move from a deleted section", ^{
            OCMExpect([mockCollectionView deleteSections:[NSIndexSet indexSetWithIndex:0]]);
            OCMExpect([mockCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]]);
            
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeDelete];
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:[NSIndexPath indexPathForRow:5 inSection:1] forChangeType:NSFetchedResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [coordinator controllerDidChangeContent:mockFRC];
            
            OCMVerifyAll(mockCollectionView);
        });
        
        it(@"ignore insert item part of move when moving to a inserted section", ^{
            OCMExpect([mockCollectionView insertSections:[NSIndexSet indexSetWithIndex:0]]);
            OCMExpect([mockCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:1]]]);
            
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeInsert];
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:[NSIndexPath indexPathForRow:5 inSection:1] forChangeType:NSFetchedResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [coordinator controllerDidChangeContent:mockFRC];
            
            OCMVerifyAll(mockCollectionView);
        });

        it(@"ignores changes when paused", ^{
            coordinator.paused = YES;
            
            OCMVerify([mockFRC setDelegate:nil]);
        });
        
        it(@"receives updates after being unpaused", ^{
            coordinator.paused = YES;
            coordinator.paused = NO;
            
            OCMExpect([mockCollectionView deleteItemsAtIndexPaths:@[indexPathZero]]);
            
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
            [coordinator controllerDidChangeContent:mockFRC];
            
            OCMVerifyAll(mockCollectionView);
        });
        
        describe(@"with a cellConfigurator", ^{
            
            __block id mockCollectionCellConfigurator = OCMProtocolMock(@protocol(CollectionCellConfigurator));
            
            beforeEach(^{
                coordinator = [[FetchedResultsCoordinator alloc] initWithCollectionView:mockCollectionView fetchedResultsController:mockFRC cellConfigurator:mockCollectionCellConfigurator];
            });
            
            it(@"reconfigures cell when data updated", ^{
                id mockCell = OCMClassMock([UITableViewCell class]);
                OCMStub([mockCollectionView cellForItemAtIndexPath:indexPathZero]).andReturn(mockCell);
                
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
                [coordinator controllerDidChangeContent:mockFRC];
                OCMVerify([mockCollectionCellConfigurator configureCell:mockCell withManagedObject:mockObject]);
            });
            
            it(@"does not update not visible cells", ^{
                OCMStub([mockCollectionView cellForItemAtIndexPath:indexPathZero]); // returns nil
                
                [[mockCollectionCellConfigurator reject] configureCell:OCMOCK_ANY withManagedObject:mockObject];
                
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
                [coordinator controllerDidChangeContent:mockFRC];
            });
            
        });
        
    });
    
    it(@"reloads data when unpaused", ^{
        coordinator = [[FetchedResultsCoordinator alloc] initWithCollectionView:mockCollectionView fetchedResultsController:mockFRC cellConfigurator:nil];
        
        coordinator.paused = YES;
        coordinator.paused = NO;
        
        OCMVerify([mockCollectionView reloadData]);
        OCMVerify([mockFRC performFetch:[OCMArg anyObjectRef]]);
    });
    
    it(@"starts observing changes when unpaused", ^{
        coordinator = [[FetchedResultsCoordinator alloc] initWithCollectionView:mockCollectionView fetchedResultsController:mockFRC cellConfigurator:nil];
        
        coordinator.paused = YES;
        coordinator.paused = NO;
        
        OCMVerify([mockFRC setDelegate:coordinator]);
    });

});

SpecEnd
