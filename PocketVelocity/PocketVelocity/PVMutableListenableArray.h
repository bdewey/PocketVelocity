//
//  PVMutableListenableArray.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/22/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PVListenableArray.h"

@interface PVMutableListenableArray : PVListenableArray

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;
- (void)insertObject:(id)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)addObject:(id)object;
- (void)removeLastObject;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object;

@end
