//
//  PVAsyncListeningTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOAsyncPipelineStage.h"
#import "VOPipelineStage.h"
#import "VOTestUtilities.h"

static const char *kQueueIdentifierKey = "PVAsyncListeningTests";
static char *kQueueIdentifierValue = "com.brians-brain.pocketvelocity";

typedef NS_ENUM(NSUInteger, PVAsyncListeningTestCallbackQueue) {
  kCallbackQueueInvalid,
  kCallbackQueueMainQueue,
  kCallbackQueueBackgroundQueue
};

@interface PVAsyncListeningTests : XCTestCase <VOPipelineSink>
{
  dispatch_queue_t _queue;
  VOPipelineStage *_listeners;
  PVAsyncListeningTestCallbackQueue _callbackQueueIdentifier;
  BOOL _callbackInvoked;
  BOOL _valid;
}

@end

@implementation PVAsyncListeningTests

@synthesize valid = _valid;

- (void)setUp
{
  [super setUp];
  _queue = dispatch_queue_create(kQueueIdentifierValue, DISPATCH_QUEUE_SERIAL);
  dispatch_queue_set_specific(_queue, kQueueIdentifierKey, kQueueIdentifierValue, NULL);
  _listeners = [[VOPipelineStage alloc] init];
  _callbackQueueIdentifier = kCallbackQueueInvalid;
  _callbackInvoked = NO;
  _valid = YES;
}

- (void)tearDown
{
  _queue = nil;
  _listeners = nil;
  [super tearDown];
}

- (void)testBackgroundQueue
{
  VOAsyncPipelineStage *async = [[VOAsyncPipelineStage alloc] initWithSource:_listeners queue:_queue];
  [async addPipelineSink:self];
  [_listeners pipelineSource:nil didUpdateToValue:nil];
  XCTAssertFalse(_callbackInvoked, @"");
  XCTAssertTrue([VOTestUtilities runRunLoopUntilCondition:&_callbackInvoked], @"");
  XCTAssertEqual(_callbackQueueIdentifier, kCallbackQueueBackgroundQueue, @"");
}

- (void)testMainQueueOptimization
{
  VOAsyncPipelineStage *async = [[VOAsyncPipelineStage alloc] initWithSource:_listeners
                                                                       queue:dispatch_get_main_queue()];
  [async addPipelineSink:self];
  [_listeners pipelineSource:nil didUpdateToValue:nil];
  XCTAssertTrue(_callbackInvoked, @"");
  XCTAssertEqual(_callbackQueueIdentifier, kCallbackQueueMainQueue, @"");
}

#pragma mark - PVListening

- (void)pipelineSource:(id<VOPipelineSource>)listenableObject didUpdateToValue:(id)value
{
  _callbackQueueIdentifier = (dispatch_get_specific(kQueueIdentifierKey) == kQueueIdentifierValue) ? kCallbackQueueBackgroundQueue : kCallbackQueueMainQueue;
  _callbackInvoked = YES;
}

- (void)pipelineSourceDidStop:(id<VOPipelineSource>)pipelineSource
{
  
}

- (void)invalidate
{
  _valid = NO;
}

@end
