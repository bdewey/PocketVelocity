//
//  PVObservableArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOArrayChangeDescription.h"
#import "VOChangeDescribingArray.h"
#import "VOChangeDescribingArray_Internal.h"
#import "VOListenersCollection.h"
#import "VOMutableChangeDescribingArray.h"
#import "PVUtilities.h"

@implementation VOChangeDescribingArray
{
  VOArrayChangeDescription *_changeDescription;
}

- (instancetype)initWithValues:(NSArray *)values changeDescription:(VOArrayChangeDescription *)changeDescription
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

- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[NSArray class]]) {
    return PVObjectsAreEqual(_values, object);
  } else if ([object isKindOfClass:[VOChangeDescribingArray class]]) {
    VOChangeDescribingArray *otherArray = (VOChangeDescribingArray *)object;
    return PVObjectsAreEqual(_values, otherArray->_values);
  }
  return NO;
}

- (NSUInteger)hash
{
  return [_values hash];
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

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [[VOMutableChangeDescribingArray alloc] initWithOriginalValues:self];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
  return [_values countByEnumeratingWithState:state objects:buffer count:len];
}

@end
