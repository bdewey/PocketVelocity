//
//  PVListenersCollection.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVListenable.h"

@class PVListenerQueuePair;

typedef void (^PVListenerEnumerationBlock)(PVListenerQueuePair *listenerQueuePair);

@interface PVListenersCollection : NSObject <PVListenable>

- (void)enumerateListenersWithBlock:(PVListenerEnumerationBlock)block;

@end

@interface PVListenerQueuePair : NSObject

@property (nonatomic, readonly, weak) id listener;
@property (nonatomic, readonly, weak) dispatch_queue_t callbackQueue;

@end
