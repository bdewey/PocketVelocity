//  Copyright (c) 2014 Brian Dewey. All rights reserved.

#import <Foundation/Foundation.h>

#import "VOChangeDescribing.h"

@class VOArrayChangeDescription;

/**
 When listening to changes to this data source, the change description is class PVArrayChangeDescription.
 */
@interface VOChangeDescribingArray : NSObject <
  NSCopying,
  NSMutableCopying,
  VOChangeDescribing
>

@property (nonatomic, readonly, assign) NSUInteger count;
@property (nonatomic, readonly, copy) VOArrayChangeDescription *changeDescription;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end

