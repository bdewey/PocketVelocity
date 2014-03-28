//
//  PVAsyncListening.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOListenable.h"
#import "VOChangeDescribingArray.h"

@interface PVAsyncListening : NSObject <VOListenable, VOListening>

@property (nonatomic, readonly, strong) id<VOListenable> source;
@property (nonatomic, readonly, strong) dispatch_queue_t queue;

- (instancetype)initWithListenableObject:(id<VOListenable>)object queue:(dispatch_queue_t)queue;

@end

