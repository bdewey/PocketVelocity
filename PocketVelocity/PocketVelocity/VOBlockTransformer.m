//
//  VOBlockTransformer.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOBlockTransformer.h"

@implementation VOBlockTransformer
{
  VOValueTransformingBlock _block;
}

- (instancetype)initWithBlock:(VOValueTransformingBlock)block
{
  self = [super init];
  if (self != nil) {
    _block = block;
  }
  return self;
}

+ (instancetype)blockTransformerWithBlock:(VOValueTransformingBlock)block
{
  return [[[self class] alloc] initWithBlock:block];
}

#pragma mark - VOValueTransforming

- (id)transformValue:(id)value
{
  return _block(value);
}

@end
