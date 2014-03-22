//
//  NSArray+PVUtilities.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/16/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "NSArray+PVUtilities.h"


@implementation NSArray (PVUtilities)

- (NSArray *)pv_mapWithBlock:(PVUtilityMapBlock)block
{
  NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:self.count];
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    id newElement = block(obj, stop);
    if (newElement) {
      [result addObject:newElement];
    }
  }];
  return [result copy];
}

@end
