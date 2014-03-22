//
//  PVAnnouncer.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVAnnouncing.h"

typedef void (^PVAnnouncerEnumerationBlock)(id listener);

@interface PVAnnouncer : NSObject <PVAnnouncing>

- (void)enumerateListenersWithBlock:(PVAnnouncerEnumerationBlock)block;

@end
