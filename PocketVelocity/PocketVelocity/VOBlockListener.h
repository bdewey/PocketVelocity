//
//  VOBlockListener.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOListenable.h"

typedef void (^VOBlockListenerBlock)(id value);

@interface VOBlockListener : NSObject <VOListening>

@property (nonatomic, readonly, strong) id<VOListenable> source;
@property (nonatomic, readonly, strong) dispatch_queue_t queue;
@property (nonatomic, readonly, assign) BOOL valid;

- (instancetype)initWithSource:(id<VOListenable>)source callbackQueue:(dispatch_queue_t)queue block:(VOBlockListenerBlock)block;
- (instancetype)initWithSource:(id<VOListenable>)source block:(VOBlockListenerBlock)block;

- (void)invalidate;

@end
