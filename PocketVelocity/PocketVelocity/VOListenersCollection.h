//
//  PVListenersCollection.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOListenable.h"

@class PVListenerQueuePair;

@interface VOListenersCollection : NSObject <VOListenable, VOListening>

@property (atomic, readonly, strong) id currentValue;
- (instancetype)initWithCurrentValue:(id)currentValue;

@end

