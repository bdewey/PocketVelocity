//
//  VOListenersCollectionTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/31/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOListenersCollection.h"

static const NSUInteger kPerformanceIterations = 100000;

static CFTimeInterval _TimeBlock(dispatch_block_t block) {
  CFTimeInterval startTime = CACurrentMediaTime();
  block();
  return CACurrentMediaTime() - startTime;
}

@interface _SampleListener : NSObject <VOListening>

@property (nonatomic, readonly, strong) id currentValue;

@end

@implementation _SampleListener

- (void)listenableObject:(id<VOListenable>)listenableObject didUpdateToValue:(id)value
{
  _currentValue = value;
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
  VOListenersCollection *collection = [[VOListenersCollection alloc] initWithCurrentValue:nil];
  CFTimeInterval elapsedTime = _TimeBlock(^{
    for (NSUInteger i = 0; i < kPerformanceIterations; i++) {
      [collection addListener:listeners[i]];
    }
  });
  NSLog(@"%s elapsedTime = %0.3f seconds", __PRETTY_FUNCTION__, elapsedTime);
}

- (void)testPerformanceUpdate
{
  VOListenersCollection *collection = [[VOListenersCollection alloc] initWithCurrentValue:nil];
  const NSUInteger kNumListeners = 10;
  NSMutableArray *listeners = [[NSMutableArray alloc] initWithCapacity:kNumListeners];
  for (NSUInteger i = 0; i < kNumListeners; i++) {
    _SampleListener *listener = [[_SampleListener alloc] init];
    [listeners addObject:listener];
    [collection addListener:listener];
  }
  CFTimeInterval elapsedTime = _TimeBlock(^{
    for (NSUInteger i = 0; i < kPerformanceIterations; i++) {
      [collection listenableObject:nil didUpdateToValue:nil];
    }
  });
  NSLog(@"%s elapsedTime = %0.3f seconds", __PRETTY_FUNCTION__, elapsedTime);
}

@end
