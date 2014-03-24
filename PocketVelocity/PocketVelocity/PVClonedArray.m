//
//  PVClonedArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVArrayChangeDescription.h"
#import "PVListenableArray_Internal.h"
#import "PVClonedArray.h"

@interface PVClonedArray () <PVListening>

@end

@implementation PVClonedArray
{
  id<PVListenable> _source;
}

- (instancetype)initWithSource:(id<PVListenable>)source
{
  self = [super init];
  if (self != nil) {
    _source = source;
    [_source addListener:self];
  }
  return self;
}

- (void)dealloc
{
  [_source removeListener:self];
}

#pragma mark - PVListening

- (void)listenableObject:(id)object didChangeWithDescription:(PVArrayChangeDescription *)changeDescription
{
  [self _updateValues:changeDescription.updatedValues changeDescription:changeDescription];
}

@end
