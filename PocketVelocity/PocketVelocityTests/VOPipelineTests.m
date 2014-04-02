//
//  VOPipelineTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOArrayFilterer.h"
#import "VOArrayMapTransformer.h"
#import "VOBlockTransformer.h"
#import "VOListenersCollection.h"
#import "VOPipeline.h"

static NSString *const kEvenString = @"Even";
static NSString *const kOddString  = @"Odd";

@interface VOPipelineTests : XCTestCase <VOPipelineSink>

@end

@implementation VOPipelineTests {
  VOPipeline *_pipeline;
  VOListenersCollection *_listeners;
  id _pipelineResult;
}

- (void)setUp
{
  [super setUp];

  _pipelineResult = nil;
  _listeners = [[VOListenersCollection alloc] initWithCurrentValue:nil];
  _pipeline = [[[[VOPipeline alloc] initWithName:@"VOPipelineTests" source:_listeners transformer:nil queue:dispatch_get_main_queue()] pipelineWithArrayFilteringBlock:^id(NSNumber *value) {
    NSInteger number = [value integerValue];
    if (number % 2) {
      return value;
    }
    return nil;
  }] pipelineWithArrayMappingBlock:^id(NSNumber *value) {
    NSInteger number = [value integerValue];
    if (number % 2) {
      return kOddString;
    }
    return kEvenString;
  }];
  [_pipeline addPipelineSink:self];
}

- (void)tearDown
{
  [_pipeline removePipelineSink:self];
  _pipeline = nil;
  _listeners = nil;
  _pipelineResult = nil;
  [super tearDown];
}

- (void)testSimplePipeline
{
  NSUInteger kTestArraySize = 10;
  NSMutableArray *mutableValue = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < kTestArraySize; i++) {
    [mutableValue addObject:@(i)];
  }
  [_listeners pipelineSource:_listeners didUpdateToValue:mutableValue];
  
  NSMutableArray *expectedResults = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < (kTestArraySize / 2); i++) {
    [expectedResults addObject:kOddString];
  }
  
  XCTAssertNotNil(_pipelineResult, @"");
  XCTAssertEqualObjects(_pipelineResult, expectedResults, @"");
}

#pragma mark - VOListening

- (void)pipelineSource:(id<VOPipelineSource>)listenableObject didUpdateToValue:(id)value
{
  _pipelineResult = value;
}

@end
