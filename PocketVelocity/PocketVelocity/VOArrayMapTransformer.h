//
//  PVMappedArray.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOChangeDescribingArray.h"
#import "VOValueTransforming.h"

@interface VOArrayMapTransformer : NSObject <VOValueTransforming>

@property (nonatomic, readwrite, assign) BOOL pipeliningEnabled;
@property (nonatomic, readonly, strong) id<VOValueTransforming> transformer;

- (instancetype)initWithValueTransformer:(id<VOValueTransforming>)transformer;
- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)value;

@end

