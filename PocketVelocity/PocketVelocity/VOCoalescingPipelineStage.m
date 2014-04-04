//
//  VOCoalescingPipelineStage.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOCoalescingPipelineStage.h"
#import "VOChangeDescribingDictionary.h"
#import "VODictionaryChangeDescription.h"
#import "VOMutableChangeDescribingDictionary.h"

@implementation VOCoalescingPipelineStage
{
  dispatch_queue_t _queue;
  dispatch_source_t _timer;
  VOMutableChangeDescribingDictionary *_accumulator;
}

- (instancetype)initWithSource:(id<VOPipelineSource>)source coalescingTimeInterval:(NSTimeInterval)coalescingTimeInterval
{
  self = [super initWithSource:source];
  if (self != nil) {
    _coalescingTimeInterval = coalescingTimeInterval;
    _queue = dispatch_queue_create("org.brians-brain.pocket-velocity.VOCoalescingPipelineStage", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
  }
  return self;
}

#pragma mark - Overrides

- (void)pipelineSource:(id<VOPipelineSource>)pipelineSource didUpdateToValue:(VOChangeDescribingDictionary *)value
{
  dispatch_async(_queue, ^{
    if (_accumulator == nil) {
      _accumulator = [value mutableCopy];
    } else {
      VODictionaryChangeDescription *changeDescription = value.changeDescription;
      for (id<NSCopying> key in changeDescription.removedKeys) {
        [_accumulator removeObjectForKey:key];
      }
      for (id<NSCopying> key in changeDescription.insertedOrUpdatedKeys) {
        _accumulator[key] = value[key];
      }
    }
    if (_timer == nil) {
      _timer = [self _newCoalescingTimer];
    }
  });
}

- (void)pipelineSourceDidStop:(id<VOPipelineSource>)pipelineSource
{
  dispatch_async(_queue, ^{
    [self _handleTimer];
  });
}

- (dispatch_source_t)_newCoalescingTimer
{
  dispatch_source_t timer;
  timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
  dispatch_source_set_timer(timer, dispatch_walltime(NULL, _coalescingTimeInterval * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0.1);
  __weak VOCoalescingPipelineStage *weakSelf = self;
  dispatch_source_set_event_handler(timer, ^{
    [weakSelf _handleTimer];
  });
  dispatch_resume(timer);
  return timer;
}

- (void)_handleTimer
{
  dispatch_source_cancel(_timer);
  _timer = nil;
  id value = [_accumulator copyWithZone:nil];
  [super pipelineSource:self.source didUpdateToValue:value];
}

@end

@implementation VOPipelineStage (VOCoalescingPipelineStage)

- (VOPipelineStage *)pipelineStageCoalescedWithTimeInterval:(NSTimeInterval)timeInterval
{
  return [[VOCoalescingPipelineStage alloc] initWithSource:self coalescingTimeInterval:timeInterval];
}

@end