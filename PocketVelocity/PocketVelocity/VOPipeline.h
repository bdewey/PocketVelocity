//
//  VOPipeline.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOInvalidating.h"
#import "VOListenable.h"

@protocol VOValueTransforming;

@interface VOPipeline : NSObject <VOInvalidating, VOListenable, VOListening>

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, strong) id<VOValueTransforming> transformer;
@property (nonatomic, readonly, assign) BOOL mainQueuePipeline;
@property (nonatomic, readonly, assign) BOOL chainedPipeline;

- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source;
- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source transformer:(id<VOValueTransforming>)transformer;
- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source transformer:(id<VOValueTransforming>)transformer queue:(dispatch_queue_t)queue;
- (instancetype)initWithPipeline:(VOPipeline *)pipeline transformer:(id<VOValueTransforming>)transformer;

@end
