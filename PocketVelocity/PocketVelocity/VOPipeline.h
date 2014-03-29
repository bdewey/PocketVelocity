//
//  VOPipeline.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOListenable.h"

@interface VOPipeline : NSObject <VOListenable, VOListening>

@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSArray *stages;
@property (nonatomic, readonly, assign) BOOL mainQueuePipeline;

- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source stages:(NSArray *)stages;
- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source stages:(NSArray *)stages queue:(dispatch_queue_t)queue;

@end
