//
//  VOListenersCollectionTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/31/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOPipelineStage.h"
#import "VOTestUtilities.h"

static const NSUInteger kPerformanceIterations = 100000;

static CFTimeInterval _TimeBlock(dispatch_block_t block) {
  CFTimeInterval startTime = CACurrentMediaTime();
  block();
  return CACurrentMediaTime() - startTime;
}

@interface _SampleListener : NSObject <VOPipelineSink>

@property (nonatomic, readonly, strong) id currentValue;

@end

@implementation _SampleListener
{
  BOOL _valid;
}

@synthesize valid = _valid;

- (void)invalidate
{
  _valid = NO;
}

- (void)pipelineSource:(id<VOPipelineSource>)listenableObject didUpdateToValue:(NSNumber *)value
{
  // We validate that we get no gaps. Every value that we get is one more than the previous value we saw.
  if (_currentValue != nil) {
    NSUInteger currentInteger = [_currentValue unsignedIntegerValue];
    NSUInteger updatedInteger = [value unsignedIntegerValue];
    NSAssert(updatedInteger == currentInteger + 1, @"Gap in values: %u -> %u", currentInteger, updatedInteger);
  }
  _currentValue = value;
}

- (void)pipelineSourceDidStop:(id<VOPipelineSource>)pipelineSource
{
  // NOTHING
}

@end

@interface VOListenersCollectionTests : XCTestCase

@end

@implementation VOListenersCollectionTests

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

- (void)testPerformanceAddListener
{
  NSMutableArray *listeners = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < kPerformanceIterations; i++) {
    [listeners addObject:[[_SampleListener alloc] init]];
  }
  VOPipelineStage *collection = [[VOPipelineStage alloc] init];
  CFTimeInterval elapsedTime = _TimeBlock(^{
    for (NSUInteger i = 0; i < kPerformanceIterations; i++) {
      [collection addPipelineSink:listeners[i]];
    }
  });
  NSLog(@"%s elapsedTime = %0.3f seconds", __PRETTY_FUNCTION__, elapsedTime);
}

- (void)testPerformanceUpdate
{
  VOPipelineStage *collection = [[VOPipelineStage alloc] init];
  const NSUInteger kNumListeners = 10;
  NSMutableArray *listeners = [[NSMutableArray alloc] initWithCapacity:kNumListeners];
  for (NSUInteger i = 0; i < kNumListeners; i++) {
    _SampleListener *listener = [[_SampleListener alloc] init];
    [listeners addObject:listener];
    [collection addPipelineSink:listener];
  }
  CFTimeInterval elapsedTime = _TimeBlock(^{
    for (NSUInteger i = 0; i < kPerformanceIterations; i++) {
      [collection pipelineSource:nil didUpdateToValue:nil];
    }
  });
  NSLog(@"%s elapsedTime = %0.3f seconds", __PRETTY_FUNCTION__, elapsedTime);
}

- (void)testConcurrencyCorrectness
{
  const NSUInteger kNumberOfListeners = 10;
  __block BOOL didFinishGeneratingValues = NO;
  NSMutableArray *listeners = [[NSMutableArray alloc] initWithCapacity:kNumberOfListeners];
  for (NSUInteger i = 0; i < kNumberOfListeners; i++) {
    [listeners addObject:[[_SampleListener alloc] init]];
  }
  VOPipelineStage *collection = [[VOPipelineStage alloc] init];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    for (NSUInteger i = 0; i < kPerformanceIterations; i++) {
      [collection pipelineSource:collection didUpdateToValue:@(i)];
    }
    didFinishGeneratingValues = YES;
  });
  for (NSUInteger i = 0; i < kNumberOfListeners; i++) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      _SampleListener *listener = listeners[i];
      [collection addPipelineSink:listener];
    });
  }
  BOOL result = [VOTestUtilities runRunLoopUntilCondition:&didFinishGeneratingValues];
  XCTAssertTrue(result, @"");
}

@end
