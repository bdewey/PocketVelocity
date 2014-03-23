//
//  PVListenableArray_Internal.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVListenableArray.h"

@interface PVListenableArray ()

@property (nonatomic, readonly, strong) NSArray *values;

- (instancetype)initWithValues:(NSArray *)values;
- (void)_updateValues:(NSArray *)updatedValues changeDescription:(PVArrayChangeDescription *)changeDescription;

@end
