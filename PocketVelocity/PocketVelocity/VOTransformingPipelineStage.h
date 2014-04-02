//
//  VOPipeline.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOInvalidating.h"
#import "VOPipelineStage.h"

@protocol VOValueTransforming;

@interface VOTransformingPipelineStage : VOPipelineStage <VOPipelineSource, VOPipelineSink>

@property (nonatomic, readonly, strong) id<VOPipelineSource> source;
@property (nonatomic, readonly, strong) id<VOValueTransforming> transformer;

- (instancetype)initWithSource:(id<VOPipelineSource>)source transformer:(id<VOValueTransforming>)transformer;

@end
