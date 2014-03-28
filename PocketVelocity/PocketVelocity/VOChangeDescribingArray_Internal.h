//
//  PVListenableArray_Internal.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOChangeDescribingArray.h"

@interface VOChangeDescribingArray ()
{
  @protected
  NSArray *_values;
}

- (instancetype)initWithValues:(NSArray *)values changeDescription:(VOArrayChangeDescription *)changeDescription;

@end
