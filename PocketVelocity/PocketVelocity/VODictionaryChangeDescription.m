//
//  VODictionaryChangeDescription.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VODictionaryChangeDescription.h"
#import "VOUtilities.h"

@implementation VODictionaryChangeDescription

- (instancetype)initWithInsertedOrUpdatedKeys:(NSSet *)insertedOrUpdatedKeys removedKeys:(NSSet *)removedKeys
{
  self = [super init];
  if (self != nil) {
    _insertedOrUpdatedKeys = [insertedOrUpdatedKeys copy];
    _removedKeys = [removedKeys copy];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ updated = %@ removed = %@", [super description], _insertedOrUpdatedKeys, _removedKeys];
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[VODictionaryChangeDescription class]]) {
    return NO;
  }
  VODictionaryChangeDescription *otherChangeDescription = object;
  return VOObjectsAreEqual(_insertedOrUpdatedKeys, otherChangeDescription->_insertedOrUpdatedKeys) &&
    VOObjectsAreEqual(_removedKeys, otherChangeDescription->_removedKeys);
}

- (NSUInteger)hash
{
  return [_insertedOrUpdatedKeys hash] * 31 + [_removedKeys hash];
}

@end
