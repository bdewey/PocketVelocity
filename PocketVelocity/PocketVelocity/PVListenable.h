//
//  PVListenable.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PVListening;

@protocol PVListenable <NSObject>

- (void)addListener:(id<PVListening>)observer;
- (void)addListener:(id<PVListening>)observer callbackQueue:(dispatch_queue_t)queue;
- (void)removeListener:(id<PVListening>)observer;

@end

@protocol PVListening <NSObject>

- (void)listenableObject:(id)object didChangeWithDescription:(id)changeDescription;

@end