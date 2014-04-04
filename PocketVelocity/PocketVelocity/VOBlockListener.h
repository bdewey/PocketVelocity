//
//  VOBlockListener.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOInvalidating.h"
#import "VOPipelining.h"
#import "VOPipelineStage.h"

typedef void (^VOBlockListenerBlock)(id value);

@interface VOBlockListener : NSObject <VOPipelineSink>

@property (nonatomic, readonly, strong) id<VOPipelineSource> source;
@property (nonatomic, readonly, strong) dispatch_queue_t queue;

- (instancetype)initWithSource:(id<VOPipelineSource>)source callbackQueue:(dispatch_queue_t)queue block:(VOBlockListenerBlock)block;
- (instancetype)initWithSource:(id<VOPipelineSource>)source block:(VOBlockListenerBlock)block;

- (void)invalidate;

@end

@interface VOPipelineStage (VOBlockListener)

- (VOBlockListener *)mainQueueBlock:(VOBlockListenerBlock)block;
- (VOBlockListener *)blockListenerOnQueue:(dispatch_queue_t)queue block:(VOBlockListenerBlock)block;

@end
