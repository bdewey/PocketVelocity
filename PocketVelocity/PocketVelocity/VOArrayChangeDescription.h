//
//  PVArrayChangeDescription.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Describes how to change an array `oldValues` to an array `newValues`.
 */
@interface VOArrayChangeDescription : NSObject

@property (nonatomic, readonly, copy) NSIndexSet *indexesToRemoveFromOldValues;
@property (nonatomic, readonly, copy) NSIndexSet *indexesToAddFromUpdatedValues;

- (instancetype)initWithIndexesToRemoveFromOldValues:(NSIndexSet *)indexesToRemoveFromOldValues
                       indexesToAddFromUpdatedValues:(NSIndexSet *)indexesToAddFromUpdatedValues;

@end

/**
 A simple extension that makes this class easier to use in a table view scenario. It translates
 the indexSet properties into an array of NSIndexPath objects assuming that each index in the set represents
 a row, and the section number is passed in as a parameter.
 */
@interface VOArrayChangeDescription (NSIndexPath)

- (NSArray *)indexPathsToRemoveFromOldValuesUsingSection:(NSUInteger)section;
- (NSArray *)indexPathsToAddFromNewValuesUsingSection:(NSUInteger)section;

@end
