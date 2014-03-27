//
//  VOMutableChangeDescribingArrayTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/27/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VOArrayChangeDescription.h"
#import "VOMutableChangeDescribingArray.h"

@interface VOMutableChangeDescribingArrayTests : XCTestCase

@end

@implementation VOMutableChangeDescribingArrayTests

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

- (void)testBasicMutatingAndCopying
{
  VOChangeDescribingArray *baseArray = [[VOChangeDescribingArray alloc] init];
  XCTAssertEqual(baseArray, [baseArray copy], @"Copy of immutable object should be pointer-equal");
  XCTAssertEqual(0U, baseArray.count, @"");
  XCTAssertNil(baseArray.changeDescription, @"");
  
  VOMutableChangeDescribingArray *mutableArray = [baseArray mutableCopy];
  [mutableArray addObject:@(0)];
  XCTAssertEqual(1U, mutableArray.count, @"");
  XCTAssertEqual(0U, baseArray.count, @"");
  
  VOMutableChangeDescribingArray *secondMutableArray = [mutableArray mutableCopy];
  [secondMutableArray addObject:@(1)];
  XCTAssertEqual(2U, secondMutableArray.count, @"");
  XCTAssertEqual(1U, mutableArray.count, @"");
  XCTAssertEqual(0U, baseArray.count, @"");
  
  [mutableArray insertObject:@(3) atIndex:0];
  XCTAssertEqual(2U, mutableArray.count, @"");
  XCTAssertEqual(2U, secondMutableArray.count, @"");
  XCTAssertEqualObjects(@(3), mutableArray[0], @"");
  XCTAssertEqualObjects(@(0), secondMutableArray[0], @"");
  
  VOChangeDescribingArray *immutableCopyOfMutableArray = [mutableArray copy];
  XCTAssertEqual(immutableCopyOfMutableArray, [immutableCopyOfMutableArray copy], @"");
  XCTAssertEqualObjects(immutableCopyOfMutableArray, mutableArray, @"");
}

- (void)testInsertChangeDescriptions
{
  VOMutableChangeDescribingArray *mutableArray = [[VOMutableChangeDescribingArray alloc] init];
  [mutableArray addObject:@(0)];
  [mutableArray addObject:@(1)];
  VOArrayChangeDescription *changeDescription = mutableArray.changeDescription;
  XCTAssertNotNil(changeDescription, @"");
  XCTAssertEqual(0U, changeDescription.indexesToRemoveFromOldValues.count, @"");
  XCTAssertEqual(2U, changeDescription.indexesToAddFromUpdatedValues.count, @"");
  XCTAssertTrue([changeDescription.indexesToAddFromUpdatedValues containsIndex:0], @"");
  XCTAssertTrue([changeDescription.indexesToAddFromUpdatedValues containsIndex:1], @"");
}

- (void)testRemoveChangeDescriptions
{
  VOMutableChangeDescribingArray *mutableArray = [[VOMutableChangeDescribingArray alloc] init];
  [mutableArray addObject:@(0)];
  [mutableArray addObject:@(1)];
  VOChangeDescribingArray *immutableCopy = [mutableArray copy];
  mutableArray = [immutableCopy mutableCopy];
  XCTAssertEqual(0U, mutableArray.changeDescription.indexesToAddFromUpdatedValues.count, @"");
  XCTAssertEqual(0U, mutableArray.changeDescription.indexesToRemoveFromOldValues.count, @"");
  [mutableArray removeLastObject];
  [mutableArray removeLastObject];
  XCTAssertEqual(0U, mutableArray.count, @"");
  XCTAssertEqual(2U, mutableArray.changeDescription.indexesToRemoveFromOldValues.count, @"");
  XCTAssertTrue([mutableArray.changeDescription.indexesToRemoveFromOldValues containsIndex:0], @"");
  XCTAssertTrue([mutableArray.changeDescription.indexesToRemoveFromOldValues containsIndex:1], @"");
}

@end
