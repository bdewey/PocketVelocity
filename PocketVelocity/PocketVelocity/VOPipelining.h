//
//  PVListenable.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOInvalidating.h"

typedef NS_ENUM(NSInteger, VOPipelineState) {
  /**
   The pipeline has been created but it has not yet procssed values.
   */
  VOPipelineStateInitialized,
  
  /**
   the pipeline has asked its source to provide values, but it hasn't received the first one yet.
   */
  VOPipelinePendingStart,
  
  /**
   The pipeline is processing values.
   */
  VOPipelineStateStarted,
  
  /**
   The pipeline is done and will not process any more values.
   */
  VOPipelineStateStopped
};

@protocol VOPipelineSink;

@protocol VOPipelineSource <NSObject>

@property (atomic, readonly, assign) VOPipelineState pipelineState;
@property (atomic, readonly, strong) id currentValue;

- (id)addPipelineSink:(id<VOPipelineSink>)listener;
- (void)removePipelineSink:(id<VOPipelineSink>)listener;

// Controls PRODUCTION of new values
- (void)startPipeline;
- (void)stopPipeline;

- (void)pipelineSinkWantsToStart:(id<VOPipelineSink>)pipelineSink;

// Debuggability
- (NSString *)pipelineDescription;

@end

// The VOInvalidating protocol on a sink tells it to stop CONSUMING new values
@protocol VOPipelineSink <VOInvalidating, NSObject>

- (void)pipelineSource:(id<VOPipelineSource>)pipelineSource didUpdateToValue:(id)value;
- (void)pipelineSourceDidStop:(id<VOPipelineSource>)pipelineSource;

@end