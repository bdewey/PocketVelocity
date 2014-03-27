//
//  PVMappdedArrayTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PVArrayChangeDescription.h"
#import "VOArrayMapTransformer.h"
#import "PVMutableChangeDescribingArray.h"
#import "PVUtilities.h"

static NSUInteger kArraySize = 10;
static NSString * const kOddString = @"Odd";
static NSString * const kEvenString = @"Even";

static VOArrayMapTransformer *CreateOddEvenMapping(PVListenableArray *arrayOfNumbers)
{
  return [[VOArrayMapTransformer alloc] initWithSourceArray:arrayOfNumbers mappingBlock:^id(NSNumber *object) {
    NSInteger value = [object integerValue];
    if (value % 2) {
      return kOddString;
    } else {
      return kEvenString;
    }
  }];
}

@interface PVMappedArrayTests : XCTestCase <PVListening>

@property (nonatomic, readonly, strong) PVMutableChangeDescribingArray *numbers;
@property (nonatomic, readonly, strong) PVArrayChangeDescription *lastChangeDescription;

@end

@implementation PVMappedArrayTests

- (void)setUp
{
  [super setUp];
  _numbers = [[PVMutableChangeDescribingArray alloc] init];
  for (int i = 0; i < kArraySize; i++) {
    [_numbers addObject:@(i)];
  }
  _lastChangeDescription = nil;
}

- (void)tearDown
{
  _numbers = nil;
  _lastChangeDescription = nil;
}

- (void)testBasicMapping
{
  VOArrayMapTransformer *mapping = CreateOddEvenMapping(self.numbers);
  
  XCTAssertEqual(mapping.count, kArraySize, @"Unexpected size %u (expedted %u)", mapping.count, kArraySize);
  for (NSUInteger i = 0; i < mapping.count; i++) {
    if (i % 2) {
      XCTAssertEqualObjects(mapping[i], kOddString, @"Expected %@, got %@", kOddString, mapping[i]);
    } else {
      XCTAssertEqualObjects(mapping[i], kEvenString, @"Expected %@, got %@", kOddString, mapping[i]);
    }
  }
}

- (void)testUpdate
{
  VOArrayMapTransformer *mapping = CreateOddEvenMapping(self.numbers);
  
  XCTAssertEqualObjects(mapping[0], kEvenString, @"");
  // Switch the number at index 0 from an even to an odd.
  self.numbers[0] = @(1);
  XCTAssertEqualObjects(mapping[0], kOddString, @"");
}

- (void)testUpdateGeneratesNotification
{
  VOArrayMapTransformer *mapping = CreateOddEvenMapping(self.numbers);
  [mapping addListener:self];
  self.numbers[0] = @(101);
  XCTAssertEqualObjects(mapping[0], kOddString, @"");
  XCTAssertEqual(mapping.count, kArraySize, @"");
  XCTAssertNotNil(self.lastChangeDescription, @"");
  NSIndexSet *indexZero = [NSIndexSet indexSetWithIndex:0];
  XCTAssertEqualObjects(self.lastChangeDescription.indexesToAddFromUpdatedValues, indexZero, @"");
  XCTAssertEqualObjects(self.lastChangeDescription.indexesToRemoveFromOldValues, indexZero, @"");
  XCTAssertEqualObjects(self.lastChangeDescription.oldValues[0], kEvenString, @"");
  XCTAssertEqualObjects(self.lastChangeDescription.updatedValues[0], kOddString, @"");
}

- (void)testUpdateOfEquivalenceClassSuppressedNotification
{
  VOArrayMapTransformer *mapping = CreateOddEvenMapping(self.numbers);
  [mapping addListener:self];
  
  // The old value at 0 was even, the new value is even... so the mapped array doesn't change
  // (Equivalence classes hold)
  // We should not get a notification at all.
  self.numbers[0] = @(100);
  XCTAssertEqualObjects(mapping[0], kEvenString, @"");
  XCTAssertEqual(mapping.count, kArraySize, @"");
  XCTAssertNil(self.lastChangeDescription, @"");
}

#pragma mark - PVListening

- (void)listenableObject:(VOArrayMapTransformer *)object didChangeWithDescription:(PVArrayChangeDescription *)changeDescription
{
  _lastChangeDescription = changeDescription;
}

@end
