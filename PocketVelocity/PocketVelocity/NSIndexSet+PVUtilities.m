//
//  NSIndexSet+PVUtilities.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "NSIndexSet+PVUtilities.h"

@implementation NSIndexSet (PVUtilities)

- (NSArray *)pv_indexPathsForSection:(NSUInteger)section
{
  NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:self.count];
  [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
    [results addObject:indexPath];
  }];
  return results;
}

@end
