//
//  PVSectionedDataSourceTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PVSectionedDataSource.h"
#import "VOMutableChangeDescribingArray.h"

@interface PVSectionedDataSourceTests : XCTestCase

@end

@implementation PVSectionedDataSourceTests

- (void)setUp
{
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testSimpleCopyAndMutate
{
  VOMutableChangeDescribingArray *section1 = [[VOMutableChangeDescribingArray alloc] init];
  VOMutableChangeDescribingArray *section2 = [[VOMutableChangeDescribingArray alloc] init];
  PVSectionedDataSource *dataSource = [[PVSectionedDataSource alloc] initWithSections:@[section1, section2]];
  
  XCTAssertEqual(2U, [dataSource countOfSections], @"");
  NSMutableSet *expectedAddedIndexPaths = [[NSMutableSet alloc] init];
  for (int i = 0; i < 10; i++) {
    [section1 addObject:@(i)];
    [expectedAddedIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    [section2 addObject:@(i)];
    [section2 addObject:@(i * 10)];
    [expectedAddedIndexPaths addObject:[NSIndexPath indexPathForItem:i*2 inSection:1]];
    [expectedAddedIndexPaths addObject:[NSIndexPath indexPathForItem:i*2+1 inSection:1]];
  }
  
  PVMutableSectionedDataSource *mutableDataSource = [dataSource mutableCopy];
  mutableDataSource[0] = section1;
  mutableDataSource[1] = section2;
  PVSectionedDataSource *updatedDataSource = [mutableDataSource copy];
  
  XCTAssertEqual(0U, [dataSource countOfItemsInSection:0], @"");
  XCTAssertEqual(10U, [updatedDataSource countOfItemsInSection:0], @"");
  XCTAssertEqualObjects(expectedAddedIndexPaths, [NSSet setWithArray:updatedDataSource.changeDescription.insertedIndexPaths], @"");
  XCTAssertEqual(0U, updatedDataSource.changeDescription.removedIndexPaths.count, @"");
  
  // Clear changeDescription from section1
  section1 = [[section1 copy] mutableCopy];
  [section1 removeObjectAtIndex:3];
  [section1 addObject:@(312)];
  [section1 addObject:@(698)];
  mutableDataSource = [updatedDataSource mutableCopy];
  mutableDataSource[0] = section1;
  updatedDataSource = [mutableDataSource copy];
  
  [expectedAddedIndexPaths removeAllObjects];
  [expectedAddedIndexPaths addObject:[NSIndexPath indexPathForItem:9 inSection:0]];
  [expectedAddedIndexPaths addObject:[NSIndexPath indexPathForItem:10 inSection:0]];
  NSMutableSet *expectedRemovedIndexPaths = [[NSMutableSet alloc] init];
  [expectedRemovedIndexPaths addObject:[NSIndexPath indexPathForItem:3 inSection:0]];
  
  XCTAssertEqual(11U, [updatedDataSource countOfItemsInSection:0], @"");
  XCTAssertEqualObjects(expectedAddedIndexPaths, [NSSet setWithArray:updatedDataSource.changeDescription.insertedIndexPaths], @"");
  XCTAssertEqualObjects(expectedRemovedIndexPaths, [NSSet setWithArray:updatedDataSource.changeDescription.removedIndexPaths], @"");
}
@end
