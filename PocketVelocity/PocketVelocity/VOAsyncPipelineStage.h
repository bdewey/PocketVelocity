//
//  VOAsyncPipelineStage.h
//  PocketVelocity
//
//  Created by Brian Dewey on 4/1/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOPipelineStage.h"

@interface VOAsyncPipelineStage : VOPipelineStage

@property (nonatomic, readonly, strong) id<VOPipelineSource> source;
@property (nonatomic, readonly, strong) dispatch_queue_t queue;

- (instancetype)initWithSource:(id<VOPipelineSource>)source queue:(dispatch_queue_t)queue;
- (instancetype)initWithSource:(id<VOPipelineSource>)source queueName:(NSString *)queueName;

@end

@interface VOPipelineStage (VOAsyncPipelineStage)

- (VOPipelineStage *)pipelineStageOnQueueNamed:(NSString *)queueName;
- (VOPipelineStage *)pipelineStageOnMainQueue;

@end