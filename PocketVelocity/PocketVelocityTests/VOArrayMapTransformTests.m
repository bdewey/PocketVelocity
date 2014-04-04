//
//  VOArrayMapTransformTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/27/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOArrayChangeDescription.h"
#import "VOArrayMapTransformer.h"
#import "VOMutableChangeDescribingArray.h"

static NSString * const kOddString = @"Odd";
static NSString * const kEvenString = @"Even";

static VOChangeDescribingArray *CreateTestArray() {
  VOMutableChangeDescribingArray *mutableArray = [[VOMutableChangeDescribingArray alloc] init];
  for (int i = 0; i < 5; i++) {
    [mutableArray addObject:@(i)];
  }
  return [mutableArray copy];
}

@interface VOArrayMapTransformTests : XCTestCase <VOValueTransforming>

@end

@implementation VOArrayMapTransformTests

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

- (void)testBasicMapping
{
  VOArrayMapTransformer *transformer = [[VOArrayMapTransformer alloc] initWithValueTransformer:self];
  VOChangeDescribingArray *output = [transformer transformValue:CreateTestArray() previousResult:nil];
  // spot check because I'm lazy
  XCTAssertEqualObjects(kEvenString, output[0], @"");
  XCTAssertEqualObjects(kOddString, output[1], @"");
}

- (void)testPipelinedMapping
{
  VOArrayMapTransformer *transformer = [[VOArrayMapTransformer alloc] initWithValueTransformer:self];
  VOChangeDescribingArray *output = [transformer transformValue:CreateTestArray() previousResult:nil];
  // spot check because I'm lazy
  XCTAssertEqualObjects(kEvenString, output[0], @"");
  XCTAssertEqualObjects(kOddString, output[1], @"");
}

- (void)testSuppressedPipelineUpdate
{
  VOArrayMapTransformer *transformer = [[VOArrayMapTransformer alloc] initWithValueTransformer:self];
  VOChangeDescribingArray *startingState = CreateTestArray();
  VOChangeDescribingArray *originalOutput = [transformer transformValue:startingState previousResult:nil];
  VOMutableChangeDescribingArray *mutableState = [startingState mutableCopy];
  mutableState[1] = @(13);      // replace one odd value with another
  VOChangeDescribingArray *output = [transformer transformValue:mutableState previousResult:originalOutput];
  XCTAssertEqualObjects(originalOutput, output, @"");
  XCTAssertEqual(0U, output.changeDescription.indexesToAddFromUpdatedValues.count, @"");
  XCTAssertEqual(0U, output.changeDescription.indexesToRemoveFromOldValues.count, @"");
}

#pragma mark - VOValueTransforming

- (id)transformValue:(NSNumber *)value previousResult:(id)previousResult
{
  NSInteger number = [value integerValue];
  if (number % 2) {
    return kOddString;
  }
  return kEvenString;
}

@end
