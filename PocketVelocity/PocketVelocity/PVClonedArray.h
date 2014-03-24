//
//  PVClonedArray.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVListenableArray.h"

@interface PVClonedArray : PVListenableArray

- (instancetype)initWithSource:(id<PVListenable>)source;

@end
