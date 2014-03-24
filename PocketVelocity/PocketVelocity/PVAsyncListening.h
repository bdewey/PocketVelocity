//
//  PVAsyncListening.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVListenable.h"
#import "PVListenableArray.h"

@interface PVAsyncListening : NSObject <PVListenable, PVListening>

@property (nonatomic, readonly, strong) id<PVListenable> source;
@property (nonatomic, readonly, strong) dispatch_queue_t queue;

- (instancetype)initWithListenableObject:(id<PVListenable>)object queue:(dispatch_queue_t)queue;

@end

@interface PVListenableArray (PVAsyncListening)

- (PVListenableArray *)defaultQueueArray;
- (PVListenableArray *)mainQueueArray;

@end
