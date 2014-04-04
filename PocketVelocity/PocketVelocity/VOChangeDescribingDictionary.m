//
//  VOChangeDescribingDictionary.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOChangeDescribingDictionary.h"
#import "VODictionaryChangeDescription.h"
#import "VOMutableChangeDescribingDictionary.h"
#import "VOUtilities.h"

@implementation VOChangeDescribingDictionary
{
  NSDictionary *_values;
}

- (instancetype)initWithValues:(NSDictionary *)values
             changeDescription:(VODictionaryChangeDescription *)changeDescription
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
  return [self initWithValues:nil changeDescription:nil];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ values = %@ changeDescription = %@", [super description], _values, _changeDescription];
}

- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[NSDictionary class]]) {
    return [_values isEqualToDictionary:object];
  }
  if ([object isKindOfClass:[VOChangeDescribingDictionary class]]) {
    VOChangeDescribingDictionary *objectAsDictionary = object;
    return VOObjectsAreEqual(_values, objectAsDictionary->_values);
  }
  if ([object conformsToProtocol:@protocol(VODictionary)]) {
    NSDictionary *otherDictionary = [object dictionary];
    return [_values isEqualToDictionary:otherDictionary];
  }
  return NO;
}

- (NSUInteger)hash
{
  return [_values hash];
}

#pragma mark - Dictionary

- (NSDictionary *)dictionary
{
  return _values;
}

- (id)objectForKey:(id)key
{
  return [_values objectForKey:key];
}

- (id)objectForKeyedSubscript:(id)key
{
  return [_values objectForKeyedSubscript:key];
}

- (NSUInteger)count
{
  return [_values count];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [[VOMutableChangeDescribingDictionary alloc] initWithOriginalValues:self];
}

@end
