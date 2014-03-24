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

@interface PVListenersCollection : NSObject <PVListenable, PVListening>

@end

