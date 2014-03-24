//
//  PVAsyncListeningTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PVAsyncListening.h"
#import "PVListenersCollection.h"

static const char *kQueueIdentifierKey = "PVAsyncListeningTests";
static char *kQueueIdentifierValue = "com.brians-brain.pocketvelocity";

static BOOL PVAsyncListeningRunLoop(BOOL *condition)
{
  CFTimeInterval tick = 0.01;
  CFTimeInterval timeoutDate = CACurrentMediaTime() + 5;
  while (!*condition) {
    if (CACurrentMediaTime() > timeoutDate) {
      break;
    }
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, tick, true);
  }
  return *condition;
}

typedef NS_ENUM(NSUInteger, PVAsyncListeningTestCallbackQueue) {
  kCallbackQueueInvalid,
  kCallbackQueueMainQueue,
  kCallbackQueueBackgroundQueue
};

@interface PVAsyncListeningTests : XCTestCase <PVListening>
{
  dispatch_queue_t _queue;
  PVListenersCollection *_listeners;
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
  _listeners = [[PVListenersCollection alloc] init];
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
  [async addListener:self];
  [_listeners listenableObject:self didChangeWithDescription:nil];
  XCTAssertFalse(_callbackInvoked, @"");
  XCTAssertTrue(PVAsyncListeningRunLoop(&_callbackInvoked), @"");
  XCTAssertEqual(_callbackQueueIdentifier, kCallbackQueueBackgroundQueue, @"");
}

#pragma mark - PVListening

- (void)listenableObject:(id)object didChangeWithDescription:(id)changeDescription
{
  _callbackQueueIdentifier = (dispatch_get_specific(kQueueIdentifierKey) == kQueueIdentifierValue) ? kCallbackQueueBackgroundQueue : kCallbackQueueMainQueue;
  _callbackInvoked = YES;
}

@end
