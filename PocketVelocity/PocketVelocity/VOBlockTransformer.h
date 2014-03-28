//
//  VOBlockTransformer.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOValueTransforming.h"

typedef id (^VOValueTransformingBlock)(id value);

@interface VOBlockTransformer : NSObject <VOValueTransforming>

- (instancetype)initWithBlock:(VOValueTransformingBlock)block;

+ (instancetype)blockTransformerWithBlock:(VOValueTransformingBlock)block;

@end
