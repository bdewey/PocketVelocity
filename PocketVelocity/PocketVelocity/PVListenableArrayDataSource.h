//
//  PVObservableArray.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVListenable.h"

@class PVArrayChangeDescription;

typedef void (^PVListenableArrayDataSourceBatchBlock)(NSMutableArray *mutableCopy);

/**
 When listening to changes to this data source, the change description is class PVArrayChangeDescription.
 */
@interface PVListenableArrayDataSource : NSObject <PVListenable>

@property (nonatomic, readonly, assign) NSUInteger count;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;
- (void)insertObject:(id)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)addObject:(id)object;
- (void)removeLastObject;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object;

@end

