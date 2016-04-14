//  Copyright © 2015 Mark Carter. All rights reserved.

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <CoreData/CoreData.h>

#import "FetchedResultsCoordinator-swift.h"


SpecBegin(FetchedResultsCoordinatorTableTests)

describe(@"FetchedResultsCoordinatorTableTests", ^{
    
    __block id mockTableView;
    __block id mockFRC;
    __block id mockObject;
    
    id indexPathZero = [NSIndexPath indexPathForRow:0 inSection:0];
    id indexPathOne = [NSIndexPath indexPathForRow:1 inSection:0];
    __block FetchedResultsCoordinator *coordinator;
    
    beforeEach(^{
        mockTableView = OCMClassMock([UITableView class]);
        mockFRC = OCMClassMock([NSFetchedResultsController class]);
        OCMStub([mockFRC performFetch:[OCMArg anyObjectRef]]).andReturn(YES);

        mockObject = OCMClassMock([NSManagedObject class]);
    });
    
    it(@"creates a FetchedResultsCoordinator for tables", ^{
        expect([[FetchedResultsCoordinator alloc] initWithTableView:mockTableView fetchedResultsController:mockFRC updateCell:nil]).toNot.beNil();
    });
    
    describe(@"with a tableView based Coordinator", ^{
        
        beforeEach(^{
            coordinator = [[FetchedResultsCoordinator alloc] initWithTableView:mockTableView fetchedResultsController:mockFRC updateCell:nil];
            OCMExpect([mockTableView beginUpdates]);
            OCMExpect([mockTableView endUpdates]);
            [coordinator controllerWillChangeContent:mockFRC];
        });
        
        it(@"updates table when data inserted", ^{
            OCMExpect([mockTableView insertRowsAtIndexPaths:@[indexPathZero] withRowAnimation:UITableViewRowAnimationFade]);
            
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:nil forChangeType:NSFetchedResultsChangeInsert newIndexPath:indexPathZero];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockTableView);
        });
        it(@"updates table when data deleted", ^{
            OCMExpect([mockTableView deleteRowsAtIndexPaths:@[indexPathZero] withRowAnimation:UITableViewRowAnimationFade]);
            
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockTableView);
        });
        
        it(@"updates table when data moved", ^{
            OCMExpect([mockTableView deleteRowsAtIndexPaths:@[indexPathZero] withRowAnimation:UITableViewRowAnimationFade]);
            OCMExpect([mockTableView insertRowsAtIndexPaths:@[indexPathOne] withRowAnimation:UITableViewRowAnimationFade]);

            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeMove newIndexPath:indexPathOne];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockTableView);
        });

        it(@"updates table when data updated", ^{
            OCMExpect([mockTableView reloadRowsAtIndexPaths:@[indexPathZero] withRowAnimation:UITableViewRowAnimationNone]);
            
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockTableView);
        });
        
        
        it(@"updates table when section inserted", ^{
            OCMExpect([mockTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);
            
            [coordinator controllerWillChangeContent:mockFRC];
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeInsert];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockTableView);
        });
        
        it(@"updates table when section deleted", ^{
            OCMExpect([mockTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);

            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeDelete];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockTableView);
        });
        
        it(@"ignores invalid section changes", ^{
            [[mockTableView reject] insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [[mockTableView reject] deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeMove];
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:1 forChangeType:NSFetchedResultsChangeUpdate];
            [coordinator controllerDidChangeContent:mockFRC];
            OCMVerifyAll(mockTableView);
        });
        
        context(@"with section changes", ^{
            
            beforeEach(^{
                [[[mockTableView reject] ignoringNonObjectArgs] insertRowsAtIndexPaths:OCMOCK_ANY withRowAnimation:UITableViewRowAnimationFade];
                [[[mockTableView reject] ignoringNonObjectArgs] deleteRowsAtIndexPaths:OCMOCK_ANY withRowAnimation:UITableViewRowAnimationFade];
                [[mockTableView reject] moveRowAtIndexPath:OCMOCK_ANY toIndexPath:OCMOCK_ANY];
                [[[mockTableView reject] ignoringNonObjectArgs] reloadRowsAtIndexPaths:OCMOCK_ANY withRowAnimation:UITableViewRowAnimationFade];
            });

            it(@"ignores changes for object deleted in a deleted section", ^{
                
                OCMExpect([mockTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);
                
                [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeDelete];
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
                [coordinator controllerDidChangeContent:mockFRC];
                
                OCMVerifyAll(mockTableView);
            });

            it(@"ignores changes for object inserted in an inserted section", ^{
                
                OCMExpect([mockTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);
                
                [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeInsert];
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:nil forChangeType:NSFetchedResultsChangeInsert newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [coordinator controllerDidChangeContent:mockFRC];

                OCMVerifyAll(mockTableView);
            });
            
            it(@"ignore move from a deleted section into a inserted section", ^{
                // ie move only item out of a section into a new section
                OCMExpect([mockTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);
                OCMExpect([mockTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);
                
                [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeInsert];
                [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeDelete];
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forChangeType:NSFetchedResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [coordinator controllerDidChangeContent:mockFRC];
                
                OCMVerifyAll(mockTableView);
            });
        });
        
        it(@"ignore delete item part of move when move from a deleted section", ^{
            OCMExpect([mockTableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);
            OCMExpect([mockTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade]);
            
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeDelete];
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:[NSIndexPath indexPathForRow:5 inSection:1] forChangeType:NSFetchedResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [coordinator controllerDidChangeContent:mockFRC];
            
            OCMVerifyAll(mockTableView);
        });
        
        it(@"ignore insert item part of move when moving to a inserted section", ^{
            OCMExpect([mockTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade]);
            OCMExpect([mockTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:1]]  withRowAnimation:UITableViewRowAnimationFade]);
            
            [coordinator controller:mockFRC didChangeSection:OCMOCK_ANY atIndex:0 forChangeType:NSFetchedResultsChangeInsert];
            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:[NSIndexPath indexPathForRow:5 inSection:1] forChangeType:NSFetchedResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [coordinator controllerDidChangeContent:mockFRC];
            
            OCMVerifyAll(mockTableView);
        });
        
        it(@"ignores changes when paused", ^{
            coordinator.paused = YES;
            
            OCMVerify([mockFRC setDelegate:nil]);
        });

        it(@"receives updates after being unpaused", ^{
            coordinator.paused = YES;
            coordinator.paused = NO;
            
            OCMExpect([mockTableView deleteRowsAtIndexPaths:@[indexPathZero] withRowAnimation:UITableViewRowAnimationFade]);

            [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeDelete newIndexPath:nil];
            [coordinator controllerDidChangeContent:mockFRC];
            
            OCMVerifyAll(mockTableView);
        });

        
        describe(@"with a cellConfigurator", ^{
            
            __block BOOL updateCellInvoked = false;
            __block id mockUpdateCell = ^(NSIndexPath * _Nonnull indexPath, NSManagedObject * _Nonnull object) {
                updateCellInvoked = ( object == mockObject ) && ( indexPath == indexPathZero );
            };

            it(@"reconfigures cell when data updated", ^{
                coordinator = [[FetchedResultsCoordinator alloc] initWithTableView:mockTableView fetchedResultsController:mockFRC updateCell:mockUpdateCell];
                
                [[mockTableView reject] reloadRowsAtIndexPaths:@[indexPathZero] withRowAnimation:UITableViewRowAnimationNone];
                
                [coordinator controller:mockFRC didChangeObject:mockObject atIndexPath:indexPathZero forChangeType:NSFetchedResultsChangeUpdate newIndexPath:nil];
                [coordinator controllerDidChangeContent:mockFRC];
                XCTAssertTrue( updateCellInvoked );
                OCMVerifyAll(mockTableView);
            });

        });
        
    });
    
    it(@"reloads data when unpaused", ^{
        coordinator = [[FetchedResultsCoordinator alloc] initWithTableView:mockTableView fetchedResultsController:mockFRC updateCell:nil];
        
        coordinator.paused = YES;
        coordinator.paused = NO;
        
        OCMVerify([mockTableView reloadData]);
        OCMVerify([mockFRC performFetch:[OCMArg anyObjectRef]]);
    });
    
    it(@"starts observing changes when unpaused", ^{
        coordinator = [[FetchedResultsCoordinator alloc] initWithTableView:mockTableView fetchedResultsController:mockFRC updateCell:nil];
        
        coordinator.paused = YES;
        coordinator.paused = NO;
        
        OCMVerify([mockFRC setDelegate:OCMOCK_ANY]);
    });

});

SpecEnd
