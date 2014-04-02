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

- (id)addListener:(id<VOPipelineSink>)listener;
- (void)removeListener:(id<VOPipelineSink>)listener;

@end

@protocol VOPipelineSink <NSObject>

- (void)listenableObject:(id<VOPipelineSource>)listenableObject didUpdateToValue:(id)value;

@end