//
//  NSObject+VOUtilities.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/3/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "NSObject+VOUtilities.h"

@implementation NSObject (VOUtilities)

- (NSString *)vo_descriptionWithProperties:(NSDictionary *)properties
{
  if (properties.count == 0) {
    return [NSString stringWithFormat:@"<%@ %p>", NSStringFromClass([self class]), self];
  }
  NSMutableString *mutableResults = [[NSMutableString alloc] init];
  [mutableResults appendFormat:@"<%@ %p: {\n", NSStringFromClass([self class]), self];
  NSArray *keys = [properties.allKeys sortedArrayUsingSelector:@selector(compare:)];
  for (NSString *key in keys) {
    [mutableResults appendFormat:@"  %@ = %@;\n", key, properties[key]];
  }
  [mutableResults appendFormat:@"}>"];
  return mutableResults;
}

@end
