//
//  PVAsyncListeningTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PVAsyncListening.h"
#import "VOListenersCollection.h"
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
  VOListenersCollection *_listeners;
  PVAsyncListeningTestCallbackQueue _callbackQueueIdentifier;
  BOOL _callbackInvoked;
}

@end

@implementation PVAsyncListeningTests

- (void)setUp
{
  [super setUp];
  _queue = dispatch_queue_create(kQueueIdentifierValue, DISPATCH_QUEUE_SERIAL);
  dispatch_queue_set_specific(_queue, kQueueIdentifierKey, kQueueIdentifierValue, NULL);
  _listeners = [[VOListenersCollection alloc] initWithCurrentValue:nil];
  _callbackQueueIdentifier = kCallbackQueueInvalid;
  _callbackInvoked = NO;
}

- (void)tearDown
{
  _queue = nil;
  _listeners = nil;
  [super tearDown];
}

- (void)testBackgroundQueue
{
  PVAsyncListening *async = [[PVAsyncListening alloc] initWithListenableObject:_listeners queue:_queue];
  [async addPipelineSink:self];
  [_listeners pipelineSource:nil didUpdateToValue:nil];
  XCTAssertFalse(_callbackInvoked, @"");
  XCTAssertTrue([VOTestUtilities runRunLoopUntilCondition:&_callbackInvoked], @"");
  XCTAssertEqual(_callbackQueueIdentifier, kCallbackQueueBackgroundQueue, @"");
}

- (void)testMainQueueOptimization
{
  PVAsyncListening *async = [[PVAsyncListening alloc] initWithListenableObject:_listeners
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

@end
