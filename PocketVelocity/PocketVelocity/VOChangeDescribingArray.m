//
//  PVObservableArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVArrayChangeDescription.h"
#import "VOChangeDescribingArray.h"
#import "VOChangeDescribingArray_Internal.h"
#import "PVListenersCollection.h"
#import "PVMutableChangeDescribingArray.h"

@implementation VOChangeDescribingArray
{
  PVArrayChangeDescription *_changeDescription;
}

- (instancetype)initWithValues:(NSArray *)values changeDescription:(PVArrayChangeDescription *)changeDescription
{
  self = [super init];
  if (self != nil) {
    _values = [values copy];
    _changeDescription = changeDescription;
  }
  return self;
}

- (instancetype)init
{
  return [self initWithValues:[[NSArray alloc] init] changeDescription:nil];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ _values = %@", [super description], _values];
}

#pragma mark - NSArray

- (id)objectAtIndex:(NSUInteger)index
{
  return [_values objectAtIndex:index];
}

- (NSUInteger)count
{
  return _values.count;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
  return _values[index];
}

- (void)_updateValues:(NSArray *)updatedValues changeDescription:(PVArrayChangeDescription *)changeDescription
{
  _values = [updatedValues copy];
  _changeDescription = changeDescription;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [[PVMutableChangeDescribingArray alloc] initWithValues:_values changeDescription:_changeDescription];
}

@end
