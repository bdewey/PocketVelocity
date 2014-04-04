//
//  VOArrayFiltererTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOArrayFilterer.h"
#import "VOMutableChangeDescribingArray.h"

static VOChangeDescribingArray *CreateTestArray(NSUInteger length) {
  VOMutableChangeDescribingArray *mutableArray = [[VOMutableChangeDescribingArray alloc] init];
  for (NSUInteger i = 0; i < length; i++) {
    [mutableArray addObject:@(i)];
  }
  return [mutableArray copy];
}

@interface VOArrayFiltererTests : XCTestCase <VOValueTransforming>

@end

@implementation VOArrayFiltererTests
{
  VOArrayFilterer *_filterer;
}

- (void)setUp
{
  [super setUp];
  _filterer = [[VOArrayFilterer alloc] initWithTransformer:self expectsPipelineSemantics:NO];
}

- (void)tearDown
{
  _filterer = nil;
  [super tearDown];
}

- (void)testSimpleFilter
{
  VOChangeDescribingArray *input = CreateTestArray(10);
  VOChangeDescribingArray *output = [_filterer transformValue:input previousResult:nil];
  XCTAssertEqual((NSUInteger)5, output.count, @"");
}

#pragma mark - VOValueTransforming

// Only pass odd numbers through.
- (id)transformValue:(NSNumber *)value previousResult:(NSNumber *)previousResult
{
  NSInteger number = [value integerValue];
  if (number % 2) {
    return value;
  }
  return nil;
}

@end
