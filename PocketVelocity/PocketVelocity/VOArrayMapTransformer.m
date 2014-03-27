//
//  PVMappedArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOArrayChangeDescription.h"
#import "VOArrayMapTransformer.h"
#import "VOChangeDescribingArray_Internal.h"
#import "VOMutableChangeDescribingArray.h"

@interface VOArrayMapTransformer()

@end

@implementation VOArrayMapTransformer
{
  VOChangeDescribingArray *_oldArray;
}

- (instancetype)initWithValueTransformer:(id<VOValueTransforming>)transformer
{
  self = [super init];
  if (self != nil) {
    _transformer = transformer;
  }
  return self;
}

#pragma mark - VOValueTransforming

- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)value
{
  VOArrayChangeDescription *changeDescription = value.changeDescription;
  VOMutableChangeDescribingArray *updatedMappedValues = (_oldArray != nil) ? [_oldArray mutableCopy] : [[VOMutableChangeDescribingArray alloc] init];
  [changeDescription.indexesToRemoveFromOldValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [updatedMappedValues removeObjectAtIndex:idx];
  }];
  [changeDescription.indexesToAddFromUpdatedValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    id transformedValue = [_transformer transformValue:value[idx]];
    updatedMappedValues[idx] = transformedValue;
  }];
  return [updatedMappedValues copy];
}

@end

