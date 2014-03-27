//
//  PVMutableListenableArray.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/22/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VOChangeDescribingArray.h"

@interface VOMutableChangeDescribingArray : VOChangeDescribingArray

- (void)setObject:(id<NSCopying>)object atIndexedSubscript:(NSUInteger)index;
- (void)insertObject:(id<NSCopying>)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)addObject:(id<NSCopying>)object;
- (void)removeLastObject;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id<NSCopying>)object;

@end
