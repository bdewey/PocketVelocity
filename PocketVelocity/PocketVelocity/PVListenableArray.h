//  Copyright (c) 2014 Brian Dewey. All rights reserved.

#import <Foundation/Foundation.h>

#import "PVListenable.h"

@class PVArrayChangeDescription;

/**
 When listening to changes to this data source, the change description is class PVArrayChangeDescription.
 */
@interface PVListenableArray : NSObject <
  NSCopying,
  NSMutableCopying,
  PVListenable
>

@property (nonatomic, readonly, assign) NSUInteger count;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end

