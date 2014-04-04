//
//  VOAsyncPipelineStage.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/1/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "NSObject+VOUtilities.h"
#import "VOAsyncPipelineStage.h"

@implementation VOAsyncPipelineStage
{
  BOOL _shouldInvokeSynchronouslyOnMainThread;
}

- (instancetype)initWithSource:(id<VOPipelineSource>)source queue:(dispatch_queue_t)queue
{
  self = [super initWithSource:source];
  if (self != nil) {
    _queue = queue;
    _shouldInvokeSynchronouslyOnMainThread = (_queue == dispatch_get_main_queue());
  }
  return self;
}

- (instancetype)initWithSource:(id<VOPipelineSource>)source queueName:(NSString *)queueName
{
  const char *cstring = [queueName cStringUsingEncoding:NSUTF8StringEncoding];
  dispatch_queue_t queue = dispatch_queue_create(cstring, DISPATCH_QUEUE_SERIAL);
  dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
  return [self initWithSource:source queue:queue];
}

- (NSString *)vo_descriptionWithProperties:(NSDictionary *)properties
{
  NSMutableDictionary *mutableProperties = [properties mutableCopy];
  NSString *queueLabel = [NSString stringWithCString:dispatch_queue_get_label(_queue) encoding:NSUTF8StringEncoding];
  [mutableProperties addEntriesFromDictionary:@{@"queue": NSNULL_IF_NIL(queueLabel)}];
  return [super vo_descriptionWithProperties:mutableProperties];
}

#pragma mark - VOPipelineSink

- (void)pipelineSource:(id<VOPipelineSource>)pipelineSource didUpdateToValue:(id)value
{
  if (_shouldInvokeSynchronouslyOnMainThread && [NSThread isMainThread]) {
    [super pipelineSource:pipelineSource didUpdateToValue:value];
  } else {
    dispatch_async(_queue, ^{
      [super pipelineSource:pipelineSource didUpdateToValue:value];
    });
  }
}
@end

@implementation VOPipelineStage (VOAsyncPipelineStage)

- (VOPipelineStage *)pipelineStageOnQueueNamed:(NSString *)queueName
{
  return [[VOAsyncPipelineStage alloc] initWithSource:self queueName:queueName];
}

- (VOPipelineStage *)pipelineStageOnMainQueue
{
  return [[VOAsyncPipelineStage alloc] initWithSource:self queue:dispatch_get_main_queue()];
}

@end