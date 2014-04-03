//
//  VOMutableChangeDescribingDictionary.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOMutableChangeDescribingDictionary.h"
#import "VOChangeDescribingDictionary.h"
#import "VODictionaryChangeDescription.h"

@implementation VOMutableChangeDescribingDictionary
{
  NSMutableSet *_removedKeys;
  NSMutableDictionary *_updatedValues;
}

- (instancetype)initWithOriginalValues:(id<NSCopying,VODictionary>)originalValues
{
  self = [super init];
  if (self != nil) {
    _originalValues = [originalValues copyWithZone:nil];
    _removedKeys = [[NSMutableSet alloc] init];
    _updatedValues = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (instancetype)init
{
  return [self initWithOriginalValues:nil];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ original = %p removed = %@ update = %@",
          [super description], _originalValues, _removedKeys, _updatedValues];
}

#pragma mark - VODictionary

- (NSDictionary *)dictionary
{
  NSMutableDictionary *mutableResults = [[_originalValues dictionary] mutableCopy];
  if (mutableResults == nil) {
    mutableResults = [[NSMutableDictionary alloc] init];
  }
  [mutableResults removeObjectsForKeys:[_removedKeys allObjects]];
  [mutableResults addEntriesFromDictionary:_updatedValues];
  return [mutableResults copy];
}

- (id)objectForKey:(id)key
{
  if ([_removedKeys containsObject:key]) {
    return nil;
  }
  id result = [_updatedValues valueForKey:key];
  if (result) {
    return result;
  }
  return [_originalValues objectForKey:key];
}

- (id)objectForKeyedSubscript:(id)key
{
  return [self objectForKey:key];
}

- (NSUInteger)count
{
  // TODO: this is horribly horribly inefficient. Fix it.
  return [[self dictionary] count];
}

#pragma mark - Mutation

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
  [_removedKeys removeObject:key];
  [_updatedValues setObject:object forKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
  [_removedKeys removeObject:key];
  [_updatedValues setObject:object forKeyedSubscript:key];
}

- (void)removeObjectForKey:(id<NSCopying>)key
{
  [_updatedValues removeObjectForKey:key];
  [_removedKeys addObject:key];
}

#pragma mark - VOChangeDescribing

- (VODictionaryChangeDescription *)changeDescription
{
  return [[VODictionaryChangeDescription alloc] initWithInsertedOrUpdatedKeys:[NSSet setWithArray:_updatedValues.allKeys] removedKeys:_removedKeys];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
  return [[VOChangeDescribingDictionary alloc] initWithValues:[self dictionary]
                                            changeDescription:[self changeDescription]];
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [[VOMutableChangeDescribingDictionary alloc] initWithOriginalValues:self];
}

@end
