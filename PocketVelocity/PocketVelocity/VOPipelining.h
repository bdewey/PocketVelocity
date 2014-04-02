//
//  PVListenable.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VOPipelineSink;

@protocol VOPipelineSource <NSObject>

@property (atomic, readonly, strong) id currentValue;
- (id)addPipelineSink:(id<VOPipelineSink>)listener;
- (void)removePipelineSink:(id<VOPipelineSink>)listener;

@end

@protocol VOPipelineSink <NSObject>

- (void)pipelineSource:(id<VOPipelineSource>)pipelineSource didUpdateToValue:(id)value;

@end