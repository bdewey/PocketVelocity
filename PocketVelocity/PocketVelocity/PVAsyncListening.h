//
//  PVAsyncListening.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOPipelining.h"
#import "VOChangeDescribingArray.h"

@interface PVAsyncListening : NSObject <VOPipelineSource, VOPipelineSink>

@property (nonatomic, readonly, strong) id<VOPipelineSource> source;
@property (nonatomic, readonly, strong) dispatch_queue_t queue;

- (instancetype)initWithListenableObject:(id<VOPipelineSource>)object queue:(dispatch_queue_t)queue;

@end

