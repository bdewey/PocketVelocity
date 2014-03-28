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

// Many tests below describe a sequence of operations of inserts & removes.
typedef NS_ENUM(NSUInteger, _VOArrayOperationType) {
  _VOArrayOperationInsert,
  _VOArrayOperationRemove
};

// Encapsulates a single mutation.
typedef struct {
  _VOArrayOperationType type;
  NSUInteger index;
} VOArrayOperation;


@interface VOMutableChangeDescribingArrayTests : XCTestCase

@end

@implementation VOMutableChangeDescribingArrayTests

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

- (void)testEqualItemOptimization
{
  VOMutableChangeDescribingArray *mutableArray = [[VOMutableChangeDescribingArray alloc] init];
  [mutableArray addObject:@(0)];
  [mutableArray addObject:@(1)];
  VOChangeDescribingArray *immutableCopy = [mutableArray copy];
  mutableArray = [immutableCopy mutableCopy];
  
  // Assign the same value to the same slot. This shouldn't look like a change.
  mutableArray[0] = @(0);
  
  XCTAssertEqualObjects(mutableArray, immutableCopy, @"");
  XCTAssertEqualObjects(mutableArray.changeDescription.indexesToAddFromUpdatedValues, [NSIndexSet indexSet], @"");
}

- (void)testSingleInsert
{
  VOArrayOperation operations[] = {
                                   { _VOArrayOperationInsert, 3 }
  };
  [self _executeTestNamed:@"testSingleInsert"
           operationCount:sizeof(operations) / sizeof(VOArrayOperation)
               operations:operations
  expectedIndexesToRemove:[NSIndexSet indexSet]
     expectedIndexesToAdd:[NSIndexSet indexSetWithIndex:3]];

}

- (void)testSingleRemove
{
  VOArrayOperation operations[] = {
    { _VOArrayOperationRemove, 3 }
  };
  [self _executeTestNamed:@"testSingleRemove"
           operationCount:1
               operations:operations
  expectedIndexesToRemove:[NSIndexSet indexSetWithIndex:3]
     expectedIndexesToAdd:[NSIndexSet indexSet]];
}

- (void)testDoubleInserts
{
  VOArrayOperation operations[] = {
    { _VOArrayOperationInsert, 2 },
    { _VOArrayOperationInsert, 2 }
  };
  [self _executeTestNamed:@"testDoubleInserts"
           operationCount:2
               operations:operations
  expectedIndexesToRemove:[NSIndexSet indexSet]
     expectedIndexesToAdd:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]];
}

- (void)testInsertAndRemove
{
  VOArrayOperation operations[] = {
    { _VOArrayOperationInsert, 2 },
    { _VOArrayOperationRemove, 2 }
  };
  [self _executeTestNamed:@"testInsertAndRemove"
           operationCount:2
               operations:operations
  expectedIndexesToRemove:[NSIndexSet indexSet]
     expectedIndexesToAdd:[NSIndexSet indexSet]];
}

- (void)testDoubleRemovals
{
  VOArrayOperation operations[] = {
    { _VOArrayOperationRemove, 2 },
    { _VOArrayOperationRemove, 2 }
  };
  [self _executeTestNamed:@"testDoubleRemoves"
           operationCount:2
               operations:operations
  expectedIndexesToRemove:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]
     expectedIndexesToAdd:[NSIndexSet indexSet]];
}

#pragma mark - Helpers

- (void)_executeTestNamed:(NSString *)testName
           operationCount:(NSUInteger)operationCount
               operations:(VOArrayOperation *)operations
  expectedIndexesToRemove:(NSIndexSet *)expectedIndexesToRemove
     expectedIndexesToAdd:(NSIndexSet *)expectedIndexesToAdd
{
  NSUInteger counter = 0;
  // This validates that changes to a VOMutableChangeDescribingArray yield the same operations done to an NSMutableArray
  NSMutableArray *mirrorArray = [[NSMutableArray alloc] init];
  
  VOMutableChangeDescribingArray *mutableArray = [[VOMutableChangeDescribingArray alloc] init];
  for (int i = 0; i < 10; i++) {
    [mutableArray addObject:@(counter)];
    [mirrorArray addObject:@(counter)];
    counter++;
  }
  mutableArray = [[mutableArray copy] mutableCopy];
  for (int i = 0; i < operationCount; i++) {
    switch (operations[i].type) {
      case _VOArrayOperationInsert:
        [mutableArray insertObject:@(counter) atIndex:operations[i].index];
        [mirrorArray insertObject:@(counter) atIndex:operations[i].index];
        counter++;
        break;
        
      case _VOArrayOperationRemove:
        [mutableArray removeObjectAtIndex:operations[i].index];
        [mirrorArray removeObjectAtIndex:operations[i].index];
        break;
    }
  }
  VOChangeDescribingArray *immutableCopy = [mutableArray copy];
  VOArrayChangeDescription *changeDescription = immutableCopy.changeDescription;
  XCTAssertEqualObjects(expectedIndexesToRemove,
                        changeDescription.indexesToRemoveFromOldValues,
                        @"Test case %@", testName);
  XCTAssertEqualObjects(expectedIndexesToAdd,
                        changeDescription.indexesToAddFromUpdatedValues,
                        @"Test case %@", testName);
  XCTAssertEqualObjects(immutableCopy, mirrorArray, @"Test case %@", testName);
}

@end
