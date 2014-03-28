//
//  VOArrayFilterer.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOValueTransforming.h"

@class VOChangeDescribingArray;

@interface VOArrayFilterer : NSObject <VOValueTransforming>

@property (nonatomic, readonly, strong) id<VOValueTransforming> transformer;
@property (nonatomic, readonly, assign) BOOL expectsPipelineSemantics;

- (instancetype)initWithTransformer:(id<VOValueTransforming>)transformer
           expectsPipelineSemantics:(BOOL)expectsPipelineSemantics;
- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)value;

@end
